# Bellman-Ford (Shortest Paths with Negative Edges)

## Problem

Find the shortest path from a source to all vertices **even if some edges are negative**.
Also detect **negative cycles** (paths that can reduce cost forever).

## Simple Idea

Relax all edges again and again.
After k rounds, every shortest path with at most k edges is correct.
A simple shortest path uses at most V-1 edges, so **V-1 rounds** are enough.

## Step-by-Step

1. `dist[source] = 0`, others = infinity
2. Repeat V-1 times:
   - For every edge (u → v, w):
     - If `dist[u] + w < dist[v]`, update `dist[v]`
3. One more pass:
   - If any edge can still relax, a **negative cycle** exists

## Why It Works (Easy Invariant)

After round k, `dist[v]` is the shortest path using **at most k edges**.
So after V-1 rounds, all simple shortest paths are found.

## Complexity

- Time: **O(V × E)**
- Space: **O(V)**

## Example

```mbt check
///|
test "bellman ford example" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 1),
    (1, 2, 2),
    (0, 2, 5),
    (2, 3, 1),
  ]
  let (dist, neg) = @bellman_ford.bellman_ford(4, edges[:], 0)
  inspect(dist, content="[0, 1, 3, 4]")
  inspect(neg, content="false")
}
```

## When to Use

Use Bellman-Ford when:

- You have **negative edge weights**, or
- You must **detect negative cycles**

If all edges are non-negative, Dijkstra is faster.
