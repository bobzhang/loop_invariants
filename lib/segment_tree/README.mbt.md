# Segment Tree (Range Sum, Point Update)

This package implements a classic **segment tree** for range sum queries and
point updates.

Segment trees are perfect when you need:

- fast range queries in **O(log n)**,
- fast point updates in **O(log n)**,
- operations beyond simple sums (min, max, gcd, etc.).

---

## 1. Big idea (beginner friendly)

A segment tree is a binary tree over array ranges.

Each node stores the **sum of its range**.

Example array `[1, 2, 3, 4, 5]`:

```
                    [0..4] = 15
                   /           \
            [0..2] = 6        [3..4] = 9
            /      \           /     \
      [0..1]=3   [2]=3     [3]=4   [4]=5
       /   \
   [0]=1  [1]=2
```

---

## 2. Range query walkthrough

Query sum of [1, 3]:

```
Root [0..4] overlaps -> go both sides

[0..2] overlaps:
  [0..1] overlaps -> take [1] = 2
  [2] fully inside -> take 3

[3..4] overlaps:
  [3] inside -> take 4
  [4] outside -> ignore

Total = 2 + 3 + 4 = 9
```

So the query touches only O(log n) nodes.

---

## 3. Point update walkthrough

Update index 2 from 3 to 10:

```
Before:               After:
  [0..4]=15             [0..4]=22
  /      \              /      \
[0..2]=6 [3..4]=9   [0..2]=13 [3..4]=9
    \                     \
   [2]=3                [2]=10
```

We update the leaf and recompute sums on the path to the root.

---

## 4. Example usage (public API)

```mbt check
///|
test "segment tree range sum" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L, 5L]
  let st = @segment_tree.SegmentTree::new(arr)
  inspect(st.query(0, 4), content="15")
  inspect(st.query(1, 3), content="9")
  inspect(st.query(2, 2), content="3")
}
```

```mbt check
///|
test "segment tree update" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L]
  let st = @segment_tree.SegmentTree::new(arr)
  inspect(st.query(0, 3), content="10")
  st.update(2, 10L)
  inspect(st.query(0, 3), content="17")
  inspect(st.query(2, 3), content="14")
}
```

---

## 5. Tournament bracket intuition

Think of the tree like a tournament:

```
Array: [5] [3] [7] [2]
         \ /    \ /
       [8]      [9]
           \    /
            [17]
```

Each internal node combines its children.

If you store min instead of sum, the root gives the minimum.

---

## 6. Common applications

1. **Range sum / min / max / gcd**
2. **Dynamic statistics** (update elements frequently)
3. **Interval queries** in geometry and games
4. **Competitive programming** range problems

---

## 7. Complexity

```
Build:  O(n)
Query:  O(log n)
Update: O(log n)
Space:  O(n)
```

---

## 8. Segment tree vs Fenwick tree

```
Fenwick: simpler, small memory, but only for invertible ops (sum, xor)
Segment: supports any associative operation (min, max, gcd), more flexible
```

---

## 9. Beginner checklist

1. The input array is 0‑indexed.
2. Query range [l, r] is inclusive.
3. Updates change one element at a time.
4. The tree size is ~4n for safety.

---

## 10. Summary

Segment trees are the go‑to tool for fast range queries with updates:

- O(log n) per query/update
- supports many operations
- simple once you visualize the range tree
