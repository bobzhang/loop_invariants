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

## Example

```mbt check
///|
test "lazy segtree example" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L]
  let st = @lazy_segtree.LazySegTreeSum::new(arr)
  let _ = st.range_add(1, 3, 2L)
  inspect(st.range_sum(0, 3), content="Some(16)")
  inspect(st.point_query(2), content="Some(5)")
}
```

## Notes

- Time complexity: O(log n) per update/query
- This package is a reference implementation with invariants
