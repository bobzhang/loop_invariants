# Bipartite Matching (Reference)

Compute a maximum matching in a bipartite graph. This implementation uses a
layered BFS + DFS approach (Hopcroft-Karp).

## What it demonstrates

- BFS layering from unmatched left nodes
- DFS to find vertex-disjoint augmenting paths
- Repeating until no augmenting path exists

## Pseudocode sketch

```mbt nocheck
while bfs_level_graph():
  for u in left:
    if dfs_augment(u): matching++
```

## Notes

- Time complexity: O(E * sqrt(V))
- This package is a reference implementation with invariants
