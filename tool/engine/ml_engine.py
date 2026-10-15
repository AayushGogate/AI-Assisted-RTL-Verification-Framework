"""
ML Engine: RandomForestClassifier with RandomForestRegressor Fallback
and Random-Selection Baseline Comparison.
"""

from typing import Dict, Any, List, Optional, Tuple, Set
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, confusion_matrix

def run_ml_analysis(
    analysis_data: Dict[str, Any],
    dut_plugin: Any,
    top_n: int = 10,
    random_state: int = 42
) -> Dict[str, Any]:
    """
    Executes the ML recommendation pipeline:
    1. Checks if ML action is needed.
    2. Labels tested data (rare vs common).
    3. Deduplicates vectors before train/validation split.
    4. Trains and evaluates RandomForestClassifier on held-out validation data.
    5. Retrains on all tested data and scores untested vectors by P(rare).
    6. Triggers RandomForestRegressor fallback for zero-example numeric boundary gaps.
    7. Evaluates chosen candidates against bin_fn strictly AFTER model selection.
    8. Benchmarks against 20-draw Random-Selection Baseline.
    """
    missing_bins: List[str] = analysis_data["missing_bins"]
    under_covered_bins: List[str] = analysis_data["under_covered_bins"]
    total_bins: int = analysis_data["total_bins"]
    bins_hit_before: int = analysis_data["bins_hit"]
    input_cols: List[str] = analysis_data["input_cols"]
    decoded_df: pd.DataFrame = analysis_data["decoded_df"]
    tested_tuples: Set[Tuple[int, ...]] = analysis_data["tested_tuples"]
    full_space: List[Tuple[int, ...]] = analysis_data["full_space"]

    # 1. Check if ML action is needed
    if not missing_bins and not under_covered_bins:
        return {
            "ml_needed": False,
            "status": "fully_covered",
            "message": "Fully covered: No coverage bins are missing or under-covered. No ML action needed.",
            "classifier_skipped": True,
            "candidates": [],
            "random_baseline": None,
            "projected_coverage_pct": analysis_data["coverage_pct"],
        }

    # 2. Labelling Rule
    rare_bins_set = set(missing_bins) | set(under_covered_bins)

    # Compute untested candidates dataframe
    untested_vectors = [v for v in full_space if v not in tested_tuples]
    if not untested_vectors:
        return {
            "ml_needed": False,
            "status": "input_space_exhausted",
            "message": "Full input space has already been simulated.",
            "classifier_skipped": True,
            "candidates": [],
            "random_baseline": None,
            "projected_coverage_pct": analysis_data["coverage_pct"],
        }

    cand_df = pd.DataFrame(untested_vectors, columns=input_cols)

    # Deduplicate tested vectors before train/validation split
    dedup_df = decoded_df[input_cols].drop_duplicates().copy()
    dedup_bins = [dut_plugin.bin_fn(dict(zip(input_cols, row))) for row in dedup_df.values]
    dedup_df["target_rare"] = [1 if b in rare_bins_set else 0 for b in dedup_bins]

    num_rare_examples = int(dedup_df["target_rare"].sum())
    num_common_examples = len(dedup_df) - num_rare_examples
    unique_vectors_used = len(dedup_df)

    # Containers for results
    classifier_skipped = False
    classifier_skip_reason: Optional[str] = None
    validation_metrics: Optional[Dict[str, Any]] = None
    confusion_table: Optional[Dict[str, int]] = None
    ranked_candidates: List[Dict[str, Any]] = []

    # 3. Primary Technique: RandomForestClassifier
    if dedup_df["target_rare"].nunique() < 2:
        # Only one class present (typically common=0 when missing bins have 0 training examples)
        classifier_skipped = True
        classifier_skip_reason = (
            f"Training labels contain only one class ({num_rare_examples} rare, {num_common_examples} common). "
            "The classifier cannot learn to predict a rare class from zero positive examples in tested data."
        )
        cand_df["rare_probability"] = 0.0
    else:
        # Check if stratified split is possible (each class needs at least 2 instances)
        can_stratify = (num_rare_examples >= 2) and (num_common_examples >= 2)
        stratify_arg = dedup_df["target_rare"].values if can_stratify else None

        X = dedup_df[input_cols].values
        y = dedup_df["target_rare"].values

        # If dataset is very small, use 25% or minimum 1 sample
        test_size = 0.25 if len(dedup_df) >= 8 else 0.2

        try:
            X_train, X_val, y_train, y_val = train_test_split(
                X, y, test_size=test_size, random_state=random_state, stratify=stratify_arg
            )

            clf = RandomForestClassifier(n_estimators=100, random_state=random_state)
            clf.fit(X_train, y_train)

            y_val_pred = clf.predict(X_val)
            acc = float(accuracy_score(y_val, y_val_pred))
            prec = float(precision_score(y_val, y_val_pred, zero_division=0))
            rec = float(recall_score(y_val, y_val_pred, zero_division=0))

            # Predicted vs Actual table
            # Confusion matrix: [[TN, FP], [FN, TP]]
            cm = confusion_matrix(y_val, y_val_pred, labels=[0, 1])
            tn, fp, fn, tp = int(cm[0, 0]), int(cm[0, 1]), int(cm[1, 0]), int(cm[1, 1])

            validation_metrics = {
                "accuracy": round(acc, 4),
                "precision": round(prec, 4),
                "recall": round(rec, 4),
                "val_samples_count": len(y_val),
            }
            confusion_table = {
                "true_negative": tn,
                "false_positive": fp,
                "false_negative": fn,
                "true_positive": tp,
            }

            # Retrain on all deduplicated tested data before predicting on untested candidates
            clf.fit(X, y)
            classes = list(clf.classes_)
            if 1 in classes:
                rare_idx = classes.index(1)
                cand_df["rare_probability"] = clf.predict_proba(cand_df[input_cols].values)[:, rare_idx]
            else:
                cand_df["rare_probability"] = 0.0

        except Exception as e:
            classifier_skipped = True
            classifier_skip_reason = f"Classifier training encountered error: {str(e)}"
            cand_df["rare_probability"] = 0.0

    # 4. Fallback Technique: RandomForestRegressor
    regressor_fallback_used = False
    regressor_fallback_reason: Optional[str] = None
    unreachable_bins: List[str] = []

    # Identify missing bins that had ZERO training examples
    tested_bin_counts = analysis_data["per_bin_data"]
    zero_example_missing = [
        item["bin"] for item in tested_bin_counts if item["status"] == "missing"
    ]

    numeric_fn = getattr(dut_plugin, "numeric_target_fn", None)
    selected_by_model: List[Dict[str, Any]] = []

    if zero_example_missing:
        if numeric_fn is not None:
            regressor_fallback_used = True
            regressor_fallback_reason = (
                f"Missing bins {zero_example_missing} have 0 training examples. "
                f"Triggered RandomForestRegressor on numeric target '{dut_plugin.DUT_NAME}'."
            )
            # Train regressor on tested data using numeric_target_fn
            y_numeric = [numeric_fn(dict(zip(input_cols, row))) for row in dedup_df[input_cols].values]
            reg = RandomForestRegressor(n_estimators=100, random_state=random_state)
            reg.fit(dedup_df[input_cols].values, y_numeric)

            # Predict numeric target on untested candidates
            cand_df["predicted_numeric"] = reg.predict(cand_df[input_cols].values)

            # Select candidates based ONLY on model output:
            # Check if plugin has explicit boundary mapping (e.g. sum_zero -> min, sum_max -> max)
            numeric_targets_map = getattr(dut_plugin, "NUMERIC_BIN_TARGETS", {})

            regressor_picks = []
            for mb in zero_example_missing:
                target_info = numeric_targets_map.get(mb)
                if target_info:
                    direction = target_info.get("direction")
                    target_val = target_info.get("target_val")
                    if direction == "min":
                        # Untested vectors with lowest predicted numeric value
                        sorted_cands = cand_df.sort_values("predicted_numeric", ascending=True)
                        regressor_picks.append(sorted_cands.head(2))
                    elif direction == "max":
                        # Untested vectors with highest predicted numeric value
                        sorted_cands = cand_df.sort_values("predicted_numeric", ascending=False)
                        regressor_picks.append(sorted_cands.head(2))
                    elif target_val is not None:
                        # Untested vectors with predicted value closest to target_val
                        dist = (cand_df["predicted_numeric"] - target_val).abs()
                        sorted_cands = cand_df.iloc[dist.argsort()]
                        regressor_picks.append(sorted_cands.head(2))
                else:
                    # General numeric boundaries: pick min and max predicted extremes
                    sorted_asc = cand_df.sort_values("predicted_numeric", ascending=True)
                    sorted_desc = cand_df.sort_values("predicted_numeric", ascending=False)
                    regressor_picks.extend([sorted_asc.head(1), sorted_desc.head(1)])

            if regressor_picks:
                reg_chosen_df = pd.concat(regressor_picks).drop_duplicates(subset=input_cols)
                reg_chosen_indices = set(reg_chosen_df.index)
                for idx, r in reg_chosen_df.iterrows():
                    vec_dict = {col: int(r[col]) for col in input_cols}
                    selected_by_model.append({
                        **vec_dict,
                        "selection_method": "regressor_extrapolation",
                        "rare_probability": None,
                        "predicted_numeric": round(float(r["predicted_numeric"]), 2),
                    })
                # Remove selected from cand_df so classifier picks remainder
                cand_df = cand_df.drop(index=list(reg_chosen_indices))

        else:
            # Zero examples and no numeric_target_fn -> strictly mark unreachable
            unreachable_bins = list(zero_example_missing)

    # 5. Add top classifier candidates by P(rare)
    if "rare_probability" in cand_df.columns and not cand_df.empty:
        sorted_cls = cand_df.sort_values("rare_probability", ascending=False)
        needed_more = max(0, top_n - len(selected_by_model))
        for _, r in sorted_cls.head(needed_more).iterrows():
            vec_dict = {col: int(r[col]) for col in input_cols}
            selected_by_model.append({
                **vec_dict,
                "selection_method": "classifier_p_rare",
                "rare_probability": round(float(r["rare_probability"]), 4),
                "predicted_numeric": None,
            })

    # If still fewer than top_n, fill from remaining sorted candidates
    if len(selected_by_model) < top_n and not cand_df.empty:
        remainder = cand_df.head(top_n - len(selected_by_model))
        for _, r in remainder.iterrows():
            vec_dict = {col: int(r[col]) for col in input_cols}
            selected_by_model.append({
                **vec_dict,
                "selection_method": "model_ranked",
                "rare_probability": round(float(r.get("rare_probability", 0.0)), 4),
                "predicted_numeric": None,
            })

    # 6. Evaluate chosen candidates using bin_fn STRICTLY AFTER model selection
    # (Per requirement: Candidate selection uses ONLY model outputs. bin_fn may not filter or choose.)
    final_candidates = []
    closed_bins_by_ml = set()

    for idx, cand in enumerate(selected_by_model[:top_n]):
        inputs_only = {col: cand[col] for col in input_cols}
        actual_bin = dut_plugin.bin_fn(inputs_only)
        closes_gap = actual_bin in missing_bins
        if closes_gap:
            closed_bins_by_ml.add(actual_bin)

        final_candidates.append({
            "rank": idx + 1,
            "inputs": inputs_only,
            "actual_bin": actual_bin,
            "closes_gap": closes_gap,
            "selection_method": cand["selection_method"],
            "rare_probability": cand["rare_probability"],
            "predicted_numeric": cand.get("predicted_numeric"),
        })

    ml_gaps_closed_count = len(closed_bins_by_ml)

    # 7. Random-Selection Baseline Comparison
    # Pick same number of untested vectors at random (seed 42, 20 draws)
    k_candidates = len(final_candidates)
    rng = np.random.default_rng(random_state)
    random_draw_counts = []
    untested_arr = np.array(untested_vectors)

    if len(untested_vectors) >= k_candidates and k_candidates > 0:
        for _ in range(20):
            sample_indices = rng.choice(len(untested_vectors), size=k_candidates, replace=False)
            sampled_vecs = untested_arr[sample_indices]
            draw_closed = set()
            for s_vec in sampled_vecs:
                b = dut_plugin.bin_fn(dict(zip(input_cols, s_vec)))
                if b in missing_bins:
                    draw_closed.add(b)
            random_draw_counts.append(len(draw_closed))

        random_mean_closed = float(np.mean(random_draw_counts))
        random_std_closed = float(np.std(random_draw_counts))
    else:
        random_mean_closed = 0.0
        random_std_closed = 0.0

    # ML Win Determination: ML ranking counts as a win only if it does better
    is_ml_win = ml_gaps_closed_count > random_mean_closed
    ml_win_status = "WIN" if is_ml_win else ("TIE" if ml_gaps_closed_count == random_mean_closed else "LOSS")

    # Projected Coverage before RTL verification confirmation
    projected_bins_hit = bins_hit_before + ml_gaps_closed_count
    projected_coverage_pct = round((projected_bins_hit / total_bins * 100.0), 2) if total_bins > 0 else 0.0

    return {
        "ml_needed": True,
        "status": "gaps_targeted",
        "labelling_rule": "Rare = missing or count < 50% of mean; common otherwise",
        "unique_vectors_used": unique_vectors_used,
        "num_rare_examples": num_rare_examples,
        "num_common_examples": num_common_examples,
        "classifier_skipped": classifier_skipped,
        "classifier_skip_reason": classifier_skip_reason,
        "validation_metrics": validation_metrics,
        "confusion_table": confusion_table,
        "regressor_fallback_used": regressor_fallback_used,
        "regressor_fallback_reason": regressor_fallback_reason,
        "unreachable_bins": unreachable_bins,
        "candidates": final_candidates,
        "ml_gaps_closed_count": ml_gaps_closed_count,
        "ml_gaps_closed_bins": list(closed_bins_by_ml),
        "random_baseline": {
            "num_draws": 20,
            "seed": random_state,
            "k_candidates": k_candidates,
            "mean_gaps_closed": round(random_mean_closed, 2),
            "std_gaps_closed": round(random_std_closed, 2),
            "is_ml_win": is_ml_win,
            "win_status": ml_win_status,
            "comparison_text": (
                f"ML closed {ml_gaps_closed_count} missing bin(s) vs "
                f"Random Selection's 20-draw average of {random_mean_closed:.2f} bin(s). "
                + ("(ML Win: AI candidate prioritization beat random stimulus)" if is_ml_win else
                   "(ML did not outperform the random baseline for this budget)")
            ),
        },
        "projected_coverage_pct": projected_coverage_pct,
        "projected_bins_hit": projected_bins_hit,
    }
