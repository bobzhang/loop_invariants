# Max Flow (Reference)

Reference implementation of max flow with level graph and blocking flow ideas.

## What it demonstrates

- Residual graph representation
- BFS level construction
- DFS augmentation with iterators

## Pseudocode sketch

```mbt nocheck
while bfs(source, sink):
  iter = 0
  while f = dfs(source, sink):
    flow += f
```

## Notes

- Complexity depends on the specific algorithm variant
- This package is a reference implementation with invariants
