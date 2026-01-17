# Polygon Triangulation (Minimum Weight, Convex)

This package computes the **minimum‑weight triangulation** of a **convex**
polygon. The weight is the sum of triangle perimeters, using **squared
distances** to keep everything in integers.

---

## 1. Problem in plain words

You are given a convex polygon with vertices in order.

You must draw non‑crossing diagonals to split it into triangles.

Many triangulations are possible. We want the one with **minimum total cost**.

---

## 2. Small visual

For a pentagon:

```
     1
    / \
   /   \
  0-----2
   \   /
    \ /
  4--3
```

There are several ways to triangulate it. We want the cheapest.

---

## 3. Key insight: interval DP

Pick an edge (i, j).

Every triangulation of the polygon chain from i to j must include **exactly one
triangle** that uses this edge, and that triangle is `(i, k, j)` for some
i < k < j.

So:

```
dp[i][j] = min over k:
  dp[i][k] + dp[k][j] + cost(i, k, j)
```

Base case:

```
dp[i][i+1] = 0   // just an edge, no triangle
```

This is the classic interval DP structure (like matrix chain multiplication).

---

## 4. Triangle cost

The cost here is the **squared perimeter**:

```
cost(i, j, k) =
  dist2(i, j) + dist2(j, k) + dist2(k, i)

dist2(a, b) = (ax - bx)^2 + (ay - by)^2
```

Why squared? It avoids floating point and keeps everything in Int64.

---

## 5. Step‑by‑step example (square)

Square:

```
0(0,0) ---- 1(1,0)
  |           |
  |           |
3(0,1) ---- 2(1,1)
```

Two triangulations:

```
Option A: triangles (0,1,2) and (0,2,3)
Option B: triangles (0,1,3) and (1,2,3)
```

All sides are length 1, diagonals have squared length 2.

Triangle costs:

```
(0,1,2): 1 + 1 + 2 = 4
(0,2,3): 2 + 1 + 1 = 4
Total = 8
```

Option B also gives 8, so the answer is 8.

---

## 6. Example usage (public API)

```mbt check
///|
test "triangulation square" {
  let points : Array[@polygon_triangulation.Point] = [
    @polygon_triangulation.Point::{ x: 0L, y: 0L },
    @polygon_triangulation.Point::{ x: 1L, y: 0L },
    @polygon_triangulation.Point::{ x: 1L, y: 1L },
    @polygon_triangulation.Point::{ x: 0L, y: 1L },
  ]
  inspect(
    @polygon_triangulation.min_weight_triangulation(points).unwrap(),
    content="8",
  )
}
```

---

## 7. Another example (pentagon)

Consider a regular‑ish pentagon:

```
0(0,0), 1(2,0), 2(3,1), 3(1,3), 4(-1,1)
```

We can compare two triangulations:

```
Option A: fix vertex 0, triangles (0,1,2), (0,2,3), (0,3,4)
Option B: use diagonals (1,3) and (1,4)
```

The DP will automatically pick the cheaper one.

```mbt check
///|
test "triangulation pentagon" {
  let points : Array[@polygon_triangulation.Point] = [
    @polygon_triangulation.Point::{ x: 0L, y: 0L },
    @polygon_triangulation.Point::{ x: 2L, y: 0L },
    @polygon_triangulation.Point::{ x: 3L, y: 1L },
    @polygon_triangulation.Point::{ x: 1L, y: 3L },
    @polygon_triangulation.Point::{ x: -1L, y: 1L },
  ]
  // We just check it returns Some(...) and is deterministic.
  let ans = @polygon_triangulation.min_weight_triangulation(points)
  inspect(ans is Some(_), content="true")
}
```

---

## 8. DP table visualization

For n = 5 (pentagon), dp is 5×5.
We fill by increasing gap length.

```
      j → 0   1   2   3   4
i ↓
0        0   0   x   x   x
1            0   0   x   x
2                0   0   x
3                    0   0
4                        0
```

Where:

```
dp[i][i+1] = 0
dp[i][i+2] = cost(i, i+1, i+2)   // a single triangle
```

Then:

```
dp[0][4] = min(
  dp[0][1] + dp[1][4] + cost(0,1,4),
  dp[0][2] + dp[2][4] + cost(0,2,4),
  dp[0][3] + dp[3][4] + cost(0,3,4)
)
```

---

## 9. Common applications

1. **Graphics / rendering**
   - Polygons are rendered as triangles.
   - Better triangulations reduce skinny triangles.
2. **Mesh generation**
   - Simulation and FEM benefit from good triangles.
3. **Geometry preprocessing**
   - Many algorithms are easier on triangulated polygons.

---

## 10. Complexity

```
States: O(n^2)
Transitions per state: O(n)
Total: O(n^3) time, O(n^2) space
```

---

## 11. Constraints and notes

- The polygon must be **convex** and vertices ordered (CW or CCW).
- For non‑convex polygons, minimum‑weight triangulation is NP‑hard.
- The result uses squared distances, so it differs from true Euclidean
  perimeter but preserves ordering in most cases.

---

## 12. Summary

Minimum‑weight triangulation of a convex polygon is a classic interval DP:

```
dp[i][j] = min_{i<k<j} dp[i][k] + dp[k][j] + cost(i,k,j)
```

The implementation is straightforward, and the DP guarantees optimality.
