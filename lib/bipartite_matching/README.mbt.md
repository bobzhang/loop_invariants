# Bipartite Matching (Maximum Matching)

A **bipartite graph** has two disjoint vertex sets: **left** and **right**.
Edges only go between the sets. A **matching** is a set of edges where no
vertex appears more than once.

This package computes a **maximum matching**: the largest possible number of
non-conflicting pairs.

## Problem statement

Given:

- `n_left` left vertices labeled `0..n_left-1`
- `n_right` right vertices labeled `0..n_right-1`
- a list of edges `(u, v)` with `u` on the left and `v` on the right

Find a maximum-size set of pairs `(u, v)` where no left or right vertex is
used twice.

## The key idea: augmenting paths

An **augmenting path** is a path that alternates:

- unmatched edge
- matched edge
- unmatched edge
- ...

and starts at an unmatched left vertex and ends at an unmatched right vertex.
Flipping the matched/unmatched status of every edge on that path increases the
matching size by 1.

If no augmenting path exists, the matching is maximum.

## Algorithms

Two algorithms are provided:

- **Hungarian (Kuhn's)**: O(V * E) - Simple DFS-based augmentation
- **Hopcroft-Karp**: O(E * sqrt(V)) - Faster for large graphs

## Public API

```
// Build a bipartite graph
let graph = BipartiteGraph::new(n_left, n_right)
graph.add_edge(u, v)

// Choose algorithm and compute
let matcher = graph.hungarian()      // or graph.hopcroft_karp()
let size = matcher.max_matching()    // returns matching size
let pairs = matcher.get_matching()   // returns Array[(Int, Int)]

// Minimum vertex cover (HopcroftKarp only; runs max_matching internally)
let (left_cover, right_cover) = matcher.min_vertex_cover()
```

## Examples

### Example 1: small matching

```mbt check
///|
test "small matching" {
  let graph = @bipartite_matching.BipartiteGraph::new(2, 2)
  graph.add_edge(0, 0)
  graph.add_edge(0, 1)
  graph.add_edge(1, 1)
  let matcher = graph.hungarian()
  inspect(matcher.max_matching(), content="2")
}
```

### Example 2: more left vertices than right

```mbt check
///|
test "unbalanced sets" {
  let graph = @bipartite_matching.BipartiteGraph::new(4, 2)
  graph.add_edge(0, 0)
  graph.add_edge(1, 0)
  graph.add_edge(2, 1)
  graph.add_edge(3, 1)
  let matcher = graph.hopcroft_karp()
  inspect(matcher.max_matching(), content="2")
}
```

Only two right vertices exist, so the maximum matching size is 2.

### Example 3: assignment style

Workers on the left, jobs on the right. An edge means a worker can do a job.

```mbt check
///|
test "assignment example" {
  let graph = @bipartite_matching.BipartiteGraph::new(3, 3)
  graph.add_edge(0, 0)
  graph.add_edge(0, 2)
  graph.add_edge(1, 0)
  graph.add_edge(1, 1)
  graph.add_edge(2, 1)
  let matcher = graph.hungarian()
  inspect(matcher.max_matching(), content="3")
}
```

## Practical notes and pitfalls

- Edges must point from left to right; `(u, v)` is invalid if `u` or `v` is out
  of range.
- Duplicate edges are allowed but may slow down DFS.
- The order of pairs in the result depends on DFS order; sort if you need a
  stable presentation.

## Complexity

- Time: O(V * E)
- Space: O(V + E)

`V = n_left + n_right` and `E = edges.length()`.

## When to use it

Use bipartite matching when you need:

- Assignments (workers to jobs, students to courses)
- Pairing tasks without conflicts
- Maximum compatibility matches

If the graph is very large, Hopcroft-Karp is faster, but the core idea is the
same.
