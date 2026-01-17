# Cartesian Tree

A Cartesian tree turns an array into a binary tree that preserves both:

1. **In-order order** (left-to-right traversal gives the original array), and
2. **Heap order** (the minimum value sits above larger values).

This combination makes it a powerful tool for **range minimum queries (RMQ)**.

## Problem statement

Given an array `arr`, we want to answer queries like:

```
min(arr[l..=r])
```

efficiently after preprocessing.

## Key properties

For a *min-heap* Cartesian tree:

- The root is the **minimum** element in the array.
- The left subtree contains exactly the elements to the left of the minimum.
- The right subtree contains exactly the elements to the right of the minimum.
- An in-order traversal returns the original array order.

These properties uniquely determine the tree structure.

## How to build it in O(n)

We use a **monotonic stack** of indices:

1. Scan the array left to right.
2. While the stack top is larger than the current value, pop it.
3. The last popped node becomes the **left child** of the current node.
4. The current node becomes the **right child** of the new stack top (if any).
5. Push the current index.

Each index is pushed and popped at most once, so the total work is O(n).

## RMQ via LCA

The minimum in a range `[l, r]` is the **lowest common ancestor (LCA)** of the
nodes at indices `l` and `r`. This holds because:

- The heap property guarantees that every ancestor has the smallest value in
  its subtree.
- The in-order property guarantees that the subtree of the LCA corresponds
  exactly to the interval `[l, r]`.

So RMQ becomes:

```
RMQ(l, r) = value at LCA(node[l], node[r])
```

## Public API

This package exposes:

```
@cartesian_tree.range_min(arr, l, r)
```

It returns `Some(min)` if the range is valid, otherwise `None`.

## Examples

### Example 1: basic RMQ

```mbt check
///|
test "basic rmq" {
  let arr : Array[Int64] = [3L, 2L, 6L, 1L, 9L]
  inspect(@cartesian_tree.range_min(arr[:], 1, 3), content="Some(1)")
  inspect(@cartesian_tree.range_min(arr[:], 0, 2), content="Some(2)")
}
```

### Example 2: duplicates and tie-breaking

This implementation only pops **strictly larger** values. That means equal
values keep their original order, and the leftmost minimum becomes higher in
the tree.

```mbt check
///|
test "duplicates" {
  let arr : Array[Int64] = [5L, 5L, 2L, 5L]
  inspect(@cartesian_tree.range_min(arr[:], 0, 1), content="Some(5)")
  inspect(@cartesian_tree.range_min(arr[:], 0, 2), content="Some(2)")
}
```

### Example 3: ascending and descending arrays

```mbt check
///|
test "ascending and descending" {
  let asc : Array[Int64] = [1L, 2L, 3L, 4L]
  let desc : Array[Int64] = [4L, 3L, 2L, 1L]
  inspect(@cartesian_tree.range_min(asc[:], 1, 3), content="Some(2)")
  inspect(@cartesian_tree.range_min(desc[:], 1, 3), content="Some(1)")
}
```

### Example 4: invalid ranges

```mbt check
///|
test "invalid range" {
  let arr : Array[Int64] = [3L, 2L, 6L]
  inspect(@cartesian_tree.range_min(arr[:], -1, 1), content="None")
  inspect(@cartesian_tree.range_min(arr[:], 2, 1), content="None")
  inspect(@cartesian_tree.range_min(arr[:], 0, 10), content="None")
}
```

## Applications

- Range minimum queries
- Nearest smaller elements
- Largest rectangle in a histogram
- Treaps (Cartesian tree by key order and random priority)

## Complexity

- Build: O(n)
- LCA preprocessing: O(n log n) with binary lifting
- Query: O(log n) for the LCA (O(1) with Euler tour + RMQ)

## Practical notes and pitfalls

- If values can repeat, always define a tie-breaking rule. This implementation
  keeps the **leftmost** minimum higher in the tree.
- The range is **inclusive**: `[l, r]`.
- If you only need the tree structure, you can reuse the stack build step
  without LCA preprocessing.

## When to use it

Use a Cartesian tree when you need fast RMQ and want a tree representation that
preserves array order.
