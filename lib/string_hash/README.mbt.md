# String Hashing (Rolling Hash)

This package provides a simple **string hashing** helper for pattern matching.
It uses a polynomial rolling hash to find all occurrences of a pattern.

---

## 1. Big idea (beginner friendly)

Turn a string into a number:

```
hash("abc") = 'a'*B^2 + 'b'*B + 'c'
```

With prefix hashes, you can get the hash of any substring in O(1).

That makes pattern matching very fast.

---

## 2. Rolling hash formula

```
prefix[0] = 0
prefix[i] = prefix[i-1]*B + s[i-1]   (mod M)

hash(l, r) = prefix[r+1] - prefix[l] * B^(r-l+1)
```

If negative, add M.

---

## 3. Small visual example

Text: `"abababab"`
Pattern: `"aba"`

```
window 0: "aba" -> hash matches
window 1: "bab" -> hash no
window 2: "aba" -> match
window 3: "bab" -> no
window 4: "aba" -> match
```

Result: [0, 2, 4]

---

## 4. Example usage (public API)

```mbt check
///|
test "string hash example" {
  let hits = @string_hash.hash_pattern_match("abababab", "aba")
  inspect(hits, content="[0, 2, 4]")
}
```

---

## 5. Why collisions matter

Different strings can share the same hash.

For correctness‑critical tasks:

- verify by direct comparison when hashes match, or
- use double hashing.

---

## 6. Complexity

```
Build prefix hash: O(n)
Each window check: O(1)
Total: O(n + m) expected
```

---

## 7. Summary

String hashing is a fast, practical tool:

- O(1) substring hash,
- great for multiple pattern checks,
- very simple to implement.
