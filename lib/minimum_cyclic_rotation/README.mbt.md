# Minimum Cyclic Rotation (Booth's Algorithm)

This package finds the **lexicographically smallest rotation** of a string.
It uses **Booth's algorithm**, which runs in linear time.

If you imagine the string written on a ring, you can cut the ring at any
position to read a rotation. The minimum cyclic rotation is the cut that gives
the smallest string in dictionary order.

## 1. Problem statement (plain language)

Given a string `s` of length `n`, consider all `n` rotations:

```
s = "baca"
rotations:
  start 0 -> "baca"
  start 1 -> "acab"
  start 2 -> "caba"
  start 3 -> "abac"
```

The minimum cyclic rotation is `"abac"` (start index `3`).

If there are ties (e.g. `"abab"`), the algorithm returns the **smallest start
index** among all minimal rotations.

## 2. Visualizing rotations as a ring

```
index:  0   1   2   3
char :  b   a   c   a
          \  |  /
           \ | /
             *
          (wrap)
```

Reading the ring starting at index `i` produces rotation `i`.

## 3. What this package provides

From `pkg.generated.mbti`:

- `min_cyclic_rotation(s : String) -> String`
- `min_cyclic_rotation_index(s : String) -> Int`

Behavior on edge cases:

- Empty string: rotation is `""`, index is `0`.
- Single character: rotation is the same character, index is `0`.

## 4. Why Booth's algorithm works (intuition)

Booth's algorithm compares **two candidate starts** `i` and `j`:

- `k` is how many characters we have matched so far.
- Compare `s[(i+k) % n]` and `s[(j+k) % n]`.
- On a mismatch:
  - if `s[i+k] > s[j+k]`, then **all starts in `i..i+k` are worse than `j`**
  - if `s[i+k] < s[j+k]`, then **all starts in `j..j+k` are worse than `i`**
  - so we skip an entire block of candidates at once

This is what makes it O(n): we never re-check positions that are already
dominated.

### Tiny skip diagram

```
Compare rotations at i and j:

i: [i .......... i+k]  (mismatch at i+k)
j: [j .......... j+k]

If s[i+k] > s[j+k], then starts i..i+k are all worse.
We jump i to i+k+1.
```

## 5. Worked example (detailed)

Let `s = "baca"`, `n = 4`.
Booth compares rotations using the doubled string `"bacabaca"` to avoid
manual wraparound.

We show `(i, j, k)` and the compared characters:

```
Start: i=0, j=1, k=0
  s[0] vs s[1] -> 'b' vs 'a' -> 'b' > 'a'
  i is worse, so i = 2, k = 0

Now:  i=2, j=1, k=0
  s[2] vs s[1] -> 'c' vs 'a' -> 'c' > 'a'
  i is worse, so i = 3, k = 0

Now:  i=3, j=1, k=0
  s[3] vs s[1] -> 'a' vs 'a' -> equal
  k = 1

Now:  i=3, j=1, k=1
  s[0] vs s[2] -> 'b' vs 'c' -> 'b' < 'c'
  j is worse, so j = 4 (>= n), stop
```

Winner is `i = 3`, and the minimum rotation is `"abac"`.

## 6. Example usage (basic)

```mbt check
///|
test "min rotation basic" {
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("baca"), content="abac")
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("baca"),
    content="3",
  )
}
```

## 7. Example: repeated patterns and ties

`"abab"` has two minimal rotations: `"abab"` (start 0) and `"abab"` (start 2).
The smallest index is `0`.

```mbt check
///|
test "min rotation repeated patterns" {
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("abab"), content="abab")
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("abab"),
    content="0",
  )
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("aaaa"), content="aaaa")
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("aaaa"),
    content="0",
  )
}
```

## 8. Example: a clear winner

```
s = "caaab"
rotations:
  0: caaab
  1: aaabc   <- minimum
  2: aabca
  3: abcaa
  4: bcaaa
```

```mbt check
///|
test "min rotation clear winner" {
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation("caaab"),
    content="aaabc",
  )
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("caaab"),
    content="1",
  )
}
```

## 9. Example: canonicalizing cyclic strings (necklace view)

Two strings are rotations of each other iff their minimum rotations match.

```mbt check
///|
fn canon(s : String) -> String {
  @minimum_cyclic_rotation.min_cyclic_rotation(s)
}

///|
test "canonicalization by minimum rotation" {
  inspect(canon("abc"), content="abc")
  inspect(canon("bca"), content="abc")
  inspect(canon("acb"), content="acb")
}
```

## 10. Example: use the index to rotate parallel data

Sometimes you want the **index** so you can rotate other arrays the same way.

```mbt check
///|
fn[T] rotate_array(xs : ArrayView[T], start : Int) -> Array[T] {
  let n = xs.length()
  if n == 0 {
    Array::new()
  } else {
    let shift = start % n
    Array::makei(n, i => xs[(shift + i) % n])
  }
}

///|
test "rotate parallel data by min rotation index" {
  let s = "baca"
  let idx = @minimum_cyclic_rotation.min_cyclic_rotation_index(s)
  let weights : Array[Int] = [10, 20, 30, 40]
  let rotated = rotate_array(weights[:], idx)
  inspect(rotated, content="[40, 10, 20, 30]")
}
```

## 11. Complexity

Booth's algorithm does only O(n) comparisons:

```
Time:  O(n)
Space: O(n)   (uses the doubled string)
```

## 12. Implementation notes

- The algorithm works on `s + s` for easy wraparound.
- Lexicographic order follows the string's code unit order (UTF-16).
- The index result is stable for repeated patterns: it picks the smallest start.

## 13. Related tools

- **Duval's algorithm** (Lyndon factorization) can also find minimum rotation.
- **KMP on s+s** can be used to test if two strings are rotations.
