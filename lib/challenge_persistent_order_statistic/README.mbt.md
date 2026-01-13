# Persistent Order Statistic Tree

Persistent segment tree that supports kth-order statistics.

## Core Idea

Build a persistent segment tree over a value range [lo, hi). Each update adds
1 to the count at a value. The kth query walks the tree using left subtree
sizes to decide which side contains the target rank.

## Example

```mbt check
///|
test "persistent order statistic" {
  let os0 = @challenge_persistent_order_statistic.make(0, 10)
  let os1 = @challenge_persistent_order_statistic.add(os0, 5)
  let os2 = @challenge_persistent_order_statistic.add(os1, 2)
  let os3 = @challenge_persistent_order_statistic.add(os2, 7)
  let os4 = @challenge_persistent_order_statistic.add(os3, 2)
  inspect(@challenge_persistent_order_statistic.kth(os4, 0), content="Some(2)")
  inspect(@challenge_persistent_order_statistic.kth(os4, 1), content="Some(2)")
  inspect(@challenge_persistent_order_statistic.kth(os4, 2), content="Some(5)")
  inspect(@challenge_persistent_order_statistic.size(os4), content="4")
}
```

## Another Example

```mbt check
///|
test "persistent order statistic small" {
  let os0 = @challenge_persistent_order_statistic.make(0, 5)
  let os1 = @challenge_persistent_order_statistic.add(os0, 4)
  let os2 = @challenge_persistent_order_statistic.add(os1, 1)
  inspect(@challenge_persistent_order_statistic.kth(os2, 0), content="Some(1)")
  inspect(@challenge_persistent_order_statistic.kth(os2, 1), content="Some(4)")
}
```

## Notes

- Duplicate values are allowed (counts increase).
- `kth` returns None when the rank is out of range.
