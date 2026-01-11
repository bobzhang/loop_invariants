# Persistent AVL Set

Self-balancing BST with path-copying insertions.

## Example

```mbt check
///|
test "persistent avl set" {
  let t0 = @challenge_persistent_avl_set.empty()
  let t1 = @challenge_persistent_avl_set.insert(t0, 3)
  let t2 = @challenge_persistent_avl_set.insert(t1, 1)
  let t3 = @challenge_persistent_avl_set.insert(t2, 4)
  inspect(@challenge_persistent_avl_set.contains(t3, 1), content="true")
  inspect(@challenge_persistent_avl_set.contains(t3, 2), content="false")
  inspect(@challenge_persistent_avl_set.inorder(t3), content="[1, 3, 4]")
}
```
