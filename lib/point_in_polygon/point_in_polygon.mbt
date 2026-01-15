// ============================================================================
// POINT IN POLYGON - Ray Casting with Boundary Detection
// ============================================================================
//
// We cast a horizontal ray to the right and count edge crossings. An odd number
// of crossings means the point is inside. Collinear points on edges are treated
// as boundary.
//
// TIME COMPLEXITY: O(n)
// SPACE COMPLEXITY: O(1)

///|
pub(all) struct Point {
  x : Int64
  y : Int64
} derive(Show, Eq)

///|
pub enum Location {
  Inside
  Outside
  Boundary
} derive(Show, Eq)

///|
fn cross(a : Point, b : Point, c : Point) -> Int64 {
  (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
}

///|
fn on_segment(a : Point, b : Point, p : Point) -> Bool {
  let min_x = if a.x < b.x { a.x } else { b.x }
  let max_x = if a.x > b.x { a.x } else { b.x }
  let min_y = if a.y < b.y { a.y } else { b.y }
  let max_y = if a.y > b.y { a.y } else { b.y }
  p.x >= min_x && p.x <= max_x && p.y >= min_y && p.y <= max_y
}

///|
/// Determine whether point p lies inside, outside, or on the boundary.
pub fn point_in_polygon(poly : Array[Point], p : Point) -> Location {
  let n = poly.length()
  if n < 3 {
    return Outside
  }
  let inside = for i = 0, inside = false; i < n; {
    let a = poly[i]
    let b = poly[(i + 1) % n]
    let c = cross(a, b, p)
    if c == 0 && on_segment(a, b, p) {
      return Boundary
    }
    let above_a = a.y > p.y
    let above_b = b.y > p.y
    let new_inside = if above_a != above_b {
      let lhs = (b.x - a.x) * (p.y - a.y)
      let rhs = (p.x - a.x) * (b.y - a.y)
      let intersects = if b.y > a.y { lhs > rhs } else { lhs < rhs }
      if intersects {
        not(inside)
      } else {
        inside
      }
    } else {
      inside
    }
    continue i + 1, new_inside
  } else {
    inside
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (ray casting):
      #|inside reflects the parity of ray crossings among edges poly[0..i).
      #|Boundary points are detected immediately via collinearity checks.
      #|MAINTENANCE:
      #|For edge (i, i+1), toggle inside when the ray crosses it to the right.
      #|TERMINATION:
      #|At i = n, inside is true iff the total crossing count is odd.
    ),
  }
  if inside {
    Inside
  } else {
    Outside
  }
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "point in polygon square" {
  let poly : Array[Point] = [
    { x: 0L, y: 0L },
    { x: 4L, y: 0L },
    { x: 4L, y: 4L },
    { x: 0L, y: 4L },
  ]
  inspect(point_in_polygon(poly, { x: 2L, y: 2L }), content="Inside")
  inspect(point_in_polygon(poly, { x: 5L, y: 2L }), content="Outside")
  inspect(point_in_polygon(poly, { x: 4L, y: 2L }), content="Boundary")
}
