# Rotating Calipers Diameter

## Overview

The **diameter** of a convex polygon is the maximum distance between any two of
its vertices. Rotating calipers finds this in linear time by tracking antipodal
pairs.

- **Time**: O(n)
- **Space**: O(1)

## Key Idea

For each edge `(i, i+1)`, the farthest vertex in terms of area
(antipodal point) only moves forward as `i` increases. This monotonicity lets us
scan all edges with a single pointer `j`.

## API

- `convex_diameter(points)` returns `{ i, j, dist2 }`.
- `dist2` is the squared distance to avoid floating point.

## Example Usage

```mbt check
///|
test "diameter square" {
  let points : Array[@rotating_calipers_diameter.Point] = [
    @rotating_calipers_diameter.Point::{ x: 0L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 2L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 2L, y: 2L },
    @rotating_calipers_diameter.Point::{ x: 0L, y: 2L },
  ]
  let result = @rotating_calipers_diameter.convex_diameter(points).unwrap()
  inspect(result.dist2, content="8")
}
```

## Requirements

- The input polygon must be **convex** and in **counter‑clockwise** order.
- No duplicate consecutive vertices.
