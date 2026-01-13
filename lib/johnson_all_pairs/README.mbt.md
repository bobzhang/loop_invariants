# Johnson's All-Pairs Shortest Paths

## Overview

Johnson's algorithm computes shortest paths between **all pairs** in a directed
weighted graph. It supports **negative weights** as long as there is **no
negative cycle**.

The key trick is to reweight every edge so that all weights become non-negative,
then run Dijkstra from every source.

- **Time**: O(V * E + V * E log V)
- **Space**: O(V + E)

## Core Idea

Use Bellman-Ford once to compute potentials that reweight edges to
non-negative values. Then run Dijkstra from each source and un-reweight
the results.

## How It Works

1. Add a super-source `s` with zero-weight edges to all vertices.
2. Run Bellman-Ford from `s` to compute potentials `h[v]`.
3. Reweight each edge `u -> v` as `w'(u,v) = w(u,v) + h[u] - h[v]`.
4. Run Dijkstra from every source on the reweighted graph.
5. Recover original distances: `dist(u,v) = dist'(u,v) - h[u] + h[v]`.

If Bellman-Ford detects a negative cycle, the algorithm returns `None`.

## API

- `johnson_all_pairs(n, edges)`
  - Returns `Some(dist)` where `dist[u][v]` is the shortest distance from `u` to
    `v`.
  - Returns `None` if a negative cycle exists.
  - Unreachable pairs use a large sentinel value `4611686018427387903`.

## Example Usage

```mbt check
///|
test "johnson basic" {
  let edges : Array[(Int, Int, Int64)] = [
    (0, 1, 1L),
    (0, 2, 4L),
    (1, 2, -2L),
    (2, 3, 2L),
    (1, 3, 5L),
  ]
  let dist = @johnson_all_pairs.johnson_all_pairs(4, edges[:]).unwrap()
  inspect(dist[0], content="[0, 1, -1, 1]")
}
```

```mbt check
///|
test "johnson negative cycle" {
  let edges : Array[(Int, Int, Int64)] = [(0, 1, 1L), (1, 2, -2L), (2, 1, -2L)]
  inspect(@johnson_all_pairs.johnson_all_pairs(3, edges[:]), content="None")
}
```

## When To Use

- Sparse graphs with negative weights but **no negative cycles**.
- You need all-pairs shortest paths and `n` is large enough that Floyd-Warshall
  (O(V^3)) is too slow.
