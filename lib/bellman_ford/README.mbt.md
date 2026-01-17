# Bellman-Ford (Shortest Paths with Negative Edges)

Bellman-Ford computes shortest paths from a single source in a directed,
weighted graph. Unlike Dijkstra, it **allows negative edge weights** and can
**detect negative cycles** (cycles whose total weight is negative).

If a negative cycle is reachable from the source, there is no well-defined
"shortest" path for vertices that can reach that cycle, because you can loop
forever and keep decreasing the path cost.

This package provides two ways to use the algorithm:

- `@bellman_ford.bellman_ford`: a simple wrapper returning distances and a
  negative-cycle flag.
- `@bellman_ford.BellmanFord`: a full solver with `add_edge`, `compute`,
  `get_distance`, and `get_path`.

## Problem statement

Given a directed graph with vertices `0..n-1` and weighted edges
`(u -> v, w)`, find the shortest path distance from a source `s` to every
vertex `v`. If any negative cycle is reachable from `s`, report that as well.

## The core idea: relaxation

A single **relaxation** tries to improve the best-known distance to a vertex:

```
If dist[u] + w < dist[v], then dist[v] = dist[u] + w
```

If we repeatedly relax all edges, shorter and shorter paths are discovered.

## Why V-1 rounds are enough

A *simple* path (one that does not repeat vertices) has at most `V - 1` edges.
Bellman-Ford uses this fact:

- After 1 round, all shortest paths that use at most 1 edge are correct.
- After 2 rounds, all shortest paths with at most 2 edges are correct.
- ...
- After `V - 1` rounds, all shortest paths are correct.

This is the key invariant: **after k rounds, `dist[v]` is the shortest distance
using at most k edges**.

## Detecting negative cycles

After `V - 1` rounds, all simple shortest paths are finalized. If **any** edge
can still relax, then some path can be improved indefinitely, which means a
negative cycle is reachable from the source.

The implementation in this package runs one extra pass to set
`has_negative_cycle`.

## Examples

### Example 1: basic graph (no negative edges)

```mbt check
///|
test "basic graph" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 5),
    (0, 2, 2),
    (2, 1, 1),
    (1, 3, 3),
    (2, 3, 6),
  ]
  let (dist, neg) = @bellman_ford.bellman_ford(4, edges[:], 0)
  inspect(dist, content="[0, 3, 2, 6]")
  inspect(neg, content="false")
}
```

Shortest paths:
- `0 -> 2` costs 2
- `0 -> 2 -> 1` costs 3
- `0 -> 2 -> 1 -> 3` costs 6

### Example 2: negative edge but no negative cycle

```mbt check
///|
test "negative edge without negative cycle" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 4),
    (0, 2, 5),
    (1, 2, -2),
    (2, 3, 3),
  ]
  let (dist, neg) = @bellman_ford.bellman_ford(4, edges[:], 0)
  inspect(dist, content="[0, 4, 2, 5]")
  inspect(neg, content="false")
}
```

Here the path `0 -> 1 -> 2` (cost 2) beats the direct edge `0 -> 2` (cost 5).

### Example 3: detect a negative cycle

```mbt check
///|
test "negative cycle detection" {
  let edges : Array[(Int, Int, Int)] = [(0, 1, 1), (1, 2, -2), (2, 1, -2)]
  let (_dist, neg) = @bellman_ford.bellman_ford(3, edges[:], 0)
  inspect(neg, content="true")
}
```

The cycle `1 -> 2 -> 1` has total weight `-4`, so there is no finite shortest
path to vertices that can reach it.

### Example 4: path reconstruction with the full solver

```mbt check
///|
test "path reconstruction" {
  let bf = @bellman_ford.BellmanFord::new(4)
  bf.add_edge(0, 1, 2L)
  bf.add_edge(1, 2, 2L)
  bf.add_edge(0, 2, 10L)
  bf.add_edge(2, 3, 1L)
  let result = bf.compute(0)
  inspect(result.get_path(3), content="Some([0, 1, 2, 3])")
  inspect(result.get_distance(3), content="Some(5)")
}
```

### Example 5: unreachable vertices

```mbt check
///|
test "unreachable vertices" {
  let bf = @bellman_ford.BellmanFord::new(4)
  bf.add_edge(0, 1, 3L)
  bf.add_edge(2, 3, 1L)
  let result = bf.compute(0)
  inspect(result.get_distance(0), content="Some(0)")
  inspect(result.get_distance(1), content="Some(3)")
  inspect(result.get_distance(2), content="None")
  inspect(result.get_distance(3), content="None")
}
```

## Step-by-step intuition (small walk-through)

Suppose we have edges:

```
0 -> 1 (4)
0 -> 2 (5)
1 -> 2 (-2)
2 -> 3 (3)
```

Initialization:
- `dist[0] = 0`, all others are infinity

Round 1:
- Relax `0 -> 1`: dist[1] = 4
- Relax `0 -> 2`: dist[2] = 5
- Relax `1 -> 2`: dist[2] becomes 2 (better than 5)
- Relax `2 -> 3`: dist[3] becomes 5

Round 2:
- No further improvements, so we can stop early.

This matches the output in Example 2.

## Practical notes and pitfalls

- **Undirected negative edges are dangerous**: a single negative undirected edge
  implies a negative cycle (u -> v -> u). Bellman-Ford will correctly report a
  negative cycle in that case.
- **Only cycles reachable from the source are detected**: the check uses
  `dist[u] < INF`, so a negative cycle in a disconnected component is ignored.
- **Unreachable vertices stay at infinity**: use `get_distance` to see `None`
  for unreachable nodes, or check the large sentinel in the wrapper.
- **Weights should fit in Int64**: the internal solver uses Int64 to reduce the
  risk of overflow on large graphs.
- **Wrapper returns Int distances**: if you need large distances, use
  `@bellman_ford.BellmanFord` directly to keep Int64 results.
- **Early exit is safe**: if one full round produces no relaxation, distances
  are already final and the algorithm can stop early.

## Complexity

- Time: O(V * E)
- Space: O(V)

## When to use Bellman-Ford

Use it when:
- You have negative edge weights, or
- You must detect negative cycles.

If all edges are non-negative, Dijkstra is faster.
