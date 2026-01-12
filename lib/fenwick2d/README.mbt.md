# 2D Fenwick Tree (Reference)

Support point updates and 2D prefix/range sums in O(log^2 n) time.

## What it demonstrates

- Extending lowbit traversal to two dimensions
- Inclusion-exclusion for rectangle queries
- Careful index handling

## Pseudocode sketch

```mbt nocheck
update(x, y, delta):
  for i = x..: for j = y..: tree[i][j] += delta
prefix(x, y):
  for i = x..: for j = y..: sum += tree[i][j]
```

## Example

```mbt check
///|
test "fenwick2d example" {
  let fw = @fenwick2d.Fenwick2D::new(3, 3)
  fw.update(1, 1, 5)
  fw.update(2, 3, 2)
  inspect(fw.range_sum(1, 1, 3, 3), content="7")
}
```

## Notes

- Time complexity: O(log^2 n)
- This package is a reference implementation with invariants
