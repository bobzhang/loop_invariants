# Challenge: Binary Search on Answer

Find the smallest value that satisfies a monotone predicate by binary search.

## What you learn

- Monotone feasibility checks
- Loop invariants for lower/upper bounds
- Separating feasibility from search logic

## Pseudocode sketch

```mbt nocheck
while low < high:
  mid = (low + high) / 2
  if feasible(mid): high = mid
  else: low = mid + 1
```

## Example

```mbt check
///|
test "binary search answer capacity" {
  let weights : Array[Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  let ans = @challenge_binary_search_answer.min_capacity(weights[:], 5)
  inspect(ans, content="15")
}
```

## Another Example

```mbt check
///|
test "binary search answer feasibility" {
  let weights : Array[Int] = [3, 2, 2, 4, 1, 4]
  inspect(
    @challenge_binary_search_answer.can_ship(weights[:], 3, 6),
    content="true",
  )
  inspect(
    @challenge_binary_search_answer.can_ship(weights[:], 3, 5),
    content="false",
  )
}
```

## Notes

- Time complexity: O(log R * cost(feasible))
- Useful for capacity, speed, or threshold problems
