# Link-Cut Tree

## Overview

A **Link-Cut Tree** is a dynamic tree data structure that supports link, cut,
and path queries in O(log n) amortized time. It represents a forest of trees
that can be dynamically modified.

- **Operations**: O(log n) amortized
- **Space**: O(n)

## The Problem

```
Maintain a forest that changes over time:
- link(u, v): Add edge between u and v (trees merge)
- cut(u, v): Remove edge between u and v (tree splits)
- path_query(u, v): Query path from u to v

Static trees: Use HLD, LCA, etc.
Dynamic trees: Need Link-Cut Trees!
```

## The Key Insight

```
Decompose tree into "preferred paths" using splay trees.
Each splay tree represents one preferred path.

Preferred child: The last child we accessed
Preferred path: Chain of preferred child relationships

Tree:              Preferred paths (after accessing 6):
      1                    [1]
     /|\                   |
    2 3 4                  [3]
   /|                      |
  5 6            [2-5]    [4-6]

Access(6): Makes path from 6 to root "preferred"
           1-3-4-6 becomes one splay tree
```

## Operations

### Access(v)
```
Make path from v to root a single preferred path.

Before access(6):        After access(6):
Preferred paths:         Preferred paths:
  [1-2-5]                  [1-3-4-6]
  [3]                      [2-5]
  [4-6]

Steps:
1. Splay v to root of its auxiliary tree
2. Cut right child (detach old preferred path below)
3. Walk up parent edges, splaying and attaching
```

### Link(u, v)
```
Make u a child of v. Trees merge.

Trees:    [A]    [B]      After link(u, v):
           |      |              [A]
           u      v               |
                                  v
                                  |
                                 [B]

Implementation:
1. make_root(u)  // u becomes root of its tree
2. u.parent = v
```

### Cut(u, v)
```
Remove edge between u and v. Tree splits.

Before cut(u, v):       After cut(u, v):
      [A]                    [A]    [B]
       |                      |      |
       v                      v      u
       |
      [B]
       |
       u

Implementation:
1. make_root(u)
2. access(v)
3. v.left = null (cut connection)
```

## Visual: Preferred Path Decomposition

```
Original tree:          Auxiliary trees (splay):
        1
       /|\              Each preferred path is one splay tree
      2 3 4             connected by "path parent" pointers
     /|   |
    5 6   7

If preferred path is 1-3-4-7:

   Splay tree 1:     Splay tree 2:
       [3]              [6]
      /   \              |
    [1]   [4]      path  [2]
            \     parent  |
            [7] --------> [5]
```

## Example Usage

```mbt nocheck
// Build Link-Cut Tree
let lct = LinkCutTree::new(n)

// Initially, each node is its own tree

// Link operations
lct.link(1, 2)  // Connect 1 to 2
lct.link(3, 2)  // Connect 3 to 2
lct.link(4, 3)  // Connect 4 to 3

// Query path
let sum = lct.path_sum(1, 4)  // Sum on path 1-2-3-4

// Cut operation
lct.cut(3, 2)  // Disconnect 3 from 2
// Now: {1, 2} and {3, 4} are separate trees
```

## Common Applications

### 1. Dynamic Connectivity
```
Query: Are u and v in the same tree?
Update: Link or cut edges

LCT gives O(log n) for both operations!
```

### 2. Path Queries on Dynamic Trees
```
Query: Sum/max/min on path from u to v
Update: Change edge weights or node values

LCT can store auxiliary data in splay nodes.
```

### 3. Dynamic LCA
```
After access(u) and access(v),
the LCA is the last node where paths split.
```

### 4. Maximum Spanning Forest
```
Maintain MST while edges are added.
If cycle detected, remove heaviest edge.
LCT allows O(log n) per edge operation.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| access | O(log n) amortized |
| link | O(log n) amortized |
| cut | O(log n) amortized |
| find_root | O(log n) amortized |
| path_query | O(log n) amortized |

## Link-Cut Tree vs Other Structures

| Structure | Link/Cut | Path Query | Use Case |
|-----------|----------|------------|----------|
| **Link-Cut Tree** | O(log n) | O(log n) | Dynamic trees |
| Heavy-Light Decomp | N/A | O(log² n) | Static trees |
| Euler Tour Tree | O(log n) | O(log n) subtree | Subtree queries |
| Top Trees | O(log n) | O(log n) | Tree contraction |

**Choose Link-Cut Tree when**: You need dynamic link/cut with path queries.

## The Splay Tree Connection

```
Each preferred path is stored as a splay tree.
Key ordering: depth in the represented tree.

Splay ensures recently accessed paths are fast to access again.
This gives amortized O(log n) per operation.

Rotations in splay tree = rotations in represented tree?
No! Splay rotations only affect auxiliary structure,
not the actual tree topology.
```

## Make Root Operation

```
make_root(v): Make v the root of its represented tree.

Implementation:
1. access(v)        // v is now root of its splay tree
2. Flip the splay tree (reverse in-order)

This "reroots" the tree at v, useful before link.
```

## Implementation Notes

- Each node has: parent, left, right, path_parent
- path_parent points to parent in represented tree (across preferred paths)
- Splay before most operations for amortization
- Use lazy propagation for path reversals
- Store aggregates (sum, min, max) in splay nodes
- Handle subtree values separately (not directly supported)

