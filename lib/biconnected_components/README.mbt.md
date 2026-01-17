# Biconnected Components (and Articulation Points)

This package finds **biconnected components** and **articulation points** in an
undirected graph. These concepts are about *robust connectivity*:

- A **biconnected component** (also called a block) is a maximal subgraph where
  removing any single vertex does **not** disconnect the subgraph.
- An **articulation point** (cut vertex) is a vertex whose removal **does**
  disconnect the graph (increases the number of connected components).

These are fundamental tools for network reliability, dependency analysis, and
graph decomposition.

## Problem statement

Given an undirected graph with vertices `0..n-1` and edges `(u, v)`, find:

1. All biconnected components (each reported as a list of edges).
2. All articulation points.

## Key ideas (DFS + low-link)

We run a DFS and assign each vertex a discovery time:

- `disc[u]`: when we first visit `u`
- `low[u]`: the smallest discovery time reachable from `u`'s subtree using
  at most one back edge

### Why low-link matters

For a tree edge `(u, v)` in the DFS tree:

- If `low[v] >= disc[u]`, then `v`'s subtree cannot reach any ancestor of `u`.
- That means removing `u` would disconnect `v`'s subtree.
- So `u` is an articulation point (with a special root rule below).

### Root rule

The DFS root is an articulation point **only if it has 2 or more DFS children**.

### Extracting components

We push each traversed edge onto a stack. When we see `low[v] >= disc[u]`,
we pop edges until we pop `(u, v)`. Those popped edges form one biconnected
component.

## What the function returns

The function:

```
@biconnected_components.biconnected_components(n, edges)
```

returns a `BiconnectedResult` with:

- `components : Array[Array[(Int, Int)]]` (each component is a list of edges)
- `articulation_points : Array[Int]`

Edges are given in DFS order; the component order is not guaranteed.

## Examples

### Example 1: triangle with a tail

```
0---1---3
 \ /
  2
```

Here, vertex `1` is an articulation point. The triangle `(0,1,2)` is one
biconnected component, and the bridge `(1,3)` is another.

```mbt check
///|
test "triangle with a tail" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (1, 3)]
  let res = @biconnected_components.biconnected_components(4, edges[:])
  let sizes = res.components.map(c => c.length())
  sizes.sort_by((a, b) => a - b)
  inspect(sizes, content="[1, 3]")
  res.articulation_points.sort_by((a, b) => a - b)
  inspect(res.articulation_points, content="[1]")
}
```

### Example 2: a simple cycle (no articulation points)

```
0---1
|   |
3---2
```

The whole cycle is one biconnected component, and there are no articulation
points.

```mbt check
///|
test "cycle has one component" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3), (3, 0)]
  let res = @biconnected_components.biconnected_components(4, edges[:])
  let sizes = res.components.map(c => c.length())
  inspect(sizes, content="[4]")
  inspect(res.articulation_points, content="[]")
}
```

### Example 3: two triangles sharing a vertex

```
  2
 / \
0---1---3
     \ /
      4
```

Vertex `1` is the only articulation point. There are two biconnected
components, each a triangle.

```mbt check
///|
test "two triangles share a vertex" {
  let edges : Array[(Int, Int)] = [
    (0, 1),
    (1, 2),
    (2, 0),
    (1, 3),
    (3, 4),
    (4, 1),
  ]
  let res = @biconnected_components.biconnected_components(5, edges[:])
  let sizes = res.components.map(c => c.length())
  sizes.sort_by((a, b) => a - b)
  inspect(sizes, content="[3, 3]")
  res.articulation_points.sort_by((a, b) => a - b)
  inspect(res.articulation_points, content="[1]")
}
```

### Example 4: disconnected graph

Disconnected components are handled independently; isolated vertices do not
appear in any biconnected component.

```mbt check
///|
test "disconnected graph" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (3, 4)]
  let res = @biconnected_components.biconnected_components(6, edges[:])
  let sizes = res.components.map(c => c.length())
  sizes.sort_by((a, b) => a - b)
  inspect(sizes, content="[1, 1, 1]")
  res.articulation_points.sort_by((a, b) => a - b)
  inspect(res.articulation_points, content="[1]")
}
```

## Practical notes and pitfalls

- This algorithm is for **undirected** graphs. For directed graphs, use SCCs.
- Components are returned as **edges**. If you need vertex sets, collect the
  endpoints of those edges.
- Articulation points are defined by **vertex removal**, not edge removal.
- Bridges are exactly the components of size 1 (a single edge).

## Complexity

- Time: O(V + E)
- Space: O(V + E)

## When to use it

Use biconnected components when you need:

- Critical nodes in a network (single points of failure)
- Robust subgraphs that survive one vertex removal
- Decomposition for graph algorithms that require articulation handling
