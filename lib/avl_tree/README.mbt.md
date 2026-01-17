# AVL Tree (Self-Balancing BST)

An AVL tree is a binary search tree (BST) that *keeps itself balanced* after
insertions and deletions. The benefit is predictable performance: lookups,
insertions, and deletions are always O(log n), even when the input order is
adversarial (like already-sorted data).

This package exposes a small public helper (`avl_sorted`) and contains a full
AVL implementation used in the tests. The README focuses on the ideas and
shows multiple working examples with the public API.

## Problem: a BST can become a chain

A plain BST has fast average performance, but it can become extremely tall if
keys arrive in sorted order:

```
Insert 1, 2, 3, 4

1
 \
  2
   \
    3
     \
      4
```

This tree has height 4, so searches can cost O(n). We want the height to stay
small automatically.

## AVL idea: keep balance factors in {-1, 0, +1}

For every node, the AVL tree stores its height. The *balance factor* is:

```
balance = height(right) - height(left)
```

An AVL tree requires `balance` to be -1, 0, or +1 for every node. If an insert
or delete breaks this rule, we fix it with a rotation.

## Rotations (local fixes that preserve order)

Rotations are small pointer rearrangements that restore balance without
changing the in-order sequence of keys.

### Right rotation (left-heavy)

```
    y                 x
   / \               / \
  x   C   --->      A   y
 / \                   / \
A   B                 B   C
```

### Left rotation (right-heavy)

```
  x                     y
 / \                   / \
A   y      --->        x   C
   / \               / \
  B   C             A   B
```

### Double rotations (zig-zag shapes)

- Left-Right: rotate left on the left child, then right on the node.
- Right-Left: rotate right on the right child, then left on the node.

These cases happen when you insert into the "inner" grandchild.

## What this package provides

`avl_sorted` inserts all keys into an AVL tree and returns the in-order
traversal. That traversal is always sorted, and duplicates are preserved.

## Examples

### Example 1: duplicates are preserved

```mbt check
///|
test "avl_sorted keeps duplicates" {
  let sorted = @avl_tree.avl_sorted([3L, 1L, 4L, 1L][:])
  inspect(sorted, content="[1, 1, 3, 4]")
}
```

### Example 2: already-sorted input still works

In a plain BST this would create a chain, but AVL rebalances internally.
You still get a correct sorted order in O(log n) time per insertion.

```mbt check
///|
test "sorted and reverse-sorted inputs" {
  let ascending = Array::makei(7, i => (i + 1).to_int64())
  let ascending_sorted = @avl_tree.avl_sorted(ascending[:])
  inspect(ascending_sorted, content="[1, 2, 3, 4, 5, 6, 7]")
  let descending = Array::makei(7, i => (7 - i).to_int64())
  let descending_sorted = @avl_tree.avl_sorted(descending[:])
  inspect(descending_sorted, content="[1, 2, 3, 4, 5, 6, 7]")
}
```

### Example 3: a zig-zag input (Left-Right case)

The input `[3, 1, 2]` triggers a left-right rotation internally. The AVL tree
fixes the imbalance while keeping the in-order traversal correct.

```mbt check
///|
test "zig-zag insertion input" {
  let sorted = @avl_tree.avl_sorted([3L, 1L, 2L][:])
  inspect(sorted, content="[1, 2, 3]")
}
```

### Example 4: string keys (any type with Compare)

```mbt check
///|
test "string keys" {
  let sorted = @avl_tree.avl_sorted(["pear", "plum", "kiwi", "date"][:])
  inspect(sorted, content="[\"date\", \"kiwi\", \"pear\", \"plum\"]")
}
```

### Example 5: large batch, still deterministic

Even for larger inputs, AVL keeps the height bounded and the output sorted.

```mbt check
///|
test "larger input" {
  let data = Array::makei(50, i => ((i * 37 + 13) % 50).to_int64())
  let sorted = @avl_tree.avl_sorted(data[:])
  inspect(sorted.length(), content="50")
  inspect(sorted[0], content="0")
  inspect(sorted[49], content="49")
}
```

## How deletion is handled (conceptual)

Deletion in AVL follows standard BST deletion, then rebalances:

1. Remove the node (or swap with its inorder successor if it has two children).
2. Update heights on the path back to the root.
3. Perform rotations when a balance factor becomes -2 or +2.

The key idea is that *only the path from the deleted node to the root* can
become unbalanced, so the fix remains O(log n).

## Complexity

- Insert / Search / Delete: O(log n)
- Space: O(n)

## When to use AVL

Use AVL trees when you need strict worst-case bounds. If you expect heavy
updates and slightly looser balancing is acceptable, a red-black tree may
perform fewer rotations in practice.
