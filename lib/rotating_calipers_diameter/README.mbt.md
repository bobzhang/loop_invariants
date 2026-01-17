# Rotating Calipers Diameter (Convex Polygon)

This package finds the **diameter** of a convex polygon: the farthest pair of
vertices. It returns the two vertex indices and the squared distance.

The algorithm is **rotating calipers**, which runs in **O(n)** time on a convex
polygon in order.

---

## 1. What is the diameter?

Given a convex polygon, the **diameter** is the maximum distance between any
two of its vertices.

```
Square with side 2:
  farthest pair = opposite corners
  distance^2 = 2^2 + 2^2 = 8
```

---

## 2. Why we need something faster than O(n^2)

Brute force checks every pair of vertices:

```
n vertices -> n*(n-1)/2 pairs -> O(n^2)
```

For large polygons, this is slow. Rotating calipers reduces it to **O(n)** by
exploiting convexity.

---

## 3. Key idea: antipodal pairs

For each edge of a convex polygon, there is a **farthest** vertex from that
edge (max area or perpendicular distance). That vertex is called **antipodal**
to the edge.

As you walk around the polygon, the antipodal vertex moves **only forward**.
So a single pointer can track it.

---

## 4. Visual intuition (calipers)

Imagine two parallel lines touching the polygon:

```
   ───────────────   (top caliper)
      /      \
     *        *      <- touching vertices
      \      /
   ───────────────   (bottom caliper)
```

Rotate the calipers along each edge. The farthest vertex only moves forward,
so total movement is O(n).

---

## 5. Step‑by‑step example (square)

Square:

```
3(0,2) ---- 2(2,2)
  |           |
  |           |
0(0,0) ---- 1(2,0)
```

Start with edge 0→1, antipodal vertex is 2.

Track max distance while rotating:

```
edge 0→1, j=2, dist2 = 8
edge 1→2, j=3, dist2 = 8
edge 2→3, j=0, dist2 = 8
edge 3→0, j=1, dist2 = 8
```

Diameter^2 = 8.

---

## 6. Why the antipodal pointer only moves forward

We compare triangle areas (cross products):

```
area(i, i+1, j+1) > area(i, i+1, j)
```

If moving j forward increases the area, we advance j. Otherwise we stop.

As i increases, the farthest point never moves backward, so total steps are
bounded by n.

---

## 7. API overview

From `pkg.generated.mbti`:

```
convex_diameter(points) -> DiameterResult?

DiameterResult {
  i : Int
  j : Int
  dist2 : Int64
}
```

`dist2` is squared distance to avoid floating point.

---

## 8. Example usage (public API)

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

---

## 9. Example: triangle

```
Triangle: (0,0), (4,0), (2,3)
Longest edge is 0↔1 (length 4, dist2 = 16)
```

```mbt check
///|
test "diameter triangle" {
  let points : Array[@rotating_calipers_diameter.Point] = [
    @rotating_calipers_diameter.Point::{ x: 0L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 4L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 2L, y: 3L },
  ]
  let result = @rotating_calipers_diameter.convex_diameter(points).unwrap()
  inspect(result.dist2, content="16")
}
```

---

## 10. Example: rectangle

```
Rectangle 1x3:
points = (0,0), (3,0), (3,1), (0,1)
diagonal^2 = 3^2 + 1^2 = 10
```

```mbt check
///|
test "diameter rectangle" {
  let points : Array[@rotating_calipers_diameter.Point] = [
    @rotating_calipers_diameter.Point::{ x: 0L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 3L, y: 0L },
    @rotating_calipers_diameter.Point::{ x: 3L, y: 1L },
    @rotating_calipers_diameter.Point::{ x: 0L, y: 1L },
  ]
  let result = @rotating_calipers_diameter.convex_diameter(points).unwrap()
  inspect(result.dist2, content="10")
}
```

---

## 11. Complexity

```
O(n) on the convex polygon
O(n log n) if you must compute the convex hull first
```

The convex hull step usually dominates for arbitrary point sets.

---

## 12. Common applications

1. **Farthest pair of points** in a set
2. **Minimum enclosing circle** (diameter gives a lower bound)
3. **Bounding box / calipers family** (rotating calipers used for width, area)

---

## 13. Beginner checklist

1. Input polygon must be **convex**.
2. Vertices must be in **counter‑clockwise order**.
3. No duplicate consecutive vertices.
4. Use squared distances to avoid floating point.

---

## 14. Summary

Rotating calipers leverages convexity:

- only one antipodal pointer moves forward,
- total work is linear,
- gives the diameter efficiently and deterministically.
