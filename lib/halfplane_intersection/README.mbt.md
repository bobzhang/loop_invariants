# Half-Plane Intersection

## Overview

Given a set of half-planes (directed lines, keeping the **left side**), this
package computes their intersection polygon using the classic **deque
algorithm**.

- **Time**: O(n log n)
- **Space**: O(n)

## Half-Plane Representation

A half-plane is defined by a directed line **a → b**. The feasible region is
all points to the left of that direction.

```
HalfPlane::from_points(a, b)
```

## Algorithm Sketch

1. Sort half-planes by direction (polar angle).
2. Remove redundant parallel lines, keeping the most restrictive.
3. Maintain a deque of lines whose intersection is non-empty.
4. Trim from front/back when a new line invalidates the current intersection.
5. Intersect consecutive lines to build the polygon.

If the intersection is **empty** or **unbounded**, the function returns `None`.

## API

- `halfplane_intersection(planes)` returns `Some(polygon)` or `None`.
- The polygon is returned in CCW order.

## Example Usage

```mbt check
///|
test "halfplane square" {
  let planes : Array[@halfplane_intersection.HalfPlane] = [
    @halfplane_intersection.HalfPlane::from_points({ x: 0.0, y: 0.0 }, {
      x: 1.0,
      y: 0.0,
    }),
    @halfplane_intersection.HalfPlane::from_points({ x: 1.0, y: 0.0 }, {
      x: 1.0,
      y: 1.0,
    }),
    @halfplane_intersection.HalfPlane::from_points({ x: 1.0, y: 1.0 }, {
      x: 0.0,
      y: 1.0,
    }),
    @halfplane_intersection.HalfPlane::from_points({ x: 0.0, y: 1.0 }, {
      x: 0.0,
      y: 0.0,
    }),
  ]
  let poly = @halfplane_intersection.halfplane_intersection(planes).unwrap()
  inspect(poly.length(), content="4")
}
```

## Requirements

- The intersection should be **bounded** to get a polygon.
- Input lines should not be degenerate (zero direction vector).
