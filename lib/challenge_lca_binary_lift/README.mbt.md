# Challenge: LCA (Binary Lifting)

Lowest common ancestor with O(log n) queries after preprocessing.

## Example

```mbt check
///|
test "lca example" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5)]
  let tree = @challenge_lca_binary_lift.build_lca(6, edges[:], 0)
  inspect(@challenge_lca_binary_lift.lca(tree, 3, 4), content="1")
}
```

## Another Example

```mbt check
///|
test "lca across subtrees" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5)]
  let tree = @challenge_lca_binary_lift.build_lca(6, edges[:], 0)
  inspect(@challenge_lca_binary_lift.lca(tree, 4, 5), content="0")
}
```
