# Topological Sort (DFS)

## Overview

A **topological order** of a directed acyclic graph (DAG) is a linear ordering
where every edge `u -> v` appears with `u` before `v`.

- **Build**: O(V + E)
- **Space**: O(V + E)

## DFS Method

1. Run DFS from every unvisited vertex.
2. When a vertex finishes (all outgoing edges processed), append it to a list.
3. Reverse the list to obtain the topological order.

### Cycle Detection

We keep a state per vertex:
- `0` = unvisited
- `1` = visiting (currently on DFS stack)
- `2` = done

An edge to a **visiting** vertex indicates a cycle, so no topological order
exists.

## Example

```
Edges: 0->1, 0->2, 1->3, 2->3

Valid topological orders:
  0, 1, 2, 3
  0, 2, 1, 3
```

## Example Usage

```mbt check
///|
test "topological sort example" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (2, 3)]
  let order = @topological_sort_dfs.topological_sort(4, edges[:]).unwrap()
  inspect(order.length(), content="4")
}
```

## Why It Works

A vertex is appended only after all its outgoing neighbors are fully processed.
Therefore, every edge goes from an earlier vertex in the reversed list to a
later vertex.

## Applications

- Task scheduling with prerequisites
- Build systems (compile order)
- Course planning
- DAG dynamic programming
