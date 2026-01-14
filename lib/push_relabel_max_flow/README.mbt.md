# Push-Relabel Max Flow

## Overview

**Push-Relabel** (also called Preflow-Push) is a max-flow algorithm that works
by maintaining a "preflow" (where nodes can have excess flow) and progressively
pushing excess toward the sink or back to the source.

- **Time**: O(V²E) worst-case, often faster in practice
- **Space**: O(V + E)
- **Key Feature**: Local operations, good for dense graphs

## The Key Insight

```
Ford-Fulkerson approach: Find augmenting paths globally
  - Each path: O(E) to find
  - Total: O(E × max_flow) iterations

Push-Relabel insight: Work locally!
  - Maintain "excess" at each node
  - Push excess to neighbors with lower "height"
  - If stuck, increase your height (relabel)
  - Eventually all excess reaches sink or returns to source

No global path finding needed!
```

## Understanding Preflow vs Flow

```
Flow conservation: flow_in(v) = flow_out(v) for all v ≠ s,t

Preflow relaxation: flow_in(v) ≥ flow_out(v) allowed
  - Nodes can have "excess" flow pooled up
  - excess(v) = flow_in(v) - flow_out(v)

Goal: Convert preflow to valid flow by pushing excess to sink.
```

## Height Labels and Admissible Edges

```
Height function h: V → N (non-negative integers)

Rules:
  h(s) = n (source is highest)
  h(t) = 0 (sink is lowest)
  For edge (u,v) with remaining capacity: h(u) ≤ h(v) + 1

An edge (u,v) is "admissible" if:
  - It has remaining capacity
  - h(u) = h(v) + 1 (exactly one level higher)

We can only push flow along admissible edges.
```

## Visual: Push and Relabel Operations

```
Push operation (when h(u) = h(v) + 1):

Before:                After push(u, v, 3):
  excess(u) = 5          excess(u) = 2
  [u] ──(cap=3)──► [v]   [u] ──(cap=0)──► [v]
  h=2              h=1   h=2              h=1
                         excess(v) increases by 3

Relabel operation (when no admissible edges):

Before:                After relabel(u):
  [u] excess=5           [u] excess=5
  h=2                    h=4  ← increased!
   │                      │
   ↓ (all neighbors       ↓ now (u,v) is admissible
  [v] h=3                [v] h=3
```

## Algorithm Walkthrough

```
Graph: s=0, t=5
    16     12
  0───►1───►3
  │    │ ╲  │
 13  10│  ╲9│20
  │    ↓   ↘↓
  └───►2───►4───►5
        14    4

Initial preflow (saturate edges from source):
  Push 16 to node 1
  Push 13 to node 2
  excess: {1: 16, 2: 13}
  height: {0: 6, others: 0}

Step 1: Process node 1 (excess=16, h=0)
  Can push to 3? h(1)=0, h(3)=0, not admissible
  Relabel: h(1) = 1

Step 2: Push from 1 to 2 (h(1)=1, h(2)=0)
  Push min(16, 10) = 10
  excess: {1: 6, 2: 23}

Step 3: Process node 2, push to 4
  ...

Continue until no excess at internal nodes.
Final max flow = 23
```

## The Three Invariants

```
Push-Relabel maintains:

1. Capacity constraint: 0 ≤ flow(u,v) ≤ capacity(u,v)

2. Preflow property: excess(v) ≥ 0 for all v ≠ s

3. Height property: For (u,v) with capacity, h(u) ≤ h(v) + 1

These ensure:
- We never violate capacities
- All excess can eventually be pushed somewhere
- The algorithm terminates
```

## Core Idea

1. Initialize a preflow by saturating all edges out of the source.
2. While a vertex has excess flow:
   - **Push** along admissible edges (height decreases by 1).
   - If none exist, **relabel** the vertex to create an admissible edge.

This local policy converges to a max flow when no active vertices remain.

## Example Usage

```mbt check
///|
test "push-relabel example" {
  let pr = @push_relabel_max_flow.PushRelabel::new(6)
  pr.add_edge(0, 1, 16L)
  pr.add_edge(0, 2, 13L)
  pr.add_edge(1, 2, 10L)
  pr.add_edge(2, 1, 4L)
  pr.add_edge(1, 3, 12L)
  pr.add_edge(2, 4, 14L)
  pr.add_edge(3, 2, 9L)
  pr.add_edge(4, 3, 7L)
  pr.add_edge(3, 5, 20L)
  pr.add_edge(4, 5, 4L)
  let flow = pr.max_flow(0, 5)
  inspect(flow, content="23")
}
```

## Common Applications

### 1. Network Flow
```
Classic application: maximize flow through a network.
Works well when the graph is dense.
```

### 2. Bipartite Matching
```
Maximum matching in bipartite graphs via flow reduction.
Each match corresponds to a unit of flow.
```

### 3. Min-Cut
```
After max-flow, nodes reachable from source form one side
of the minimum cut.
```

### 4. Image Segmentation
```
Graph cuts for image processing.
Push-relabel is efficient for grid graphs.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Basic Push-Relabel | O(V²E) |
| With FIFO ordering | O(V³) |
| With highest-label | O(V² √E) |
| With gap heuristic | Even faster in practice |

## Push-Relabel vs Other Max Flow Algorithms

| Algorithm | Time | Best For |
|-----------|------|----------|
| Ford-Fulkerson | O(E × max_flow) | Small max_flow |
| Edmonds-Karp | O(VE²) | Sparse graphs |
| Dinic | O(V²E) | Unit capacity |
| **Push-Relabel** | O(V²E) | Dense graphs |

**Choose Push-Relabel when**: Working with dense graphs or need good practical performance.

## Optimizations

```
1. Highest-label selection:
   Always process the node with highest h(v)
   Improves theoretical bound to O(V² √E)

2. Gap heuristic:
   If no node has height k (a "gap"), all nodes with height > k
   can be relabeled to n+1 (will return to source)

3. Global relabeling:
   Periodically BFS from sink to recompute all heights
   Prevents height explosion
```

## Implementation Notes

- Works well on dense graphs in practice
- Can be optimized with highest-label or gap heuristics
- Source height starts at n, sink at 0
- Track active nodes (nodes with excess > 0)
- Process active nodes until none remain

