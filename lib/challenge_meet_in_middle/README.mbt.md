# Challenge: Meet-in-the-Middle

Split a set into two halves to reduce exponential search from O(2^n) to
O(2^(n/2)). Used here for subset sum.

## What you learn

- Enumerating subset sums for each half
- Sorting one half and binary searching for the best complement
- Combining results safely within a limit

## Pseudocode sketch

```mbt nocheck
left_sums = all_subset_sums(left)
right_sums = all_subset_sums(right)
sort(right_sums)
for s in left_sums:
  best = max(best, s + best_leq(right_sums, limit - s))
```

## Notes

- Time complexity: O(2^(n/2) log 2^(n/2))
- Useful when n is around 40
