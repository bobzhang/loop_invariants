# Johnson's All-Pairs Shortest Paths (APSP)

## What Johnson's Algorithm Solves

Johnson's algorithm computes **shortest paths between all pairs** of vertices in
**sparse directed graphs** that may contain **negative edges** but **no negative
cycles**.

It combines:

- **Bellman-Ford** (to remove negatives)
- **Dijkstra** (to do fast shortest paths afterward)

If your graph is dense, Floyd-Warshall is usually simpler. If it is sparse and
has negative edges, Johnson is the standard tool.

## Key Idea in One Sentence

Reweight every edge so all weights become non-negative **without changing which
paths are shortest**.

## The Potential Trick (Why Reweighting Works)

Pick a potential value `h(v)` for every vertex and redefine edge weights:

```
w'(u, v) = w(u, v) + h(u) - h(v)
```

For a path `P = v0 -> v1 -> ... -> vk`:

```
w'(P) = w(P) + h(v0) - h(vk)
```

That last term is a constant shift for *all* paths between `v0` and `vk`. So the
shortest path order does **not** change.

### How We Pick h(v)

Add a **super-source** `q` with 0-weight edges to every vertex and run
Bellman-Ford from `q`:

```
h(v) = dist(q, v)
```

By the Bellman-Ford triangle inequality:

```
h(v) <= h(u) + w(u, v)
=> w(u, v) + h(u) - h(v) >= 0
```

So all reweighted edges are non-negative and Dijkstra becomes valid.

## Visual: Reweighting Example

Original graph (has a negative edge):

```
0 --1--> 1 --(-2)--> 3
|        |
4        5
|        |
V        V
2 --1--> 3
```

Add super-source `q`:

```
q --0--> 0
q --0--> 1
q --0--> 2
q --0--> 3
```

Bellman-Ford from `q` gives potentials (one valid set):

```
h[0]=0, h[1]=0, h[2]=0, h[3]=-2
```

Reweight each edge:

```
w'(0,1) = 1 + 0 - 0  = 1
w'(0,2) = 4 + 0 - 0  = 4
w'(1,3) = -2 + 0 - (-2) = 0
w'(2,3) = 1 + 0 - (-2)  = 3
w'(1,3) is now 0, all edges >= 0
```

Now Dijkstra can be run from every source.

## Algorithm Outline

```
1) Add super-source q with 0-weight edges to all vertices
2) Run Bellman-Ford from q
   - If a negative cycle exists: return None
3) Reweight each edge: w'(u,v) = w(u,v) + h[u] - h[v]
4) For each source s:
     run Dijkstra on the reweighted graph
     recover original distances:
       dist[s][t] = d'[t] - h[s] + h[t]
```

## Step-by-Step Worked Example

Graph:

```
0 -> 1 (1)
0 -> 2 (4)
1 -> 2 (-2)
2 -> 3 (2)
1 -> 3 (5)
```

### 1) Bellman-Ford from q

```
q -> every vertex with weight 0

h starts as [0, 0, 0, 0]
After relaxations:
  h = [0, 0, -2, 0]
```

### 2) Reweight edges

```
0->1: 1 + 0 - 0   = 1
0->2: 4 + 0 - (-2)= 6
1->2: -2 + 0 - (-2)= 0
2->3: 2 + (-2) - 0= 0
1->3: 5 + 0 - 0   = 5
```

### 3) Dijkstra from 0

Reweighted distances from 0:

```
d' = [0, 1, 1, 1]
```

Recover original distances:

```
original dist[0][v] = d'[v] - h[0] + h[v]
= [0, 1, -1, 1]
```

This matches the true shortest paths in the original graph.

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
test "johnson unreachable" {
  let edges : Array[(Int, Int, Int64)] = [(0, 1, 2L), (1, 2, 3L)]
  let dist = @johnson_all_pairs.johnson_all_pairs(4, edges[:]).unwrap()
  // Node 3 is unreachable from 0
  inspect(dist[0][3], content="4611686018427387903")
}
```

```mbt check
///|
test "johnson negative cycle" {
  let edges : Array[(Int, Int, Int64)] = [(0, 1, 1L), (1, 2, -2L), (2, 1, -2L)]
  inspect(@johnson_all_pairs.johnson_all_pairs(3, edges[:]), content="None")
}
```

## Diagram: How the Potential Cancels

```
Path P: v0 -> v1 -> v2 -> v3

w'(P) = (w01 + h0 - h1)
      + (w12 + h1 - h2)
      + (w23 + h2 - h3)
      = w(P) + h0 - h3

All internal h terms cancel (telescoping).
```

## Common Pitfalls

- **Negative cycles**: Johnson must return None if any exist.
- **Overflow**: use Int64 and guard `dist + w` from overflow.
- **Unreachable nodes**: keep INF to represent no path.
- **Edge direction**: algorithm is for directed graphs. For undirected graphs,
  add edges in both directions.
- **Reweight recovery**: always use `d'[t] - h[s] + h[t]`.

## Complexity

| Phase | Time | Notes |
|------|------|-------|
| Bellman-Ford | O(V·E) | One run from super-source |
| Reweight edges | O(E) | Simple pass |
| Dijkstra × V | O(V·(E + V log V)) | Binary heap |
| Total | O(V·E·log V) | Best on sparse graphs |

## Johnson vs Floyd-Warshall

| Aspect | Johnson | Floyd-Warshall |
|--------|---------|----------------|
| Time | O(V·E·log V) | O(V^3) |
| Space | O(V + E) + output | O(V^2) |
| Negative edges | Yes | Yes |
| Best for | Sparse | Dense |

## Implementation Notes (This Package)

- Uses Bellman-Ford from `@bellman_ford` to get potentials.
- Uses a custom binary heap for Dijkstra.
- Distances are stored in `Int64`, with `INF64` for unreachable nodes.
- The API returns `None` when a negative cycle exists.

If you need path reconstruction, store predecessor arrays inside Dijkstra and
carry them through the recovery step.
