# Segment Tree (Reference)

Balanced tree over array intervals supporting fast range queries and updates.

## What it demonstrates

- Building a tree over ranges
- Querying segments that intersect a range
- Variants: sum, min/max, lazy propagation, 2D tree

## Pseudocode sketch

```mbt nocheck
build(node, l, r)
query(node, l, r, ql, qr)
update(node, l, r, idx, value)
```

## Example

```mbt check
///|
test "segment tree example" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L]
  let st = @segment_tree.SegmentTree::new(arr)
  inspect(st.query(1, 3), content="9")
  st.update(2, 10)
  inspect(st.query(1, 3), content="16")
}
```

## Notes

- Time complexity: O(log n) per query/update
- This package is a reference implementation with invariants
- For challenge-style APIs, see `lib/challenge_persistent_segment_tree_*`
