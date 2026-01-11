# Dinic Max Flow (Reference)

Compute the maximum flow in a directed graph using level graphs and blocking
flows.

## What it demonstrates

- BFS to build level graph
- DFS to send blocking flow
- Repeating until no augmenting path exists

## Pseudocode sketch

```mbt nocheck
while bfs_levels():
  while pushed = dfs_blocking():
    flow += pushed
```

## Notes

- Time complexity: O(E * V^2) worst case, faster in practice
- This package is a reference implementation with invariants
