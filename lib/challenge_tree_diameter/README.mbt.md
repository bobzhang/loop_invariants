# Challenge: Tree Diameter

Two BFS/DFS sweeps to find the longest path length in a tree.

## Example

```mbt check
///|
test "tree diameter example" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3), (3, 4)]
  inspect(@challenge_tree_diameter.tree_diameter(5, edges[:]), content="4")
}
```
