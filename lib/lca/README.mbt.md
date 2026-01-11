# Lowest Common Ancestor (Reference)

Find the LCA of two nodes in a tree using binary lifting and depth alignment.

## What it demonstrates

- Precomputing 2^k ancestors
- Lifting nodes to equal depth
- Jumping both nodes upward to the LCA

## Pseudocode sketch

```mbt nocheck
lift(u, depth[u] - depth[v])
for k from LOG down to 0:
  if up[k][u] != up[k][v]:
    u = up[k][u]
    v = up[k][v]
return parent[u]
```

## Notes

- Preprocessing: O(n log n)
- Query: O(log n)
- This package is a reference implementation with invariants
