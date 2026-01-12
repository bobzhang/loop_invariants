# Convex Hull (Reference)

Compute the convex hull of points in the plane, usually with the monotone
chain algorithm.

## What it demonstrates

- Sorting by x/y
- Building lower and upper hulls with cross products
- Removing non-left turns

## Pseudocode sketch

```mbt nocheck
sort points
for p in points:
  while hull makes non-left turn: pop
  push p
```

## Example

```mbt check
///|
test "convex hull example" {
  let pts : Array[@convex_hull.Point] = [
    { x: 0, y: 0 },
    { x: 2, y: 0 },
    { x: 2, y: 2 },
    { x: 0, y: 2 },
    { x: 1, y: 1 },
  ]
  let hull = @convex_hull.convex_hull_monotone(pts)
  inspect(hull.length(), content="4")
}
```

## Notes

- Time complexity: O(n log n)
- This package is a reference implementation with invariants
