# Challenge: Union-Find with Rollback

A disjoint-set union (DSU) that can undo merges, useful for offline queries
and divide-and-conquer on time.

## What you learn

- Logging parent/size changes
- Rolling back to a previous snapshot
- Keeping union by size without path compression

## Pseudocode sketch

```mbt nocheck
snap = dsu.snapshot()
if dsu.union(a, b):
  ...
dsu.rollback(snap)
```

## Notes

- Typical use: dynamic connectivity offline
- Path compression is avoided to allow rollback
