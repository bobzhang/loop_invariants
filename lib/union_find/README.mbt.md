# Union-Find (Disjoint Set Union) (Reference)

Maintain connectivity under union operations and answer connectivity queries
in near-constant time.

## What it demonstrates

- Union by size/rank
- Path compression
- Connectivity checks

## Pseudocode sketch

```mbt nocheck
if find(a) == find(b): connected
else: union(a, b)
```

## Notes

- Amortized time: O(alpha(n)) per operation
- This package is a reference implementation with invariants
- For a challenge-style API, see `lib/challenge_union_find_rollback`
