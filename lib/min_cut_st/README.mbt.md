# Minimum s-t Cut (Max-Flow Min-Cut)

## Overview

For a directed graph with **non-negative capacities**, the **max-flow min-cut
 theorem** says:

```
max_flow(s, t) = min_cut_capacity(s, t)
```

This package computes the minimum s-t cut by running Dinic's maximum flow
algorithm and then doing a BFS in the **residual graph** to find which vertices
remain reachable from `s`.

- **Time**: O(V^2 E)
- **Space**: O(V + E)

## What You Get

`min_cut_st` returns:

- `value`: the cut capacity (also the max flow)
- `source_side`: all vertices reachable from `s` in the residual graph after
  max flow finishes

The cut edges are exactly those from `source_side` to the remaining vertices.

## Example Usage

```mbt check
///|
test "min cut st basic" {
  let edges : Array[(Int, Int, Int64)] = [
    (0, 1, 3L),
    (0, 2, 2L),
    (1, 3, 2L),
    (2, 3, 3L),
  ]
  let result = @min_cut_st.min_cut_st(4, edges[:], 0, 3).unwrap()
  inspect(result.value, content="4")
}
```

```mbt check
///|
test "min cut st no path" {
  let edges : Array[(Int, Int, Int64)] = []
  let result = @min_cut_st.min_cut_st(3, edges[:], 0, 2).unwrap()
  inspect(result.value, content="0")
}
```

## Why Residual Reachability Works

After max flow, there is **no augmenting path** from `s` to `t`. The vertices
reachable from `s` using residual edges form the **source side** of a minimum
cut. Every edge crossing from that set to the rest is saturated, so their total
capacity equals the max flow value.
