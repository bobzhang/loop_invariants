# Closest Pair of Points (Reference)

Find the minimum distance between any two points in the plane using a divide
and conquer approach.

## What it demonstrates

- Divide points by x-coordinate
- Combine step using a y-sorted strip
- Limiting comparisons in the strip

## Pseudocode sketch

```mbt nocheck
solve(points):
  split by x
  d = min(solve(left), solve(right))
  check strip within d of mid line
```

## Example

```mbt check
///|
test "closest pair example" {
  let points : Array[(Double, Double)] = [(0.0, 0.0), (1.0, 0.0), (4.0, 0.0)]
  let (dist, p1, p2) = @closest_pair.closest_pair(points)
  inspect(dist, content="1")
  inspect((p1, p2), content="(0, 1)")
}
```

## Notes

- Time complexity: O(n log n)
- This package is a reference implementation with invariants
