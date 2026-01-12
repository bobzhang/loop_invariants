# Minimum Cost Maximum Flow (MCMF)

## Overview

**Minimum Cost Maximum Flow** finds a maximum flow that minimizes total cost.
Each edge has both capacity and cost per unit of flow. Among all maximum flows,
MCMF finds the one with minimum total cost.

- **Time**: O(V × E × flow) with SPFA, O(V × E × flow × log V) with Dijkstra
- **Space**: O(V + E)

## The Problem

```
Each edge has: capacity and cost per unit flow.
Goal: Send maximum flow from source to sink with minimum total cost.

Graph:
    capacity=3, cost=2
  S ────────────────→ A ─────────────→ T
  │                   │   cap=2, cost=1
  │ cap=2             │ cap=1
  │ cost=1            │ cost=3
  ↓                   ↓
  B ─────────────────→
      cap=3, cost=2

Maximum flow = 4, but costs differ by path:
  S→A→T: 2 units × (2+1) = 6
  S→B→T: 2 units × (1+2) = 6
Total minimum cost for max flow = 12
```

## The Key Insight

```
Repeatedly find shortest (minimum cost) augmenting path.
"Shortest" means minimum cost per unit flow.

Why it works:
- Each shortest path augmentation is optimal for current flow value
- Building up flow greedily by cost gives optimal total cost

Unlike max flow where any augmenting path works,
MCMF requires finding minimum cost paths!
```

## Algorithm: Successive Shortest Paths

```
1. Initialize flow = 0, cost = 0
2. While shortest path from s to t exists in residual graph:
   a. Find path using SPFA/Bellman-Ford (handles negative costs)
   b. Find bottleneck (minimum residual capacity on path)
   c. Augment flow along path
   d. Add (path_cost × bottleneck) to total cost
3. Return (flow, cost)
```

## Algorithm Walkthrough

```
Graph:
  S →(cap=3, cost=1)→ A →(cap=2, cost=2)→ T
  S →(cap=2, cost=2)→ B →(cap=3, cost=1)→ T

Step 1: Find shortest path
  S→A→T: cost = 1 + 2 = 3 per unit
  S→B→T: cost = 2 + 1 = 3 per unit
  Both equal, pick S→A→T

  Augment 2 units (limited by A→T)
  Flow = 2, Cost = 2 × 3 = 6

Step 2: Find shortest path in residual
  S→A: capacity 1 left, cost 1
  A→T: saturated (but reverse edge exists)
  S→B→T: cost = 3

  Path S→B→T with cost 3
  Augment 2 units (limited by S→B)
  Flow = 4, Cost = 6 + 2 × 3 = 12

Step 3: No more augmenting paths
  Max flow = 4, Min cost = 12
```

## Visual: Residual Graph with Costs

```
Original edge: u →(cap=c, cost=w)→ v

Residual graph:
  Forward:  u →(cap=c-f, cost=w)→ v    (remaining capacity)
  Backward: v →(cap=f, cost=-w)→ u     (can "undo" flow)

The negative cost on backward edge is crucial!
It allows "undoing" expensive flow for cheaper alternatives.
```

## Example Usage

```mbt nocheck
// Create MCMF graph
let mcmf = MCMF::new(n)

// Add edges: (from, to, capacity, cost)
mcmf.add_edge(0, 1, 3, 1)  // S to A
mcmf.add_edge(0, 2, 2, 2)  // S to B
mcmf.add_edge(1, 3, 2, 2)  // A to T
mcmf.add_edge(2, 3, 3, 1)  // B to T

// Compute min cost max flow
let (flow, cost) = mcmf.min_cost_max_flow(source=0, sink=3)
// flow = 4, cost = 12
```

## Common Applications

### 1. Assignment Problem
```
Assign n workers to n jobs with costs.
Source → Workers → Jobs → Sink
All capacities = 1, edge costs = assignment costs.
Min cost max flow = optimal assignment.
```

### 2. Transportation Problem
```
Ship goods from factories to warehouses.
Edges have shipping costs and capacity limits.
Minimize total shipping cost.
```

### 3. Project Scheduling
```
Schedule tasks with resource constraints.
Model as flow network with time/resource costs.
```

### 4. Network Design
```
Build network infrastructure with costs.
Maximize connectivity while minimizing construction cost.
```

## Handling Negative Costs

```
Bellman-Ford/SPFA: Handle negative edges directly
Dijkstra with potentials: Johnson's technique

Potentials (π):
  Reduce costs: new_cost(u,v) = cost(u,v) + π[u] - π[v]
  All reduced costs become non-negative!
  After each shortest path, update potentials.
```

## Complexity Analysis

| Method | Time |
|--------|------|
| SPFA-based | O(V × E × max_flow) |
| Dijkstra + potentials | O(V × E × max_flow × log V) |
| Capacity scaling | O(E² log V log U) |

## MCMF vs Max Flow

| Aspect | Max Flow | MCMF |
|--------|----------|------|
| Objective | Maximize flow | Maximize flow, minimize cost |
| Path selection | Any augmenting | Shortest (min cost) |
| Algorithm | Dinic, Push-Relabel | SPFA/Dijkstra + augment |
| Complexity | O(V²E) | O(VE × flow) |

**Choose MCMF when**: You need to optimize cost among maximum flows.

## Min Cost Flow (Specific Amount)

```
Sometimes you want exactly k units of flow, not maximum.

Modify algorithm:
  - Stop when flow reaches k
  - Or: add edge from T to S with capacity k, cost 0
        then find min cost circulation
```

## Negative Cycles

```
If residual graph has negative cost cycle:
  - Can reduce cost by pushing flow around cycle
  - Keep canceling negative cycles until none remain

Cycle-canceling algorithm:
  1. Find any feasible flow (or max flow)
  2. While negative cycle exists:
     - Augment flow around cycle
  3. Result is min cost flow
```

## Implementation Notes

- Store edges with reverse pointers for residual updates
- SPFA works for negative costs but can be slow
- Dijkstra with potentials is faster but needs careful initialization
- Watch for integer overflow in cost calculation
- For large flows, consider capacity scaling
- Edge (u, v, cap, cost) creates reverse (v, u, 0, -cost)

