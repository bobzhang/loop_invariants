# Link-Cut Tree (Reference, Alternate)

Another link-cut tree implementation focusing on explicit splay rotations and
path-parent management.

## What it demonstrates

- Preferred path decomposition
- Splaying to expose paths
- Dynamic link and cut operations

## Pseudocode sketch

```mbt nocheck
access(x)
link(x, y)
cut(x, y)
```

## Notes

- Amortized time: O(log n)
- This package is a reference implementation with invariants
