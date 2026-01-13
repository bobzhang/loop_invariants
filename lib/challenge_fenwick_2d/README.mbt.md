# Challenge: 2D Fenwick Tree

Point updates and rectangle sums in O(log^2 n).

## Core Idea

2D Fenwick trees generalize the 1D structure: each update affects all relevant
rectangles in the implicit binary indexed grid. Rectangle sums are computed
by inclusion-exclusion on prefix sums.

```
sum(r1..r2, c1..c2) =
  pref(r2, c2) - pref(r1, c2) - pref(r2, c1) + pref(r1, c1)
```

## Example

```mbt check
///|
test "fenwick2d example" {
  let fw = @challenge_fenwick_2d.Fenwick2D::new(3, 3)
  fw.add(0, 0, 5)
  fw.add(1, 2, 3)
  inspect(fw.range_sum(0, 0, 3, 3), content="8")
}
```

## Another Example

```mbt check
///|
test "fenwick2d partial sum" {
  let fw = @challenge_fenwick_2d.Fenwick2D::new(4, 4)
  fw.add(1, 1, 2)
  fw.add(2, 3, 4)
  inspect(fw.range_sum(0, 0, 2, 2), content="2")
  inspect(fw.range_sum(0, 0, 4, 4), content="6")
}
```

## Notes

- `range_sum(x1, y1, x2, y2)` uses half-open ranges.
- Time per update/query is O(log^2 n).
