# Block-Cut Tree

A **block-cut tree** turns an undirected graph into a tree (or forest) that
makes articulation structure explicit. It connects:

- **Block nodes**: biconnected components (blocks)
- **Vertex nodes**: original graph vertices

An articulation point appears in multiple blocks, so it connects to multiple
block nodes. This makes many connectivity questions easier because the result
is a tree.

## Problem statement

Given an undirected graph, build a tree where:

- Each biconnected component becomes a node.
- Each original vertex is also a node.
- A block node connects to every vertex it contains.

The resulting graph is a tree for each connected component of the original
graph (so overall it is a forest).

## Why this is useful

The block-cut tree separates "robust" subgraphs (blocks) from articulation
points (single points of failure). Once you have the tree, you can:

- Ask connectivity questions with articulation awareness
- Run LCA or distance queries on the tree
- Compress a complex graph into a tree structure

## Output format in this package

`build_block_cut_tree(n, edges)` returns a `BlockCutTree` with:

- `original_vertices`: number of original vertices `n`
- `component_count`: number of biconnected components `c`
- `adj`: adjacency list of the block-cut tree

Node indexing:

- Original vertices: `0 .. n-1`
- Component nodes: `n .. n + c - 1`

So if `n = 4` and `c = 2`, the block nodes are `4` and `5`.

## Example 1: triangle with a tail

Graph:

```
0---1---3
 \ /
  2
```

Biconnected components:
- Triangle (0,1,2)
- Edge (1,3)

Block-cut tree has two block nodes, one connected to `{0,1,2}` and one to
`{1,3}`.

```mbt check
///|
test "triangle with tail" {
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

### What the tree looks like

```
(block node for triangle)
   /   |   \
  0    1    2
       |
(block node for edge 1-3)
       |
       3
```

Vertex `1` appears in both blocks, so it is the articulation point.

## Example 2: a simple cycle

A cycle has no articulation points. The block-cut tree has one block node
connected to all vertices.

```mbt check
///|
test "cycle becomes one block" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3), (3, 0)]
  let tree = @block_cut_tree.build_block_cut_tree(4, edges[:])
  let block = 4
  inspect(tree.adj[block].length(), content="4")
  assert_true(tree.adj[block].contains(0))
  assert_true(tree.adj[block].contains(1))
  assert_true(tree.adj[block].contains(2))
  assert_true(tree.adj[block].contains(3))
}
```

## Example 3: disconnected graph

Each connected component produces its own block-cut tree component.

```mbt check
///|
test "disconnected graph" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (3, 4)]
  let tree = @block_cut_tree.build_block_cut_tree(6, edges[:])
  // There are three blocks: (0,1), (1,2), (3,4)
  inspect(tree.component_count, content="3")
}
```

## Practical notes and pitfalls

- The algorithm assumes an **undirected** graph.
- Component nodes connect to all vertices in that block.
- Articulation points appear in multiple blocks; non-articulation vertices
  appear in exactly one block.

## Complexity

- Time: O(V + E)
- Space: O(V + E)

## When to use it

Use a block-cut tree when you need:

- Articulation-aware connectivity queries
- A tree representation for LCA / path queries
- A structural decomposition of an undirected graph
