# Challenge: Line Sweep (Max Overlap)

Compute the maximum number of overlapping intervals by sorting endpoints and
sweeping left to right.

## What you learn

- Event representation (start +1, end -1)
- Sorting events by position, with tie handling
- Maintaining a running count and maximum

## Pseudocode sketch

```mbt nocheck
sort events
for event in events:
  active += event.delta
  best = max(best, active)
```

## Example

```mbt check
///|
test "line sweep basic" {
  let intervals : Array[(Int, Int)] = [(1, 3), (2, 5), (4, 6)]
  let best = @challenge_line_sweep.max_overlap(intervals[:])
  inspect(best, content="2")
}
```

## Another Example

```mbt check
///|
test "line sweep heavy overlap" {
  let intervals : Array[(Int, Int)] = [(1, 4), (2, 3), (2, 5)]
  let best = @challenge_line_sweep.max_overlap(intervals[:])
  inspect(best, content="3")
}
```

## Notes

- Time complexity: O(n log n)
- Space complexity: O(n)
