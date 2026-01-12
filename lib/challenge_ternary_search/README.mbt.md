# Challenge: Ternary Search (Unimodal Array)

Find the minimum (or maximum) in a unimodal sequence by shrinking the search
interval to the side that must contain the extremum.

## What you learn

- Using two midpoints to discard one third of the range
- Reasoning about unimodal structure
- Termination with a small remaining window

## Pseudocode sketch

```mbt nocheck
while hi - lo > 3:
  m1 = lo + (hi - lo) / 3
  m2 = hi - (hi - lo) / 3
  if f(m1) < f(m2): hi = m2 - 1
  else: lo = m1 + 1
```

## Example

```mbt check
///|
test "ternary search unimodal" {
  let arr : Array[Int] = [9, 7, 5, 3, 4, 6, 8]
  let idx = @challenge_ternary_search.find_min_unimodal(arr[:])
  inspect(idx, content="3")
}
```

## Another Example

```mbt check
///|
test "ternary search decreasing" {
  let arr : Array[Int] = [5, 4, 3, 2, 1]
  let idx = @challenge_ternary_search.find_min_unimodal(arr[:])
  inspect(idx, content="4")
}
```

## Notes

- Time complexity: O(log n)
- Requires unimodality for correctness
