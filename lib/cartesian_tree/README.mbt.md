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

## Example

```mbt check
///|
test "cartesian tree rmq example" {
  let arr : Array[Int64] = [3L, 2L, 6L, 1L, 9L]
  inspect(@cartesian_tree.range_min(arr[:], 1, 3), content="Some(1)")
  inspect(@cartesian_tree.range_min(arr[:], 0, 2), content="Some(2)")
}
```

## Notes

- Time complexity: O(n)
- This package is a reference implementation with invariants
