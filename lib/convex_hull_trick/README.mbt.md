# Convex Hull Trick (Monotone)

## Overview

This structure maintains lines `y = m*x + b` with **slopes added in increasing
order** and answers **maximum** queries for `x` in **non-decreasing order**.
It supports O(1) amortized insertion and query using a deque.

- **Time**: O(1) amortized per operation
- **Space**: O(n)

## When This Variant Applies

Use this monotone version when:
- Lines are inserted in **increasing slope** order.
- Query `x` values are **non-decreasing**.

If either order is arbitrary, use a Li Chao tree instead.

## Quick Start

```mbt check
///|
test "convex hull trick quick start" {
  let cht = @convex_hull_trick.ConvexHullTrick::new()
  cht.add_line(1L, 0L) // y = x
  cht.add_line(2L, 1L) // y = 2x + 1
  cht.add_line(3L, -1L) // y = 3x - 1
  inspect(cht.query(0L), content="1")
  inspect(cht.query(1L), content="3")
  inspect(cht.query(2L), content="5")
  inspect(cht.query(3L), content="8")
}
```

## Why It Works (Intuition)

Lines with increasing slopes intersect in increasing `x` order. That means the
best line for the next query never comes **before** the best line for the
previous query, so we only move the deque head forward.

## Minimum Queries

To get minimum values instead of maximum values:
- Negate each line `(m, b) -> (-m, -b)` when inserting.
- Negate the query result.
