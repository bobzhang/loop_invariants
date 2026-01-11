# Lazy Segment Tree (Reference)

Segment tree with deferred updates to support fast range updates and queries.

## What it demonstrates

- Lazy propagation of pending updates
- Push-down to children when needed
- Range add / range assign patterns

## Pseudocode sketch

```mbt nocheck
update(node, l, r, ql, qr, delta):
  if covered: apply + mark lazy
  else: push and recurse
```

## Notes

- Time complexity: O(log n) per update/query
- This package is a reference implementation with invariants
