# Eulerian Path and Circuit

## Overview

An **Eulerian path** visits every edge exactly once.
An **Eulerian circuit** is an Eulerian path that starts and ends at the same
vertex.

This package implements **Hierholzer's algorithm** for both directed and
undirected graphs.

- **Time**: O(V + E)
- **Space**: O(V + E)

## Existence Conditions

### Directed Graph
An Eulerian path exists iff:

1. At most one vertex has `out = in + 1` (start)
2. At most one vertex has `in = out + 1` (end)
3. All other vertices have `in = out`
4. All vertices with nonzero degree are connected in the **underlying
   undirected** graph

### Undirected Graph
An Eulerian path exists iff:

1. Exactly 0 or 2 vertices have odd degree
2. All vertices with nonzero degree are connected

## Hierholzer's Algorithm

```
Start from a valid start vertex.
Walk unused edges until stuck, then backtrack.
The backtracking order gives the Eulerian path in reverse.
```

Key invariant:
- The stack is always a valid trail using unused edges.
- When a vertex runs out of unused edges, it is finalized into the path.

## Example Usage

```mbt check
///|
test "directed eulerian path" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (0, 2)]
  let path = @eulerian_path.eulerian_path_directed(3, edges[:]).unwrap()
  inspect(path.length(), content="5")
}
```

```mbt check
///|
test "undirected eulerian circuit" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0)]
  let path = @eulerian_path.eulerian_path_undirected(3, edges[:]).unwrap()
  inspect(path.length(), content="4")
}
```

## Why the Degree Rules Matter

For directed graphs:

```
Each time we enter a vertex, we also leave it (in = out)
except possibly the start (one extra outgoing) and end (one extra incoming).
```

For undirected graphs:

```
Every time we pass through a vertex, we use 2 incident edges.
So only 0 or 2 vertices can have odd degree.
```

## Applications

- Finding Euler tours in graphs
- DNA assembly (De Bruijn graphs)
- Routing problems and circuit tracing
- Puzzle generation (draw each edge exactly once)
