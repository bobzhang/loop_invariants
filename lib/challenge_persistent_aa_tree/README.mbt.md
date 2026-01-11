# Persistent AA Tree

Balanced binary search tree with skew/split rebalancing and path copying.

## Example

```mbt check
///|
test "persistent aa tree" {
  let t0 = @challenge_persistent_aa_tree.empty()
  let t1 = @challenge_persistent_aa_tree.insert(t0, 5)
  let t2 = @challenge_persistent_aa_tree.insert(t1, 2)
  let t3 = @challenge_persistent_aa_tree.insert(t2, 8)
  inspect(@challenge_persistent_aa_tree.contains(t3, 2), content="true")
  inspect(@challenge_persistent_aa_tree.contains(t3, 7), content="false")
  inspect(@challenge_persistent_aa_tree.inorder(t3), content="[2, 5, 8]")
}
```
