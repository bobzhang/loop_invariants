# Block-Cut Tree

## Overview

The block-cut tree is a bipartite representation of an undirected graph that
connects **biconnected components** (blocks) with the **vertices** they contain.
Articulation points appear in multiple blocks, while non-articulation vertices
appear in exactly one.

Node indexing in the tree:
- Original vertices: `0 .. n-1`
- Component nodes: `n .. n + c - 1`

- **Time**: O(V + E)
- **Space**: O(V + E)

## Example

```mbt check
///|
test "block-cut tree example" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (1, 3)]
  let tree = @block_cut_tree.build_block_cut_tree(4, edges[:])
  let comp0 = 4
  let comp1 = 5
  let comp0_tri = tree.adj[comp0].length() == 3 &&
    tree.adj[comp0].contains(0) &&
    tree.adj[comp0].contains(1) &&
    tree.adj[comp0].contains(2)
  let comp1_tri = tree.adj[comp1].length() == 3 &&
    tree.adj[comp1].contains(0) &&
    tree.adj[comp1].contains(1) &&
    tree.adj[comp1].contains(2)
  let comp0_edge = tree.adj[comp0].length() == 2 &&
    tree.adj[comp0].contains(1) &&
    tree.adj[comp0].contains(3)
  let comp1_edge = tree.adj[comp1].length() == 2 &&
    tree.adj[comp1].contains(1) &&
    tree.adj[comp1].contains(3)
  assert_true((comp0_tri && comp1_edge) || (comp1_tri && comp0_edge))
}
```
