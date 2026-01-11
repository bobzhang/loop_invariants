# Persistent Segment Tree (Reference)

Segment tree that preserves previous versions by path copying on updates.

## What it demonstrates

- Functional updates that share unchanged nodes
- Querying any historical version
- Memory/time trade-offs

## Pseudocode sketch

```mbt nocheck
update(node, l, r, idx, delta):
  if leaf: return new node
  else: copy node and update one child
```

## Notes

- Time complexity: O(log n) per update/query
- Space: O(log n) per update
