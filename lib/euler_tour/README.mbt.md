# Euler Tour

## Overview

The **Euler Tour** technique linearizes a tree into an array, enabling subtree
queries to be answered as range queries. It records entry and exit times for
each node during a DFS traversal.

- **Build**: O(n)
- **Space**: O(n)

## What You Get From the Tour

```
For each node u:
  entry[u] = time when DFS first enters u
  exit[u]  = time after DFS finishes u's subtree

And:
  tour[]   = nodes in preorder (each node once)
  depth[]  = depth of each node (if you track it)
  parent[] = parent in rooted tree
```

## The Key Insight

```
DFS visits nodes in a specific order. By recording when we
enter and exit each node, subtrees become contiguous ranges!

Tree:           DFS Order:
     1              1 (enter)
    /|\             2 (enter)
   2 3 4            5 (enter, exit)
  /|                6 (enter, exit)
 5 6                2 (exit)
                    3 (enter, exit)
                    4 (enter, exit)
                    1 (exit)

Preorder tour (entry only): [1, 2, 5, 6, 3, 4]
                           └──subtree of 2──┘
```

## Entry and Exit Times

```
      tin  tout
  1:   0     6
  2:   1     4
  3:   4     5
  4:   5     6
  5:   2     3
  6:   3     4

Subtree of node u = all nodes with tin in [tin[u], tout[u])

Subtree of 2: tin in [1, 4)
  → Nodes 2, 5, 6 (check: tin[5]=2, tin[6]=3 are in [1,4) ✓)
```

## Subtree Sum as a Range Sum

```
Tree (root = 0):
    0
   / \
  1   2
 / \
3   4

Values:
  val[0]=5, val[1]=1, val[2]=4, val[3]=2, val[4]=3

Suppose the tour gives:
  entry = [0, 1, 4, 2, 3]
  exit  = [5, 4, 5, 3, 4]

Flatten by entry:
  flat[entry[u]] = val[u]
  flat = [5, 1, 2, 3, 4]

Subtree sum of node 1:
  range = [entry[1], exit[1]) = [1, 4)
  flat[1..4) = [1, 2, 3]
  sum = 6
```

## Algorithm Walkthrough

```
DFS from root 1:

  timer = 0

  Visit 1: tin[1] = 0
    Visit 2: tin[2] = 1
      Visit 5: tin[5] = 2, tout[5] = 3
      Visit 6: tin[6] = 3, tout[6] = 4
    tout[2] = 4
    Visit 3: tin[3] = 4, tout[3] = 5
    Visit 4: tin[4] = 5, tout[4] = 6
  tout[1] = 6

Final:
  Node:  1  2  3  4  5  6
  tin:   0  1  4  5  2  3
  tout:  6  4  5  6  3  4
```

## Two Types of Euler Tours

```
Type 1: Entry/Exit times only
  Array size: n (each node once)
  tin[u], tout[u] are times

Type 2: Full tour with entries and exits
  Array size: 2n (each node twice)
  tour[i] = node visited at step i

For subtree queries, Type 1 suffices.
For LCA queries, Type 2 is often used.
```

### Type 2 Example (for LCA)

```
Tree:
    0
   / \
  1   2
     / \
    3   4

Full Euler walk (node, depth):
  0(0), 1(1), 0(0), 2(1), 3(2), 2(1), 4(2), 2(1), 0(0)

First occurrence:
  first[1] = 1, first[3] = 4, first[4] = 6

LCA(3, 4) is the node with minimum depth between
positions 4..6 in the Euler walk => node 2.
```

## Example Usage

```mbt check
///|
test "euler tour subtree basics" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (1, 3)]
  let tour = @euler_tour.build_euler_tour(4, edges[:], 0)
  inspect(tour.subtree_size(1), content="3")
  inspect(tour.is_ancestor(1, 3), content="true")
}
```

```mbt check
///|
test "euler tour subtree nodes" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (1, 3)]
  let tour = @euler_tour.build_euler_tour(4, edges[:], 0)
  let nodes = tour.subtree_nodes(1)
  nodes.sort_by((a, b) => a - b)
  inspect(nodes, content="[1, 2, 3]")
}
```

```mbt check
///|
test "euler tour arrays" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let (tin, tout, order) = @euler_tour.euler_tour(5, edges[:], 0)
  inspect(order.length(), content="5")
  inspect(tin[0] < tout[0], content="true")
}
```

```mbt check
///|
test "euler tour subtree sum" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let info = @euler_tour.build_euler_tour(5, edges[:], 0)
  let values : Array[Int] = [5, 1, 4, 2, 3]
  let flat = Array::make(5, 0)
  for i in 0..<5 {
    flat[info.entry[i]] = values[i]
  }
  let start = info.entry[1]
  let end = info.exit[1]
  let total = flat[start:end].fold(init=0, (acc, v) => acc + v)
  inspect(total, content="6")
}
```

## Common Applications

### 1. Subtree Queries
```
Query: Sum/min/max of values in subtree
Solution:
  1. Build Euler tour to get tin/tout
  2. Put values at positions tin[u]
  3. Use segment tree/Fenwick tree on flattened array
  4. Query range [tin[u], tout[u]-1]

Time: O(log n) per query after O(n) preprocessing
```

### 2. Subtree Updates
```
Query: Add value to all nodes in subtree
Solution:
  1. Flatten tree via Euler tour
  2. Range update on [tin[u], tout[u]-1]
  3. Use lazy segment tree for range updates
```

### 3. LCA via RMQ
```
Record depths in Euler tour (Type 2).
LCA(u, v) = node with minimum depth between
            first occurrence of u and first occurrence of v.

Use sparse table for O(1) LCA queries!
```

### 4. Path Queries
```
Combine with LCA:
  path(u, v) = path(u, lca) + path(lca, v)

Or use Heavy-Light Decomposition for more complex queries.
```

## Visual: Subtree as Range

```
Tree:                 Flattened (by tin):
      A                pos: 0  1  2  3  4  5
     /|\               val: A  B  D  E  C  F
    B C F
   /|
  D E

tin: A=0, B=1, C=4, D=2, E=3, F=5
tout: A=6, B=4, C=5, D=3, E=4, F=6

Subtree of B: positions [1, 3] = [B, D, E]
              (tout[B]=4, so range is [1, 4-1])
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build Euler tour | O(n) |
| Check if u is ancestor of v | O(1) |
| Subtree query (with seg tree) | O(log n) |

## Euler Tour vs Other Tree Techniques

| Technique | Preprocess | Query | Best For |
|-----------|------------|-------|----------|
| **Euler Tour** | O(n) | O(log n) | Subtree queries |
| Heavy-Light | O(n) | O(log² n) | Path queries/updates |
| Centroid | O(n log n) | O(log n) | Distance queries |
| LCA | O(n log n) | O(log n) | Ancestor queries |

**Choose Euler Tour when**: You need efficient subtree operations.

## Checking Ancestor Relationship

```
u is an ancestor of v iff:
  tin[u] ≤ tin[v] AND tout[u] ≥ tout[v]

This is O(1) after preprocessing!

Example:
  Is 1 ancestor of 5?
  tin[1]=0 ≤ tin[5]=2 ✓
  tout[1]=11 ≥ tout[5]=3 ✓
  Yes!
```

## Common Pitfalls

- **Not a tree**: Euler tour assumes a tree (connected, n-1 edges).
- **Wrong root**: entry/exit times depend on the chosen root.
- **Off-by-one**: subtree range is `[entry[u], exit[u])` (exit is exclusive).
- **Mixing tour types**: LCA needs the full tour, subtree queries need entry/exit.

## Implementation Notes

- This implementation uses recursive DFS for clarity
- For very deep trees, consider an iterative stack-based DFS
- For Type 2 tour, record node on both entry and exit
- tin[u] is always < tout[u] for the same node
- Children of u have tin values in (tin[u], tout[u])
- Size of subtree = (tout[u] - tin[u] + 1) / 2 for Type 2
