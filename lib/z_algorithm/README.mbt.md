# Z-Algorithm (Beginner-Friendly Guide)

The Z-algorithm computes, for each position `i`, how long the substring
starting at `i` matches the **prefix** of the string. This gives fast pattern
matching in **linear time**.

This package provides:

```
@z_algorithm.compute_z(s)
@z_algorithm.z_function(s)       // alias
@z_algorithm.find_pattern(text, pattern)
@z_algorithm.z_search(text, pattern) // alias
@z_algorithm.count_pattern(text, pattern)
```

---

## 1) What is the Z-array?

For a string `s`, `Z[i]` = length of the longest prefix match starting at `i`.

Example:

```
s = "aabcaab"
index: 0 1 2 3 4 5 6
char:  a a b c a a b

Z = [7, 1, 0, 0, 3, 1, 0]
```

Why?

- `Z[1] = 1` because `"abcaab"` matches prefix `"a"` for 1 char.
- `Z[4] = 3` because `"aab"` matches prefix `"aab"`.

By convention, `Z[0] = n` (full string length).

---

## 2) The Z-box idea (the trick)

We keep a window `[l, r]` where `s[l..r]` matches the prefix `s[0..r-l]`.

```
s = a a b c a a b
          [-----]   (when i = 4, l = 4, r = 6)
```

If `i` is inside the box, we can reuse information:

```
k = i - l
Z[i] is at least min(Z[k], r - i + 1)
```

Only when we hit the boundary do we expand further.

---

## 3) Walkthrough example

```
s = "aabcaab"

i=1 (outside box): match "a" -> Z[1]=1, box=[1,1]
i=2 (outside): Z[2]=0
i=3 (outside): Z[3]=0
i=4 (outside): match "aab" -> Z[4]=3, box=[4,6]
i=5 (inside):  k=1, Z[1]=1, r-i+1=2 -> Z[5]=1
i=6 (inside):  k=2, Z[2]=0 -> Z[6]=0

Result: [7,1,0,0,3,1,0]
```

---

## 4) Pattern matching with Z

To find a pattern `P` inside text `T`, build:

```
S = P + "$" + T
```

Compute Z on `S`.  
Any position `i` with `Z[i] == |P|` is a match.

Example:

```
P = "ab"
T = "ababab"
S = "ab$ababab"

Z = [9,0,0,2,0,2,0,2,0]
          ^   ^   ^
Matches at indices 3,5,7 in S
=> positions 0,2,4 in T
```

---

## 5) Example usage

```mbt check
///|
test "z array and search" {
  let z = @z_algorithm.compute_z("aabcaab")
  inspect(z, content="[7, 1, 0, 0, 3, 1, 0]")
  let hits = @z_algorithm.find_pattern("aabcaabxaab", "aab")
  inspect(hits, content="[0, 4, 8]")
}
```

```mbt check
///|
test "z aliases" {
  let z2 = @z_algorithm.z_function("aaaaa")
  inspect(z2, content="[5, 4, 3, 2, 1]")
  let hits2 = @z_algorithm.z_search("ababa", "aba")
  inspect(hits2, content="[0, 2]")
}
```

```mbt check
///|
test "count pattern" {
  let cnt = @z_algorithm.count_pattern("aaaaa", "aa")
  inspect(cnt, content="4") // overlaps allowed: "aa" at 0,1,2,3
}
```

---

## 6) Why it is O(n)

The right boundary `r` only moves forward.
Each time we expand, `r` increases. It can only increase `n` times.

So the total work across all expansions is **O(n)**.

---

## 7) Common applications

```
Pattern matching (find all occurrences)
String borders (prefix = suffix)
String period detection
Counting repeated prefixes
```

---

## 8) Z vs KMP

Both do pattern matching in O(n).

```
Z: compares prefixes
KMP: uses failure links
```

Z is often simpler to implement.

---

## 9) Common pitfalls

- Forgetting that `Z[0] = n`.
- Off-by-one in [l, r] vs [l, r) range.
- Not using a separator between pattern and text.
