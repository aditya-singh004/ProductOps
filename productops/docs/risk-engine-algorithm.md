# Risk Engine Algorithm

The Java service calculates a deterministic score from 0 to 100.

## Weighted Signals

- Blocked high-priority tasks: up to 45 points.
- Overdue tasks: up to 20 points.
- Actual-vs-estimate variance: up to 18 points.
- Delayed critical path tasks: up to 18 points.
- Pending high-priority tasks: up to 12 points.
- Tasks depending on blocked predecessors: up to 12 points.

The score is clamped between 0 and 100.

## Thresholds

- `0-30`: LOW
- `31-65`: MEDIUM
- `66-100`: HIGH

## Explainability

The response includes human-readable reasons such as blocked high-priority work, overdue tasks, large variance, critical path delay, and blocked dependency chains.

## Edge Cases

- Empty task lists are rejected by validation.
- Zero total estimate avoids division by zero and gives zero variance contribution.
- Unknown statuses are treated as pending unless they equal `DONE`.
- Missing dependency arrays are treated as empty.
