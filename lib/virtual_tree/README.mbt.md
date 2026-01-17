# Virtual Tree (Beginner-Friendly Guide)

A **virtual tree** is the smallest tree that connects a chosen subset of nodes
in a larger tree. It keeps only:

- the **important nodes** you care about, and
- the **LCAs** (lowest common ancestors) needed to connect them.

This reduces a big tree with `n` nodes to a small tree with **O(k)** nodes,
where `k` is the number of important nodes.

The API in this package:

```
@virtual_tree.build_virtual_tree(
  adj, important, root?
) -> VirtualTree
```

- `adj` is the original tree adjacency list (0-indexed).
- `important` is the list of nodes you care about.
- `root` is optional (default 0).

The result:

- `VirtualTree::nodes` = the node IDs kept in the virtual tree
- `VirtualTree::adj` = adjacency list (same IDs, but only virtual edges)

---

## 1) Why we need a virtual tree

Many problems only care about a small subset of nodes.  
Processing the entire tree each query is too slow.

Virtual tree idea:

```
Big tree (n = 12):             Important nodes = {5, 9, 7}

        0
      / | \
     1  2  3
    /|  |  |
   4 5  6  7
     |     |
     8     9
           |
          10

Virtual tree:
   nodes = {0, 2, 5, 7, 9}
   edges preserve ancestry
```

Instead of processing all 12 nodes, you only touch 5.

---

## 2) The LCA trick

If we keep only the important nodes, we may lose ancestor structure.
So we insert the **LCAs** of consecutive nodes in DFS order.

Example:

```
Tree:
    0
   / \
  1   2
     / \
    3   4

Important nodes: {1, 4}
LCA(1, 4) = 0

Virtual tree nodes: {0, 1, 4}
```

Without LCA 0, the structure would be wrong.

---

## 3) How to build a virtual tree (high-level steps)

1. Run DFS on the original tree to compute:
   - `tin[v]` (entry time)
   - LCA support (binary lifting).
2. Sort important nodes by `tin`.
3. Add LCAs of consecutive nodes.
4. Sort again and deduplicate.
5. Build the virtual tree with a stack.

---

## 4) Visual walkthrough

Original tree:

```
      0
     / \
    1   2
   / \   \
  3   4   5
```

Important nodes: {3, 4, 5}

Step 1: Sort by DFS order (tin)

```
order: [3, 4, 5]
```

Step 2: Add LCAs of consecutive pairs

```
LCA(3, 4) = 1
LCA(4, 5) = 0

nodes = {0, 1, 3, 4, 5}
```

Step 3: Build tree with stack

```
Result:
    0
   / \
  1   5
 / \
3   4
```

Only 5 nodes, but ancestry is preserved.

---

## 5) Example usage (from this package)

```mbt check
///|
test "virtual tree basic example" {
  let adj : Array[Array[Int]] = Array::makei(6, _ => [])
  adj[0].push(1)
  adj[1].push(0)
  adj[0].push(2)
  adj[2].push(0)
  adj[1].push(3)
  adj[3].push(1)
  adj[1].push(4)
  adj[4].push(1)
  adj[2].push(5)
  adj[5].push(2)
  let vt = @virtual_tree.build_virtual_tree(adj, [3, 4, 5])
  inspect(vt.nodes, content="[0, 1, 3, 4, 5]")
  let adj0 = vt.adj[0].copy()
  adj0.sort()
  inspect(adj0, content="[1, 5]")
}
```

---

## 6) Single-node case

If there is only one important node, the virtual tree has just that node.

```mbt check
///|
test "virtual tree single node" {
  let adj : Array[Array[Int]] = Array::makei(3, _ => [])
  adj[0].push(1)
  adj[1].push(0)
  adj[1].push(2)
  adj[2].push(1)
  let vt = @virtual_tree.build_virtual_tree(adj, [2])
  inspect(vt.nodes, content="[2]")
  inspect(vt.adj[2].length(), content="0")
}
```

---

## 7) Common applications

```
Queries on a subset of nodes:
  - sum of distances between marked nodes
  - DP on marked nodes

Per-query preprocessing in tree problems:
  - build virtual tree
  - run DP only on O(k) nodes
```

---

## 8) Complexity

Let:
- `n` = size of original tree
- `k` = number of important nodes

```
LCA preprocess:     O(n log n)
Virtual tree build: O(k log k)
Virtual tree size:  <= 2k - 1
```

---

## 9) Common pitfalls

- Forgetting to add LCAs (breaks structure).
- Mixing up `tin` order (must sort by DFS entry time).
- Passing a graph that is not a tree (virtual tree assumes a tree).
