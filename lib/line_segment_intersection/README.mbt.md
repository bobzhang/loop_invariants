# Line Segment Intersection

## Overview

This package determines whether two line segments intersect using orientation
(cross-product) tests and careful handling of collinear cases.

- **Time**: O(1)
- **Space**: O(1)

## Geometric Idea

For segments `(a,b)` and `(c,d)`:

- If the orientations `cross(a,b,c)` and `cross(a,b,d)` have opposite signs,
  then `c` and `d` are on different sides of line `ab`.
- Likewise for `cross(c,d,a)` and `cross(c,d,b)`.
- Collinear cases are handled by checking whether the point lies within the
  bounding box of the segment.

## API

- `segments_intersect(a, b, c, d)` returns Bool.

## Example Usage

```mbt check
///|
test "segment intersection crossing" {
  let a = @line_segment_intersection.Point::{ x: 0L, y: 0L }
  let b = @line_segment_intersection.Point::{ x: 4L, y: 4L }
  let c = @line_segment_intersection.Point::{ x: 0L, y: 4L }
  let d = @line_segment_intersection.Point::{ x: 4L, y: 0L }
  inspect(
    @line_segment_intersection.segments_intersect(a, b, c, d),
    content="true",
  )
}
```

```mbt check
///|
test "segment intersection touch" {
  let a = @line_segment_intersection.Point::{ x: 0L, y: 0L }
  let b = @line_segment_intersection.Point::{ x: 2L, y: 2L }
  let c = @line_segment_intersection.Point::{ x: 2L, y: 2L }
  let d = @line_segment_intersection.Point::{ x: 3L, y: 0L }
  inspect(
    @line_segment_intersection.segments_intersect(a, b, c, d),
    content="true",
  )
}
```

```mbt check
///|
test "segment intersection disjoint" {
  let a = @line_segment_intersection.Point::{ x: 0L, y: 0L }
  let b = @line_segment_intersection.Point::{ x: 1L, y: 1L }
  let c = @line_segment_intersection.Point::{ x: 2L, y: 2L }
  let d = @line_segment_intersection.Point::{ x: 3L, y: 3L }
  inspect(
    @line_segment_intersection.segments_intersect(a, b, c, d),
    content="false",
  )
}
```
