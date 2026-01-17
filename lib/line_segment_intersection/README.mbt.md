# Line Segment Intersection (Orientation Test)

## What It Solves

Determine whether two **line segments** intersect, including:

- proper crossings
- touching at endpoints
- collinear overlap
- collinear disjoint segments

This implementation uses **cross‑product orientation tests** and is O(1).

## The Orientation Test

Given three points **a, b, c**, the cross product:

```
cross(a, b, c) = (b - a) x (c - a)
```

- `> 0` : c is left of line a→b (counter‑clockwise)
- `< 0` : c is right of line a→b (clockwise)
- `= 0` : a, b, c are collinear

## Visual: Orientation

```
        c (left of a→b)
       /
      /
 a ---→ b
      \
       \
        d (right of a→b)
```

If two points are on opposite sides of a line, the segment “straddles” it.

## General Intersection Rule

Two segments (a,b) and (c,d) intersect if:

```
1) c and d are on opposite sides of line ab, AND
2) a and b are on opposite sides of line cd
```

These are tested by checking sign differences of four cross products.

## Collinear Special Case

If cross products are zero, the points are collinear. Then you must check
**bounding box overlap**.

```
on_segment(a, b, p) means p is inside the box of segment ab
```

## Visual Cases

```
Case 1: Proper crossing

  c
  │
  │
 a┼───b
  │
  │
  d

Case 2: Endpoint touch

  c
  │
 a┴───b

Case 3: Collinear overlap

 a──────b
     c──────d

Case 4: Collinear disjoint

 a──b     c──d
```

All four cases are handled by the same orientation + on‑segment checks.

## Algorithm (Readable)

```
segments_intersect(a,b,c,d):
  o1 = cross(a,b,c)
  o2 = cross(a,b,d)
  o3 = cross(c,d,a)
  o4 = cross(c,d,b)

  if o1 == 0 and on_segment(a,b,c) -> true
  if o2 == 0 and on_segment(a,b,d) -> true
  if o3 == 0 and on_segment(c,d,a) -> true
  if o4 == 0 and on_segment(c,d,b) -> true

  return (o1 and o2 have opposite signs) AND
         (o3 and o4 have opposite signs)
```

## Worked Example (Crossing)

Segments:

```
(0,0) -> (4,4)
(0,4) -> (4,0)
```

Cross products:

```
o1 = cross(a,b,c) = +16
 o2 = cross(a,b,d) = -16
 o3 = cross(c,d,a) = -16
 o4 = cross(c,d,b) = +16

Opposite signs in both pairs => intersect
```

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

## Integer vs Floating Point

This implementation uses **Int64**, which avoids floating‑point precision
issues. If you use floating points, add an epsilon tolerance when checking
collinearity.

## Common Pitfalls

- Bounding box check must be **inclusive** (<=, not <)
- Collinear segments need special handling
- Overflow in cross product: use Int64 for safety

## Complexity

| Operation | Time | Space |
|----------|------|-------|
| Orientation | O(1) | O(1) |
| Intersection test | O(1) | O(1) |

## Related Algorithms

- Line intersection point computation
- Bentley–Ottmann (all segment intersections)
- Polygon intersection tests
