# Cartesian Tree (Reference)

Build a tree that preserves array order and heap property. Useful for RMQ and
range minimum/maximum queries.

## What it demonstrates

- Stack-based O(n) construction
- In-order traversal matches original array order
- Heap property on values

## Pseudocode sketch

```mbt nocheck
for each value:
  pop while stack top > value
  attach as right child
```

## Notes

- Time complexity: O(n)
- This package is a reference implementation with invariants
