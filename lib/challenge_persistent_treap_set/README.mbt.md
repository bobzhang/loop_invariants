# Persistent Treap Set

Random-priority BST supporting immutable inserts.

## Core Idea

Treaps maintain the BST property by key and the heap property by random
priority. Persistence is achieved by copying nodes along the insert path,
sharing the rest.

## Example

```mbt check
///|
test "persistent treap set" {
  let t0 = @challenge_persistent_treap_set.empty()
  let t1 = @challenge_persistent_treap_set.insert(t0, 5)
  let t2 = @challenge_persistent_treap_set.insert(t1, 2)
  let t3 = @challenge_persistent_treap_set.insert(t2, 8)
  inspect(@challenge_persistent_treap_set.contains(t3, 2), content="true")
  inspect(@challenge_persistent_treap_set.contains(t3, 6), content="false")
  inspect(@challenge_persistent_treap_set.size(t3), content="3")
}
```

## Another Example

```mbt check
///|
test "persistent treap set from array" {
  let t = @challenge_persistent_treap_set.from_array([3, 1, 4][:])
  inspect(@challenge_persistent_treap_set.contains(t, 1), content="true")
  inspect(@challenge_persistent_treap_set.size(t), content="3")
}
```

## Notes

- Each insert returns a new version.
- Expected time per operation is O(log n).
