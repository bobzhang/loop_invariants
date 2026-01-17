# Subset Convolution (Beginner‑Friendly)

Subset convolution combines two functions over all **subsets** of a set.

For each subset S:

```
h[S] = Σ_{T ⊆ S} f[T] · g[S \ T]
```

So we split S into T and the rest, multiply, and sum.

---

## 1. Why this is useful

Subset DP problems often need:

```
"Split a set into two parts and combine the answers."
```

Subset convolution does this efficiently in **O(n^2 · 2^n)** instead of O(3^n).

---

## 2. Tiny example (n = 2)

Let universe = {0,1}.

Subsets:

```
00 = ∅
01 = {0}
10 = {1}
11 = {0,1}
```

For S = {0,1}:

```
h[{0,1}] =
  f[∅]·g[{0,1}] +
  f[{0}]·g[{1}] +
  f[{1}]·g[{0}] +
  f[{0,1}]·g[∅]
```

That is all ways to partition S.

---

## 3. Worked example (from README test)

```
f = [1, 2, 3, 4]
g = [5, 6, 7, 8]
```

Interpretation:

```
f[∅]=1, f[{0}]=2, f[{1}]=3, f[{0,1}]=4
g[∅]=5, g[{0}]=6, g[{1}]=7, g[{0,1}]=8
```

Compute h:

```
h[∅]      = 1*5 = 5
h[{0}]    = 1*6 + 2*5 = 16
h[{1}]    = 1*7 + 3*5 = 22
h[{0,1}]  = 1*8 + 2*7 + 3*6 + 4*5 = 60
```

So:

```
h = [5, 16, 22, 60]
```

---

## 4. Example usage (public API)

```mbt check
///|
test "subset convolution quick start" {
  let f : Array[Int64] = [1L, 2L, 3L, 4L]
  let g : Array[Int64] = [5L, 6L, 7L, 8L]
  let h = @subset_convolution.subset_convolution(f[:], g[:])
  inspect(h, content="[5, 16, 22, 60]")
}
```

---

## 5. How the algorithm speeds up

Naive:

```
For each S, enumerate all subsets T of S.
Total work ~ Σ 2^|S| = 3^n
```

Optimized:

1. Group subsets by **popcount** (number of bits).
2. Use zeta transform to handle subset sums.
3. Convolve by size like polynomial multiplication.

Total time: **O(n^2 · 2^n)**.

---

## 6. Why popcount stratification works

If we define:

```
F[k][S] = f[S] if |S| = k else 0
G[k][S] = g[S] if |S| = k else 0
```

Then:

```
H[k][S] = Σ_{i=0..k} F[i][S] · G[k-i][S]
```

This is a simple convolution over sizes.

---

## 7. When to use subset convolution

Use it for:

- **partitioning DP** on subsets,
- **counting ways** to split sets,
- problems with "choose subset, rest goes to others".

---

## 8. Complexity

```
Time:  O(n^2 · 2^n)
Space: O(n · 2^n)
```

Practical for n ≤ 20.

---

## 9. Beginner checklist

1. Input size is 2^n (array indexed by bitmasks).
2. Complexity is large, so n should be small (<= 20).
3. This is **not** XOR/OR/AND convolution.
4. The formula always uses S \ T (disjoint partition).

---

## 10. Summary

Subset convolution efficiently combines subset DP values by partitioning sets.

It is a powerful tool for small‑n combinatorial problems.
