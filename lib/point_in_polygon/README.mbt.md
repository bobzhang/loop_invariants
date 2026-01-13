# Point in Polygon

## Overview

This package classifies a point as **Inside**, **Outside**, or **Boundary** of a
polygon using the classic **ray casting** method with collinearity checks.

- **Time**: O(n)
- **Space**: O(1)

## Core Idea

- Cast a ray and **count edge crossings**; odd means inside, even means outside.
- Treat **collinear edges** as boundary hits before toggling.
- Use consistent half-open rules to avoid double-counting vertices.

## Algorithm

Cast a horizontal ray to the right from the query point:

- Each edge crossing toggles the inside/outside state.
- If the point lies exactly on an edge, return `Boundary`.

## API

- `point_in_polygon(poly, p)` returns `Inside | Outside | Boundary`.

## Example Usage

```mbt check
///|
test "point in polygon square" {
  let poly : Array[@point_in_polygon.Point] = [
    @point_in_polygon.Point::{ x: 0L, y: 0L },
    @point_in_polygon.Point::{ x: 4L, y: 0L },
    @point_in_polygon.Point::{ x: 4L, y: 4L },
    @point_in_polygon.Point::{ x: 0L, y: 4L },
  ]
  inspect(
    @point_in_polygon.point_in_polygon(poly, @point_in_polygon.Point::{
      x: 2L,
      y: 2L,
    }),
    content="Inside",
  )
  inspect(
    @point_in_polygon.point_in_polygon(poly, @point_in_polygon.Point::{
      x: 5L,
      y: 2L,
    }),
    content="Outside",
  )
}
```
