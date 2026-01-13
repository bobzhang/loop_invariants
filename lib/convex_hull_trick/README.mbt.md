# Convex Hull Trick (Monotone)

## Overview

This structure maintains lines `y = m*x + b` with **slopes added in increasing
order** and answers **maximum** queries for `x` in **non-decreasing order**.
It supports O(1) amortized insertion and query using a deque.

- **Time**: O(1) amortized per operation
- **Space**: O(n)

## Example

```mbt check
///|
test "convex hull trick example" {
  let cht = @convex_hull_trick.ConvexHullTrick::new()
  cht.add_line(1L, 0L)
  cht.add_line(2L, 1L)
  cht.add_line(3L, -1L)
  inspect(cht.query(2L), content="5")
}
```
