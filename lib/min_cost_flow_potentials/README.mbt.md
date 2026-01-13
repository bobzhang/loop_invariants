# Min-Cost Max-Flow (Potentials)

## Overview

This implementation uses **successive shortest augmenting paths** with
**Johnson potentials**. Potentials reweight residual edges so all reduced costs
are non-negative, allowing Dijkstra to be used in every augmentation step.

- **Time**: O(F · E log V)
- **Space**: O(V + E)

## Quick Start

```mbt check
///|
test "min-cost flow with potentials" {
  let mcf = @min_cost_flow_potentials.MinCostFlowPotentials::new(4)
  mcf.add_edge(0, 1, 2L, 1L)
  mcf.add_edge(0, 2, 1L, 2L)
  mcf.add_edge(1, 2, 1L, 1L)
  mcf.add_edge(1, 3, 1L, 3L)
  mcf.add_edge(2, 3, 2L, 1L)
  let (flow, cost) = mcf.compute(0, 3)
  inspect(flow, content="3")
  inspect(cost, content="10")
}
```

## More Examples

```mbt check
///|
test "min-cost flow limited" {
  let mcf = @min_cost_flow_potentials.MinCostFlowPotentials::new(3)
  mcf.add_edge(0, 1, 1L, 1L)
  mcf.add_edge(1, 2, 1L, 1L)
  let (flow, cost) = mcf.compute_with_limit(0, 2, 1L)
  inspect(flow, content="1")
  inspect(cost, content="2")
}
```

```mbt check
///|
test "min-cost flow no path" {
  let mcf = @min_cost_flow_potentials.MinCostFlowPotentials::new(2)
  let (flow, cost) = mcf.compute(0, 1)
  inspect(flow, content="0")
  inspect(cost, content="0")
}
```
