# Splay Tree (Self‑Adjusting BST)

This package documents **splay trees**, a self‑adjusting binary search tree.
Whenever a node is accessed, it is rotated to the root (splayed), giving
**amortized O(log n)** time without storing balance info.

---

## 1. Big idea (beginner friendly)

If you access the same keys often, you want them near the root.

Splaying achieves that:

```
access x -> rotate x to root
recent keys become fast
```

No explicit balancing is needed.

---

## 2. Rotation reminder

Right rotation:

```
      y                x
     / \              / \
    x   C   --->     A   y
   / \                  / \
  A   B                B   C
```

Left rotation is symmetric.  
BST order is preserved.

---

## 3. The three splay cases

### Zig (parent is root)

```
Before:            After:
   p                 x
  / \               / \
 x   C   --->      A   p
/ \                   / \
A  B                 B   C
```

Single rotation.

---

### Zig‑Zig (same direction)

```
Before:                  After:
      g                     x
     / \                   / \
    p   D   --->          A   p
   / \                       / \
  x   C                     B   g
 / \                           / \
A  B                          C   D
```

Rotate **grandparent first**, then parent.

---

### Zig‑Zag (different direction)

```
Before:                  After:
    g                        x
   / \                      / \
  A   p        --->         g   p
     / \                   / \ / \
    x   D                 A  B C  D
   / \
  B   C
```

Rotate x twice: first with parent, then with grandparent.

---

## 4. Step‑by‑step example

Tree before splay(30):

```
          50
         /  \
       25    70
      /  \
     10   30
         /  \
        27   40
```

30 is right child of 25, and 25 is left child of 50 → zig‑zag.

After zig‑zag:

```
          50
         /  \
       30    70
      /  \
     25   40
    /  \
   10   27
```

Now 30’s parent is root → zig:

```
        30
       /  \
     25    50
    / \      \
   10 27      70
          /
         40
```

30 becomes the root.

---

## 5. A more visual mental model

Think of the tree as a bookshelf:

- Books you read often should end up near the front.
- Each access moves that book to the front, possibly shuffling others.
- Even if one access is expensive, repeated accesses become cheaper.

This is move-to-front for trees.

---

## 6. What splaying actually changes (invariants)

Two facts always hold, no matter how many rotations you do:

1. **BST order stays valid.** Rotations rearrange shape, not in-order order.
2. **The accessed node ends as root.** That is the definition of a splay.

Everything else (shape, depths, balance) is allowed to change.

---

## 7. Access sequence example (why it adapts)

Start with the same tree:

```
          50
         /  \
       25    70
      /  \
     10   30
         /  \
        27   40
```

Access keys: **30, 27, 30, 30**.

- Access 30: splay 30 -> it becomes root.
- Access 27: splay 27 -> it becomes root, 30 is now a child.
- Access 30: splay 30 -> it goes back to root quickly (close by).
- Access 30 again: already root -> almost free.

Repeated keys stay shallow, which is exactly what we want.

---

## 8. Typical operations

1. **Search**: find node, then splay it.
2. **Insert**: insert as BST, then splay.
3. **Delete**: splay node, delete root, join subtrees.
4. **Split/Join**: splay pivot, cut, or attach subtrees.

---

## 9. Split and join, step by step

Split by key `k`:

1. Find `k` (or the last node on its search path).
2. Splay that node to root.
3. Everything in the left subtree is `< k`, everything in the right is `> k`.

Diagram:

```
Before split:
        (root)
        /    \
     < k     > k

After splay(k):
        k
      /   \
   < k   > k

Split result:
  left = subtree(< k)
  right = subtree(> k)
```

Join two trees `A` and `B` where all keys in A are smaller:

1. Splay the **maximum** node in A to root.
2. Attach B as the right subtree.

```
A max to root:        Join:
     max                max
    /   \              /   \
  ...  (nil)   +      A     B
```

This keeps the BST invariant.

---

## 10. Deletion example (intuitive)

To delete key `x`:

1. Splay `x` to root.
2. Remove the root.
3. Join the left and right subtrees.

If `x` is not present, the last accessed node is splayed instead, which
still improves future access patterns.

---

## 11. Why it is fast (amortized)

Splaying a deep node costs more now, but it makes the tree better for the
future. Over many operations, this averages to O(log n).

One intuition:

- Moving a node up shortens its future access path.
- Nodes moved down are likely not queried often.
- The overall "disorder" decreases on average after costly splays.

---

## 12. Comparison with balanced trees

- **AVL / Red-Black**: strict balance -> guaranteed O(log n) each op.
- **Splay**: no stored balance -> simpler code, adaptive in practice.

Splay trees are great when access patterns are skewed or repetitive.

---

## 13. Example usage (conceptual)

This package is tutorial-only; it does not export a concrete API.

```mbt nocheck
///|
let tree = SplayTree::new()

tree.insert(5)
tree.insert(3)
tree.insert(7)
tree.insert(1)

tree.find(1) // splayed to root

tree.delete(3)

let (left, right) = tree.split(4)
tree = left.join(right)
```

---

## 14. Common applications

1. **Dynamic sequences** (split/join)
2. **Link-cut trees** (splay trees inside)
3. **Adaptive caches** (recent items stay near root)

---

## 15. Complexity

```
Search / Insert / Delete: O(log n) amortized
Worst case for one op:    O(n)
Space:                   O(n)
```

---

## 16. Beginner checklist

1. Always splay after access.
2. Zig-zig rotates grandparent first.
3. Zig-zag rotates node twice.
4. One operation can be slow, but average is fast.

---

## 17. Summary

Splay trees are self-adjusting BSTs:

- simple rotations,
- no balance metadata,
- adaptive performance with amortized log time.
