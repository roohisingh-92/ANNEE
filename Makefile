.PHONY: help install test smoke macs splits verify clean
PY ?= python3
DATA ?= data
OUT  ?= artifacts

help:
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-10s %s\n", $$1, $$2}'

install:  ## install the pinned environment
	$(PY) -m pip install -r requirements.txt

test:  ## run the unit tests (no data, no GPU)
	$(PY) -m pytest -q

smoke:  ## run the whole pipeline on synthetic data
	$(PY) scripts/smoke_test.py

macs:  ## regenerate Table 2 (and Table 10 capacity with BASELINES=1)
	$(PY) scripts/count_macs.py $(if $(BASELINES),--baselines,) --out $(OUT)/tables/table2.json

splits:  ## build all five seeds and print the Section 3.11.1 counts
	$(PY) scripts/make_splits.py --data-root $(DATA) --out $(OUT)/splits

verify:  ## re-check both leakage rules from the released index files
	$(PY) scripts/verify_leakage.py --splits $(OUT)/splits

clean:
	rm -rf .pytest_cache __pycache__ */__pycache__
