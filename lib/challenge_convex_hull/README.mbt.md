# Challenge: Convex Hull (Monotone Chain)

Compute the convex hull of planar points in O(n log n).

## Example

```mbt check
///|
test "convex hull example" {
  let pts : Array[@challenge_convex_hull.Point] = [
    @challenge_convex_hull.Point::{ x: 0, y: 0 },
    @challenge_convex_hull.Point::{ x: 2, y: 0 },
    @challenge_convex_hull.Point::{ x: 2, y: 2 },
    @challenge_convex_hull.Point::{ x: 0, y: 2 },
    @challenge_convex_hull.Point::{ x: 1, y: 1 },
  ]
  let hull = @challenge_convex_hull.convex_hull(pts[:])
  inspect(hull.length(), content="4")
}
```
