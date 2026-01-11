# Heavy-Light Decomposition (Reference)

Decompose a tree into heavy paths to reduce path queries to O(log^2 n)
segment queries.

## What it demonstrates

- Subtree size computation and heavy child choice
- Head assignment for heavy paths
- Converting path queries into interval queries

## Pseudocode sketch

```mbt nocheck
dfs_sizes(u)
dfs_decompose(u, head)
query_path(u, v):
  while head[u] != head[v]:
    climb heavy path
```

## Notes

- Preprocessing: O(n)
- Path query: O(log^2 n)
- This package is a reference implementation with invariants
