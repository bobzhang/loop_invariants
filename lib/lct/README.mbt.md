# Link-Cut Tree (Reference)

Dynamic tree data structure supporting link, cut, and path queries in
logarithmic amortized time.

## What it demonstrates

- Splay-based preferred paths
- Expose operation to access root-to-node path
- Link and cut operations on trees

## Pseudocode sketch

```mbt nocheck
access(x)
make_root(x)
link(x, y)
cut(x, y)
```

## Notes

- Amortized time: O(log n) per operation
- This package is a reference implementation with invariants
