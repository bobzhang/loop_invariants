# Link-Cut Tree

## Overview

A **Link-Cut Tree** is a data structure for maintaining a forest of trees with
efficient path queries and dynamic connectivity. It supports linking and cutting
edges in O(log n) amortized time.

- **Operations**: O(log n) amortized
- **Space**: O(n)
- **Key Feature**: Dynamic tree structure (add/remove edges)

## The Key Insight

```
Decompose each tree into "preferred paths" stored as splay trees.
The access(x) operation makes x-to-root the preferred path.

Original tree:        Preferred path decomposition:
       1                  Splay tree for path 1-2-4
      /|\                        [2]
     2 3 6                      /   \
    /|                        [1]   [4]
   4 5
                          + separate splay trees for 3, 5, 6
                            (connected via "path-parent" pointers)

After access(4):
  The path 1-2-4 becomes preferred
  All nodes on this path are in one splay tree
```

## Core Operations

```
access(x): Make path from root to x "preferred"
  - Splay x to root of its auxiliary tree
  - Walk up, re-linking preferred children
  - After access, x is root of its splay tree

link(x, y): Connect tree rooted at x under node y
  - access(x), access(y)
  - Make x a child of y

cut(x): Remove edge from x to its parent
  - access(x)
  - Disconnect x from its left child (parent in real tree)

find_root(x): Find root of x's tree
  - access(x)
  - Walk to leftmost node in splay tree
```

## Visual: Access Operation

```
Before access(5):
  Real tree:           Preferred paths:
       1                 [1]──[2]  (path 1-2)
      / \
     2   3               [3]  [5]  (separate)
    / \
   4   5                 [4]

After access(5):
  New preferred path: 1-2-5

  Real tree:           Preferred paths:
       1                 [1]──[2]──[5]  (path 1-2-5)
      / \
     2   3               [3]  [4]  (now separate)
    / \
   4   5

  Node 4 is no longer on preferred path (was 1-2-4, now 1-2-5)
```

## Visual: Link and Cut

```
Link(6, 4):
  Before:          After:
    Tree A           Tree A
       1                1
      / \              / \
     2   3            2   3
    / \              / \
   4   5            4   5
                    |
   Tree B           6
     6              |
     |              7
     7

Cut(4):
  Before:          After:
       1                1          4
      / \              / \        / \
     2   3            2   3      5   6
    / \                          |
   4   5                         7
  / \
 6   7
  (cut edge 2-4)
```

## Algorithm Walkthrough

```
Operations on tree:
       1
      /|\
     2 3 6
    /|
   4 5

access(4):
  1. Splay 4 in its auxiliary tree
  2. Cut 4's right child (none)
  3. Go to path-parent (2), splay 2
  4. Set 4 as 2's right child, clear 2's old right
  5. Go to path-parent (1), splay 1
  6. Set 2 as 1's right child
  7. No more path-parents → done

  Auxiliary tree structure:
         [1]
           \
           [2]
             \
             [4]

  Now 4-2-1 is one splay tree!

find_root(4):
  1. access(4) → 4 is splay root
  2. Go to leftmost: 4 → 2 → 1
  3. Splay 1 to maintain balance
  4. Return 1
```

## Example Usage

```mbt nocheck
// Create link-cut tree with n nodes
let lct = LinkCutTree::new(n)

// Initially all nodes are separate trees
// Link node 2 under node 1
lct.link(2, 1)

// Link node 3 under node 1
lct.link(3, 1)

// Now tree is: 1 with children 2, 3

// Find root of node 2's tree
lct.find_root(2)  // returns 1

// Cut edge from 2 to its parent
lct.cut(2)

// Now 2 is separate from 1
lct.find_root(2)  // returns 2

// Check if connected
lct.connected(1, 3)  // true
lct.connected(1, 2)  // false
```

## Common Applications

### 1. Dynamic Connectivity
```
Maintain connected components with edge insertions/deletions.
Answer "are u and v connected?" queries.
```

### 2. Path Queries
```
With augmented splay trees, support:
- Path sum/min/max
- Path updates (add value to all nodes on path)
```

### 3. Dynamic MST
```
Maintain minimum spanning tree under edge updates.
Use link-cut tree to find cycle when adding edge.
```

### 4. Network Flow
```
Dynamic trees in push-relabel max flow.
Find bottleneck on augmenting paths.
```

## Complexity Analysis

| Operation | Amortized Time |
|-----------|---------------|
| access(x) | O(log n) |
| link(x, y) | O(log n) |
| cut(x) | O(log n) |
| find_root(x) | O(log n) |
| connected(x, y) | O(log n) |
| path_query(x, y) | O(log n) |

## Link-Cut Tree vs Other Structures

| Structure | Dynamic Edges | Path Queries | Subtree Queries |
|-----------|--------------|--------------|-----------------|
| **Link-Cut Tree** | Yes | O(log n) | Hard |
| Euler Tour Tree | Yes | O(log n) | O(log n) |
| Heavy-Light Decomp | No | O(log² n) | O(log n) |
| Static Tree | No | O(log n) | O(log n) |

**Choose Link-Cut Tree when**: You need dynamic edge operations with path queries.

## Path Aggregates

```
To support path sum/min/max, augment splay tree nodes:

struct Node {
  value: Int       // Value at this node
  subtree_sum: Int // Sum of values in splay subtree
  ...
}

When splaying, update subtree_sum:
  node.subtree_sum = left.subtree_sum + right.subtree_sum + node.value

Query path sum x to y:
  1. make_root(x)  // Make x the root
  2. access(y)     // Now path x-y is in one splay tree
  3. Return root's subtree_sum
```

## Implementation Notes

- Each node has: parent, left child, right child, path-parent
- Path-parent connects splay tree roots to their real parents
- Splay operations maintain the splay tree property
- access() is the key operation - everything else builds on it
- Be careful with edge cases: self-loops, disconnected nodes

