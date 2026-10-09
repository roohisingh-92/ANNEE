# ANNEE — Adaptive Neural Edge Enhancement for Skin Lesion Segmentation and Classification

Reference implementation for

> R. Singh and R. C. Gangwar, "Adaptive Neural Edge Enhancement for Robust and
> Interpretable Skin Lesion Segmentation and Classification", *KSII
> Transactions on Internet and Information Systems* (under review).

This repository is what Section 3.12 of the manuscript points to. It holds the
implementation, the split construction with both leakage-control rules, the
three-stage training protocol, the inference path, and the scripts that
recompute every number the paper reports for its own models.

```
pip install -r requirements.txt
pytest -q                     # 79 tests, no data or GPU needed
python scripts/count_macs.py  # regenerates Table 2
python scripts/smoke_test.py  # whole pipeline on synthetic data, ~2 min on CPU
```

---

## What is here

| Path | Contents |
|---|---|
| `annee/config.py` | every constant the paper fixes, with its section number |
| `annee/preprocessing.py` | resize, normalise, smooth, Sobel on BT.601 luma, `E_true` |
| `annee/models.py` | attention gate, two-head ANNEE U-Net, classifier |
| `annee/losses.py` | **Eqs. (13), (14), (15a)–(15c) — the only place a loss is defined** |
| `annee/postprocess.py` | Otsu, morphology, largest component, boundary confidence |
| `annee/splits.py` | stratified lesion-grouped splits, leakage rules (i) and (ii) |
| `annee/train.py` | Stages 1, 2 and 3, with named checkpoints and per-epoch logs |
| `annee/predict.py` | writes the released prediction artefacts |
| `annee/metrics.py` | Dice, IoU, sensitivity, specificity, boundary-F, HD95; Tables 4–5 |
| `annee/stats.py` | McNemar, DeLong, bootstrap |
| `annee/macs.py` | the single MAC counter used for Table 2 **and** Table 10 |
| `annee/baselines.py` | the Table 10 baselines, counted through the same counter |
| `annee/variants.py` | ablation variants (A)–(L) and which checkpoint each is scored at |

Scripts are in `scripts/`; the two the manuscript names by file name are
`scripts/seg_metrics.py` and `scripts/cls_metrics.py`.

---

## The four reviewer requests, in code

`docs/MANUSCRIPT_MAP.md` is the detailed version. In brief:

1. **Which checkpoint produced each Table 9 row.** `annee/variants.py:checkpoint_stage`
   decides it, `scripts/run_experiment.py` loads it, and
   `annee/predict.py` writes `checkpoint_stage` and `finetuned_on` into the
   prediction manifest. A Table 9 row is never ambiguous again.
2. **One objective per training stage.** `annee/losses.py` implements
   Eqs. (13), (14) and (15a)–(15c) and nothing else. `tests/test_losses.py`
   asserts the mean reduction of Eq. (13), the presence of the region term in
   Eq. (14), and that the reported `alpha ≈ 0.31 / beta ≈ 0.69` are the
   *normalised shares*, not the raw `exp(-s)` coefficients.
3. **Reproducibility and the placeholders.** `scripts/make_splits.py` prints
   every count Section 3.11.1 and Table 3 quote; `scripts/verify_leakage.py`
   repeats the empty-intersection check from the released index files alone.
4. **Reporting consistency.** `scripts/count_macs.py` applies one counting
   convention to every model, ANNEE and baselines alike, and separates the
   classification network from the complete pipeline.

---

## Running the experiments

```bash
# 0. place the archives under data/ (see docs/DATA.md)

# 1. build the splits for all five seeds and apply both leakage rules
python scripts/make_splits.py --data-root data --out artifacts/splits
python scripts/verify_leakage.py --splits artifacts/splits

# 2. one variant, one seed, all three stages plus predictions
python scripts/run_experiment.py --variant A --seed 0 --dataset isic2019

# 3. recompute the tables from the saved predictions, no retraining
python scripts/seg_metrics.py \
    --predictions artifacts/predictions/A_isic2019_seed{0,1,2,3,4}/segmentation \
    --ground-truth data/isic2018/masks --aggregate
python scripts/cls_metrics.py \
    --predictions artifacts/predictions/A_isic2019_seed{0,1,2,3,4}/classification/predictions.csv \
    --aggregate
```

`docs/REPRODUCING.md` gives the command behind every table in the paper.

## Three-stage protocol

| Stage | Data | Objective | Trains | Checkpoint |
|---|---|---|---|---|
| 1 | ISIC 2018 Task 1 | Eq. (15a) | gate + U-Net, `s_e`, `s_l` | `stage1.weights.h5` |
| 2 | ISIC 2019 **or** HAM10000 | Eq. (15b) | classifier only | `stage2_<archive>.weights.h5` |
| 3 | the same archive | Eq. (15c) | decoder, gate, classifier, `s_e` | `stage3_<archive>_*.weights.h5` |

`L_lesion` is active in Stage 1 only: `E_true` exists for ISIC 2018 Task 1 and
nowhere else. Stage 3 runs separately per archive, so there is one Stage-3
checkpoint per archive, and Table 9 reports the ISIC 2019 one.

The morphological block never appears in a training graph. Otsu thresholding,
binarisation, closing, opening, hole filling and connected-component selection
live in `annee/postprocess.py` and are called from the prediction scripts only.

## Requirements

Python 3.11+, TensorFlow 2.x. The pinned set in `requirements.txt` is the
environment this repository is tested against; record the environment the
reported experiments actually used in `environment/paper-environment.txt`.

## Status of the released artefacts

`artifacts/` ships with its directory structure and a README per folder, not
with results. Run the commands above to populate it, then commit the outputs —
`RELEASE_CHECKLIST.md` lists each item Section 3.12 promises and the command
that produces it. **Do not submit the manuscript before that checklist is
complete**: Section 3.12 states these artefacts are available here.

## Licence

Code under the MIT Licence (`LICENSE`). The ISIC and HAM10000 archives carry
their own terms and are not redistributed here.
