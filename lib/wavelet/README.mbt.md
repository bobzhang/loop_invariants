# Wavelet Tree (Beginner-Friendly Guide)

A wavelet tree is a data structure for fast **range queries** on a static array
of integers. It answers queries like:

- "How many values equal x in [l, r)?"
- "How many values are < x in [l, r)?"
- "What is the k-th smallest value in [l, r)?"

It does this in **O(log S)** time per query, where **S** is the value range
(alphabet size).

This package contains a wavelet tree implementation used in tests. The types
are private, so the examples below are conceptual.

---

## 1) Core idea (split by value, track with bits)

At each node, we split values by a midpoint:

```
left child  = values < mid
right child = values >= mid
```

We store a **bitvector** that records where each element went:

```
bit = 0 -> went left
bit = 1 -> went right
```

We also store a **prefix sum** of the bits, so we can map ranges quickly.

---

## 2) A small build example

Array:

```
A = [3, 0, 1, 2, 3, 1, 2, 0]
values in [0, 4)
```

At the root:

```
lo = 0, hi = 4, mid = 2

values < 2  -> left
values >= 2 -> right

A:    3 0 1 2 3 1 2 0
bits: 1 0 0 1 1 0 1 0

left values:  [0, 1, 1, 0]
right values: [3, 2, 3, 2]
```

Then recurse on each child range:

```
Left child range [0, 2):
  mid = 1
  [0, 1, 1, 0] -> bits: [0,1,1,0]
  left:  [0,0]
  right: [1,1]

Right child range [2, 4):
  mid = 3
  [3, 2, 3, 2] -> bits: [1,0,1,0]
  left:  [2,2]
  right: [3,3]
```

At leaves (range size 1), recursion stops.

---

## 3) How queries work

All queries follow the same pattern:

1) Look at the current node's bitvector.
2) Use prefix sums to map [l, r) into the left or right child.
3) Recurse.

The tree height is O(log S), so each query is O(log S).

---

## 4) Range count (how many equal x in [l, r)?)

Example:

```
count value 1 in A[0, 8)
A = [3,0,1,2,3,1,2,0]
```

Walk down:

- At root (range [0,4), mid=2):
  value 1 goes left.
  left positions in [0,8) = number of zeros in bits[0,8) = 4
  new range = [0,4) in left child.

- At left child (range [0,2), mid=1):
  value 1 goes right.
  right positions in [0,4) = number of ones in bits[0,4) = 2
  new range = [0,2) in right child.

- At leaf (value=1):
  answer = length of range = 2

So there are 2 ones in the array, which is correct.

---

## 5) Range count less than x

This counts how many values are < x in [l, r).

Idea:

- If x is entirely in the left range, go left.
- If x crosses mid, then:
  - all values in left are < x (count them),
  - plus recursive count in right for the remainder.

This is similar to a binary search down the value range.

---

## 6) K-th smallest (quantile)

`kth(l, r, k)` returns the k-th smallest value in [l, r), 0-indexed.

Example:

```
A = [3,0,1,2,3,1,2,0]
range [0,8), k=3 (4th smallest)
sorted: [0,0,1,1,2,2,3,3] -> answer = 1
```

At root:

- left_count = number of zeros in bits[0,8) = 4
- k=3 < 4, so go left

At left child:

- left_count = number of zeros in bits[0,4) = 2
- k=3 >= 2, so go right with k = 3 - 2 = 1

At leaf (value=1):
answer = 1

---

## 7) Why the bitvector matters

The prefix sum of bits lets us map a range quickly:

```
bits:   1 0 0 1 1 0 1 0
prefix: 0 1 1 1 2 3 3 4 4  (prefix[i] = #ones in bits[0..i))

For range [l, r):
  right_count = prefix[r] - prefix[l]
  left_count  = (r - l) - right_count
```

We use these counts to compute the new [l, r) in each child.

---

## 8) Complexity

```
Build: O(n log S)
Queries: O(log S)
Space: O(n log S)
```

S is the value range size (max value + 1).

---

## 9) Common use cases

```
Range quantile queries (k-th smallest)
Range frequency queries (count of x)
Range count of values < x
Static arrays with many queries
```

---

## 10) Common pitfalls

- Values must be in a known range [0, S).
- This is best for static arrays (updates are hard).
- Off-by-one errors in [l, r) ranges are common.
