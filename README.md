# New Phone Purchase Decision Expert System

A CLIPS-based expert system that helps users decide whether to buy a new phone, repair their current phone, replace the battery, wait, or choose a suitable phone category.

## Features

- Final decision layer (`final-decision`) with certainty
- Split output sections: **Final Decision**, **Key Findings**, and **Supporting Recommendations**
- Adds **Suggested Phone Category** summary before optional model examples
- Certainty-factor confidence scores with mandatory gate conditions
- Replacement and blocking inference (`replacement-needed`, `no-upgrade-needed`)
- Detailed model suggestions are always evaluated and shown when relevant
- Fuzzy logic for battery, performance, budget, urgency, and repair cost
- Scenario-based testing (`scenario-01` to `scenario-05`) with positive + negative CF checks
- Scenario-based testing also includes negative category checks
- Scenario-based testing includes negative final-decision conflict checks
- Python launcher using `clipspy` (load, run, print only; no Python-side decision logic)

## Project Structure

```text
.
├── README.md
└── EXPERTSYSTEM/
    ├── run.py
    ├── main.clp
    ├── clips/
    │   ├── facts.clp
    │   ├── market-facts.clp
    │   ├── fuzzy.clp
    │   ├── rules.clp
    │   └── main.clp
    ├── tests/
    │   └── sample-scenarios.clp
    └── scripts/
        └── build_market_facts.py
```

## Installation

```bash
python3 -m pip install clipspy
```

## Usage

```bash
cd EXPERTSYSTEM
python3 run.py
```

Run a scenario:

```bash
python3 run.py --scenario scenario-01
python3 run.py --scenario scenario-03
```

Run all scenario validation tests:

```bash
python3 run.py --run-tests
```

Run interactive questionnaire mode:

```bash
python3 run.py --interactive
```

In `--interactive`, the interview flow is implemented in CLIPS (`run-interactive`), including dependent prompts and score derivation.
Interactive mode now asks numeric-first values for key fields (`budget-cad`, `urgency-score`, `repair-cost-percent`, `performance-score`, `battery-health-percent`) and derives symbolic categories in CLIPS.

Rebuild CLIPS market facts from CSV files:

```bash
python3 scripts/build_market_facts.py
```

## Scenarios

- `scenario-01`: old phone with multiple major issues
- `scenario-02`: good phone with low urgency
- `scenario-03`: battery issue only
- `scenario-04`: low budget with high urgency
- `scenario-05`: high budget with high camera/gaming needs

## CLIPS-only Entry Points

From `EXPERTSYSTEM/`:

```clips
(load "main.clp")
```

From CLIPS with manual scenario execution:

```clips
(clear)
(load "clips/facts.clp")
(load "clips/market-facts.clp")
(load "clips/fuzzy.clp")
(load "clips/rules.clp")
(load "tests/sample-scenarios.clp")
(reset)
(run-scenario "scenario-01")
(run-all-scenario-tests)
```

## Notes

- The system is decision-support only; it does not sell phones.
- Recommendations are based on CLIPS rule matching, certainty factors, and fuzzy membership functions.
- `run.py` is intentionally minimal orchestration: it loads CLIPS files, executes CLIPS entry points, and prints CLIPS output.
- Interactive question flow and input dependencies are handled in CLIPS, not Python.
- `software-support` (update status) and `platform` (`ios`/`android`/`other`) are separated to avoid mixing meanings.
- Model shortlists are generated from `market-facts.clp`, which is built from the included CSV datasets (not live web pricing), and are only shown when the final decision supports upgrade paths.
- Sections with no applicable output explicitly show `None generated.`
- `market-facts.clp` stores prices in CAD (pre-converted from BDT using `1 CAD = 90 BDT`), and model-selection thresholds use CAD directly.
