# Segment Tree Beats (Range Chmin + Sum/Max)

Segment Tree Beats is an advanced segment tree that supports **range chmin**
(clamping values down to a maximum) while still answering **range sum** and
**range max** queries efficiently.

This package provides:

- `range_chmin(l, r, x)`  → set each value to `min(value, x)`
- `range_sum(l, r)`
- `range_max(l, r)`

All in **amortized O(log n)** time.

---

## 1. Why is this hard?

For a normal segment tree, range update = hard, because:

```
range_chmin(l, r, x) may change some elements but not others
```

If we update each element directly, that is O(n).

Segment Tree Beats avoids this by storing **extra info per node** so it can
decide whether a whole segment can be updated at once.

---

## 2. Key node data (the secret sauce)

For each segment, we keep:

```
max         = largest value in segment
second_max  = second largest value (strictly less than max)
count_max   = how many elements equal max
sum         = total sum of segment
```

Example segment: `[5, 3, 5, 2, 5]`

```
max = 5
second_max = 3
count_max = 3
sum = 20
```

---

## 3. How chmin works (three cases)

For `range_chmin(x)` on a node:

**Case A**: `x >= max`

```
Nothing changes.
```

**Case B**: `second_max < x < max`

Only the maximum elements change to `x`.

```
sum -= count_max * (max - x)
max = x
```

**Case C**: `x <= second_max`

We cannot update safely at this node — must recurse to children.

---

## 4. Visual example

Segment: `[5, 3, 5, 2, 5]`

```
max = 5, second_max = 3, count_max = 3
```

Apply `chmin(4)`:

```
second_max < 4 < max  -> Case B
only 5's change to 4

new segment: [4, 3, 4, 2, 4]
sum = 20 - 3*(5-4) = 17
```

Apply `chmin(2)`:

```
2 <= second_max -> Case C
must recurse into children
```

---

## 5. Step‑by‑step walkthrough

Array:

```
[5, 1, 7, 3, 9]
```

Initial root:

```
max = 9, second_max = 7, count_max = 1, sum = 25
```

Operation: `range_chmin(1, 4, 4)`

- Root has `second_max = 7`, so 4 <= 7 → recurse.

Left child [0,3):

```
max = 7, second_max = 5
4 <= 5 -> recurse
```

Right child [3,5):

```
max = 9, second_max = 3
3 < 4 < 9 -> Case B
update max to 4, sum decreases by 1*(9-4)
```

Finally, only some nodes are updated — not the whole range.

---

## 6. Example usage (public API)

```mbt check
///|
test "segment tree beats example" {
  let st = @segment_tree_beats.SegmentTreeBeats::new([5L, 1L, 7L, 3L, 9L])
  inspect(st.range_sum(0, 5), content="25")
  inspect(st.range_max(0, 5), content="9")
  st.range_chmin(1, 4, 4L)
  inspect(st.range_sum(0, 5), content="22")
  inspect(st.range_max(0, 5), content="9")
  st.range_chmin(0, 5, 4L)
  inspect(st.range_sum(0, 5), content="16")
  inspect(st.range_max(0, 5), content="4")
}
```

---

## 7. Another example (clamp all values)

```mbt check
///|
test "segment tree beats clamp" {
  let st = @segment_tree_beats.SegmentTreeBeats::new([10L, 20L, 30L, 40L, 50L])
  st.range_chmin(0, 5, 25L)
  inspect(st.range_sum(0, 5), content="105")
  inspect(st.range_max(0, 5), content="25")
}
```

---

## 8. Why is it amortized O(log n)?

Whenever we are forced to recurse (Case C), we reduce the number of distinct
values in that segment. This can only happen a limited number of times.

The result is:

```
Total work across many operations is O((n + Q) log n)
```

So each operation is **amortized** O(log n).

---

## 9. Common applications

1. **Range clamping** (cap values to a maximum)
2. **Resource allocation** with upper limits
3. **Stock price caps** or thresholding
4. **Image processing** (clamp brightness)

---

## 10. Complexity summary

```
Build:       O(n)
range_chmin: O(log n) amortized
range_sum:   O(log n)
range_max:   O(log n)
Space:       O(n)
```

---

## 11. Beginner checklist

1. `range_chmin(l, r, x)` uses a **half‑open range** [l, r).
2. Only Case B updates a node directly.
3. Case C forces recursion into children.
4. The algorithm relies on tracking max + second_max.

---

## 12. Summary

Segment Tree Beats is a powerful segment tree extension:

- supports range clamping with sums and max,
- avoids full recursion when possible,
- achieves amortized log time per operation.
