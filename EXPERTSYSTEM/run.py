import argparse
import sys
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent


def import_clipspy():
    original_sys_path = list(sys.path)
    try:
        script_dir = str(BASE_DIR)
        sys.path = [p for p in sys.path if p not in ("", script_dir)]
        import clips  # type: ignore
    finally:
        sys.path = original_sys_path

    if not hasattr(clips, "Environment"):
        raise RuntimeError(
            "Imported 'clips' but clipspy is not available. Install with: pip install clipspy"
        )

    return clips


def load_environment(clips_module):
    env = clips_module.Environment()
    env.load(str(BASE_DIR / "clips" / "facts.clp"))
    env.load(str(BASE_DIR / "clips" / "market-facts.clp"))
    env.load(str(BASE_DIR / "clips" / "fuzzy.clp"))
    env.load(str(BASE_DIR / "clips" / "rules.clp"))
    env.load(str(BASE_DIR / "tests" / "sample-scenarios.clp"))
    return env


def run_interactive(clips_module):
    env = load_environment(clips_module)
    result = env.eval("(run-interactive)")
    if result is False:
        raise RuntimeError("Interactive execution failed")


def run_default(clips_module):
    env = load_environment(clips_module)
    env.reset()
    env.run()
    env.eval("(print-results)")


def run_scenario(clips_module, scenario_id):
    env = load_environment(clips_module)
    result = env.eval(f'(run-scenario "{scenario_id}")')
    if result is False:
        raise RuntimeError(f"Scenario execution failed for '{scenario_id}'")


def run_scenario_tests(clips_module):
    env = load_environment(clips_module)
    result = env.eval("(run-all-scenario-tests)")
    if result is False:
        raise RuntimeError("One or more scenario tests failed")


def main():
    parser = argparse.ArgumentParser(
        description="Run the New Phone Purchase Decision Expert System."
    )
    parser.add_argument(
        "--scenario",
        help="Run a specific scenario: scenario-01 to scenario-05",
    )
    parser.add_argument(
        "--run-tests",
        action="store_true",
        help="Run PASS/FAIL validations for all scenarios",
    )
    parser.add_argument(
        "--interactive",
        action="store_true",
        help="Ask questions and run CLIPS using your answers",
    )
    args = parser.parse_args()

    active_modes = sum(bool(v) for v in [args.run_tests, args.scenario, args.interactive])
    if active_modes > 1:
        raise SystemExit(
            "Error: use only one mode at a time: --scenario, --run-tests, or --interactive."
        )

    try:
        clips_module = import_clipspy()
        if args.run_tests:
            run_scenario_tests(clips_module)
        elif args.scenario:
            run_scenario(clips_module, args.scenario)
        elif args.interactive:
            run_interactive(clips_module)
        else:
            run_default(clips_module)
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)


if __name__ == "__main__":
    main()
