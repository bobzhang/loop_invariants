# Tree Utilities

## Overview

Tree-oriented data structures and algorithms that combine tree traversal
techniques with efficient range structures. These utilities enable fast
queries on tree paths and subtrees.

- **Euler Tour + Range Query**: O(log n) per subtree query
- **Fenwick on Tree**: O(log n) update and query
- **LCA with Binary Lifting**: O(log n) per query

## The Key Insight

```
Trees can be "flattened" into arrays for range queries!

Euler Tour Technique:
  Number nodes by DFS entry time (tin) and exit time (tout).
  Subtree of v = all nodes with tin in [tin[v], tout[v]]

Original tree:        Euler order:
       1              Node:  1  2  4  5  3  6
      / \             tin:   0  1  2  3  4  5
     2   3            tout:  3  2  2  3  5  5
    / \   \
   4   5   6

Subtree of 2 = nodes with tin in [1, 3] = {2, 4, 5} ✓
```

## Euler Tour Flattening

```
DFS traversal assigns each node two timestamps:
  tin[v] = when we enter v
  tout[v] = when we leave v (after visiting all descendants)

Tree:           DFS order:
     A            Enter A (tin=0)
    /|\             Enter B (tin=1)
   B C D              Leave B (tout=1)
  /\                Enter C (tin=2)
 E  F                  Leave C (tout=2)
                    Enter D (tin=3)
                      Enter E (tin=4)
                        Leave E (tout=4)
                      Enter F (tin=5)
                        Leave F (tout=5)
                      Leave D (tout=5)
                    Leave A (tout=5)

Result:
  A: tin=0, tout=5  (subtree = all nodes)
  B: tin=1, tout=1  (subtree = just B)
  C: tin=2, tout=2  (subtree = just C)
  D: tin=3, tout=5  (subtree = D, E, F)
  E: tin=4, tout=4
  F: tin=5, tout=5

Query "sum of subtree D":
  = sum of arr[tin[D]..tout[D]] = sum of arr[3..5]
```

## Fenwick Tree on Euler Order

```
Combine Euler tour with Fenwick tree for:
  - Subtree sum queries: O(log n)
  - Node value updates: O(log n)

Setup:
  1. Run DFS to compute tin[], tout[]
  2. Create Fenwick tree of size n
  3. For node v with value w: fenwick.update(tin[v], w)

Query subtree sum of v:
  fenwick.query(tout[v]) - fenwick.query(tin[v] - 1)

Update value of v to new_val:
  fenwick.update(tin[v], new_val - old_val)
```

## Path Queries with LCA

```
Query on path from u to v using LCA:

Path(u, v) = Path(u, lca) ∪ Path(lca, v)

For sum query:
  sum(u→v) = sum(root→u) + sum(root→v) - 2*sum(root→lca) + val(lca)

Tree:          Values:
     A=10        A: 10
    / \          B: 20
   B   C         C: 30
  / \            D: 40
 D   E           E: 50

prefix_sum[v] = sum from root to v:
  A: 10
  B: 30
  C: 40
  D: 70
  E: 80

Query sum(D→C):
  LCA(D, C) = A
  sum = prefix[D] + prefix[C] - 2*prefix[A] + val[A]
      = 70 + 40 - 20 + 10 = 100
  Path: D→B→A→C = 40+20+10+30 = 100 ✓
```

## Heavy-Light Decomposition Overview

```
Split tree into chains for efficient path queries.

Idea: Each node's "heavy" child is the one with largest subtree.
      Following heavy edges forms a chain.

Tree:            Chains:
       1          Chain 1: 1-2-4 (heavy path)
      /|\         Chain 2: 3
     2 3 5        Chain 3: 5
    /|            Chain 4: 6
   4 6

Path query u→v:
  1. Move up chain by chain until same chain
  2. Query within chain (segment tree)

Total: O(log n) chains × O(log n) segment tree = O(log² n)
```

## Algorithm Walkthrough

```
Build Euler tour for path updates:

Tree:       DFS:
    1         Enter 1 (0)
   / \          Enter 2 (1)
  2   3           Enter 4 (2), Leave (2)
 / \              Enter 5 (3), Leave (3)
4   5           Leave 2 (3)
                Enter 3 (4), Leave (4)
              Leave 1 (4)

Euler array (entry values):
  index: 0  1  2  3  4
  node:  1  2  4  5  3

Update subtree of node 2 by +5:
  Range update on [tin[2], tout[2]] = [1, 3]
  Result: nodes 2, 4, 5 get +5

Query value at node 4:
  Point query at tin[4] = 2
```

## Example Usage

```mbt nocheck
// Build tree
let n = 6
let adj = build_adjacency_list(edges)

// Compute Euler tour
let (tin, tout) = euler_tour(adj, root=0)

// Initialize Fenwick tree with node values
let fenwick = Fenwick::new(n)
for v in 0..n {
  fenwick.update(tin[v], values[v])
}

// Query subtree sum of node 2
let sum = fenwick.query(tout[2]) - fenwick.query(tin[2] - 1)

// Update node 3's value
fenwick.update(tin[3], new_value - old_value)
```

## Common Applications

### 1. Subtree Queries
```
Sum/min/max of all values in subtree.
Use Euler tour + range structure.
Time: O(log n) per query after O(n) preprocessing.
```

### 2. Path Queries
```
Sum/min/max of values on path u→v.
Use LCA + prefix sums, or HLD for updates.
Time: O(log n) to O(log² n).
```

### 3. Subtree Updates
```
Add value to all nodes in subtree.
Use Euler tour + lazy segment tree.
Time: O(log n) per update.
```

### 4. Dynamic Connectivity
```
Track connected components with updates.
Use Link-Cut Trees for full dynamism.
Time: O(log n) amortized.
```

## Complexity Summary

| Operation | Euler + Fenwick | HLD + Segtree | LCT |
|-----------|-----------------|---------------|-----|
| Subtree query | O(log n) | O(log n) | — |
| Subtree update | O(log n) | O(log n) | — |
| Path query | O(log n)* | O(log² n) | O(log n) |
| Path update | O(log n)* | O(log² n) | O(log n) |
| Link/Cut | — | — | O(log n) |

*Path query with Euler needs LCA preprocessing

## Tree Query Techniques Comparison

| Technique | Query Type | Update Support | Complexity |
|-----------|------------|----------------|------------|
| Euler Tour | Subtree | Point | O(log n) |
| HLD | Path + Subtree | Point + Range | O(log² n) |
| LCT | Path | Point | O(log n) amort |
| Centroid | Path decomp | Static | O(log n) |

**Choose based on**: Query type (subtree vs path) and update requirements.

## Implementation Notes

- Euler tour: careful with tin/tout boundaries (inclusive vs exclusive)
- For subtree queries: tout[v] should be inclusive of v's last descendant
- HLD: break ties consistently when choosing heavy child
- LCA with binary lifting: precompute 2^k ancestors
- Consider using iterative DFS for deep trees (avoid stack overflow)

