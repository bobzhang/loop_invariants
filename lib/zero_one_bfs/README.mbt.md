# 0-1 BFS

## Overview

**0-1 BFS** computes single-source shortest paths in graphs where every edge
weight is either 0 or 1. It achieves O(V + E) time by using a deque instead
of a priority queue.

- **Time**: O(V + E)
- **Space**: O(V + E)
- **Key Feature**: Linear time for 0-1 weighted graphs

## The Key Insight

```
Dijkstra's algorithm: O((V + E) log V) with priority queue
  - Needed because edges can have any weight
  - Priority queue maintains sorted order

0-1 BFS insight:
  - With only weights 0 and 1, distances increase by at most 1 at each step
  - A deque naturally maintains sorted order!
  - Weight 0: push to front (same distance)
  - Weight 1: push to back (distance + 1)

No priority queue needed → O(V + E)!
```

## Understanding the Deque Invariant

```
The deque maintains nodes in non-decreasing distance order:

  front ← [dist=2, dist=2, dist=3, dist=3, dist=3, dist=4] → back

When we pop from front, we always get a minimum-distance node!

Edge weight 0: New distance = current distance (add to front)
Edge weight 1: New distance = current distance + 1 (add to back)

This maintains the sorted invariant automatically.
```

## Visual: 0-1 BFS Execution

```
Graph:
    0 ──(0)─► 1 ──(1)─► 3
    │         │         ▲
   (1)       (1)       (0)
    │         │         │
    ▼         ▼         │
    2 ──(0)─► 4 ────────┘

Initial: deque = [0], dist = [0, ∞, ∞, ∞, ∞]

Step 1: Pop 0, process edges
  Edge 0→1 (w=0): dist[1] = 0, push_front(1)
  Edge 0→2 (w=1): dist[2] = 1, push_back(2)
  deque = [1, 2], dist = [0, 0, 1, ∞, ∞]

Step 2: Pop 1, process edges
  Edge 1→3 (w=1): dist[3] = 1, push_back(3)
  Edge 1→4 (w=1): dist[4] = 1, push_back(4)
  deque = [2, 3, 4], dist = [0, 0, 1, 1, 1]

Step 3: Pop 2, process edges
  Edge 2→4 (w=0): dist[4] already 1 ≤ 1, skip

Step 4: Pop 3, no new edges

Step 5: Pop 4, process edges
  Edge 4→3 (w=0): dist[3] already 1 ≤ 1, skip

Final distances: [0, 0, 1, 1, 1]
```

## Why the Deque Works

```
Key properties:

1. All 0-weight edges are processed first
   (They go to front, so they're popped before 1-weight edges)

2. Nodes in deque have distances d or d+1
   - Front nodes have distance d (from 0-weight edges)
   - Back nodes have distance d+1 (from 1-weight edges)
   - Never more than 2 different distances in deque!

3. Each node is processed at most once
   - Once we visit a node, its distance is final
   - Later visits can't improve it (greedy is safe)
```

## Core Idea

- Maintain a deque of nodes in **nondecreasing distance** order.
- Edge weight 0 goes to front; weight 1 goes to back.
- Each edge is relaxed once, giving linear time.

## Example Usage

```mbt check
///|
test "0-1 bfs example" {
  let g = @zero_one_bfs.Graph::new(5)
  g.add_edge(0, 1, 0)
  g.add_edge(1, 2, 1)
  g.add_edge(0, 2, 1)
  g.add_edge(2, 3, 0)
  g.add_edge(1, 3, 1)
  g.add_edge(3, 4, 1)
  let dist = @zero_one_bfs.zero_one_bfs(g, 0)
  inspect(dist, content="[0, 0, 1, 1, 2]")
}
```

## More Examples

```mbt check
///|
test "0-1 bfs undirected" {
  let g = @zero_one_bfs.Graph::new(4)
  g.add_undirected_edge(0, 1, 0)
  g.add_undirected_edge(1, 2, 1)
  g.add_undirected_edge(2, 3, 0)
  let dist = @zero_one_bfs.zero_one_bfs(g, 0)
  inspect(dist, content="[0, 0, 1, 1]")
}
```

## Common Applications

### 1. Grid Navigation with Teleports
```
Move between adjacent cells (cost 1) or teleport (cost 0).
Model as 0-1 graph, solve with 0-1 BFS.
```

### 2. String Transformation
```
Transform string s to t:
  - Identical character: cost 0
  - Different character: cost 1
Find minimum cost to reach target.
```

### 3. Obstacle Removal
```
Path through a grid where:
  - Empty cells: cost 0
  - Obstacles: cost 1 to remove
Find minimum removals to reach destination.
```

### 4. Network Upgrades
```
Network where some links are free, others cost 1 to upgrade.
Find minimum upgrades for connectivity.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| 0-1 BFS | O(V + E) |
| Build graph | O(E) |
| Space | O(V + E) |

## 0-1 BFS vs Other Shortest Path Algorithms

| Algorithm | Time | Edge Weights |
|-----------|------|--------------|
| **0-1 BFS** | O(V + E) | {0, 1} only |
| BFS | O(V + E) | All equal (unweighted) |
| Dijkstra | O((V + E) log V) | Non-negative |
| Bellman-Ford | O(VE) | Any (handles negative) |

**Choose 0-1 BFS when**: All edge weights are 0 or 1.

## Generalizing to 0-k BFS

```
If edge weights are in {0, 1, 2, ..., k}:

Use k+1 queues (or a "bucket" structure):
  bucket[0], bucket[1], ..., bucket[k]

When processing distance d:
  - Weight w edge → add to bucket[(d + w) % (k+1)]

Time: Still O(V + E) for small k
```

## Implementation Notes

- Use a double-ended queue (deque) for O(1) front/back operations
- Initialize distances to infinity (or max int)
- Set source distance to 0 and push to deque
- Process each node only once (check if already visited)
- Works for both directed and undirected graphs

