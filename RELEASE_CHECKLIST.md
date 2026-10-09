# Release checklist

Section 3.12 of the manuscript states that the artefacts below are available
at this repository. They are produced by the commands in the right-hand
column. **Complete this list before submitting**, or the availability
statement is not yet true.

| # | Promised in Section 3.12 | Command | Done |
|---|---|---|---|
| 1 | the implementation | already here | [x] |
| 2 | environment specification with pinned library versions | `pip freeze > environment/paper-environment.txt` on the training machine | [ ] |
| 3 | split index files for all five seeds | `make splits` | [ ] |
| 4 | per-seed lesion identifier lists for both leakage rules | same (`split_index.json`, `leakage_counts.json`) | [ ] |
| 5 | per-image classification predictions, full probability vectors | `scripts/run_experiment.py` for each variant × seed × archive | [ ] |
| 6 | per-image segmentation masks, 256×256 binary PNG | same | [ ] |
| 7 | raw region and boundary probability maps `R̂`, `Ê` | same (`region_prob/`, `boundary_prob/`) | [ ] |
| 8 | Stage-1 and Stage-3 checkpoints | same (`artifacts/checkpoints/`) | [ ] |
| 9 | per-epoch training and validation logs | same (`stage*_log.json`) | [ ] |
| 10 | per-epoch trajectories of `s_e`, `s_l` and the two shares | same, in the Stage-1 and Stage-3 logs | [ ] |
| 11 | `seg_metrics.py`, `cls_metrics.py` and the significance scripts | already here | [x] |
| 12 | leakage verification output for all five seeds | `make verify > artifacts/splits/verification.txt` | [ ] |

## Before you push

- [ ] `make test` passes
- [ ] `make smoke` passes
- [ ] `scripts/make_splits.py` output reconciled with Section 3.11.1 and Table 3 (`docs/REPORTED_NUMBERS.md`)
- [ ] `docs/KNOWN_DISCREPANCIES.md` worked through; Table 10 and Section 4.2 updated
- [ ] the repository is **public**, or a reviewer-access link is supplied — Section 3.12 gives a bare URL, which must resolve
- [ ] a release is tagged and archived (Zenodo or equivalent) so the "permanent archive deposited on acceptance" sentence can be honoured
- [ ] `CITATION.cff` updated with the final DOI

## Note on size

Items 7 and 8 are the large ones: 260 probability-map pairs per run as float16
is roughly 35 MB, and each checkpoint about 30 MB. Across 12 variants and 5
seeds that exceeds a comfortable Git repository. Either commit the artefacts
for variant (A) and the Stage-1/Stage-3 checkpoints only and deposit the rest
in the archive, or use Git LFS. Say in the README which choice you made.
