# Polygon Triangulation (Minimum Weight)

## Overview

For a **convex polygon**, any triangulation is valid. This package finds the
triangulation with **minimum total weight**, where each triangle's weight is
defined as the **sum of squared edge lengths** (to stay in integers).

- **Time**: O(n^3)
- **Space**: O(n^2)

## Core Idea

Use interval DP: pick a vertex k between i and j as the triangle tip, combine
optimal triangulations of (i, k) and (k, j), plus the triangle cost.

## DP Recurrence

Let `dp[i][j]` be the minimum triangulation cost for the chain from `i` to `j`:

```
dp[i][j] = min_{i<k<j} (dp[i][k] + dp[k][j] + cost(i, k, j))
```

where `cost(i,k,j)` is the squared‑perimeter of triangle `(i,k,j)`.

## API

- `min_weight_triangulation(points)` returns `Some(cost)` or `None` if `n < 3`.

## Example Usage

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

## Requirements

- The polygon must be **convex** and given in **CCW order**.
- Weights are based on squared distances (integer‑safe).
