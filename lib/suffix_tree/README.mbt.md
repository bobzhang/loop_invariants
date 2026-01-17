# Suffix Tree (Beginner‑Friendly)

A suffix tree is a **compressed trie of all suffixes** of a string.
Once built, it can answer substring queries in **O(m)** time.

This package builds the tree in **O(n²)** (naive insertion), which is easier
to understand and great for education.

---

## 1. What is a suffix tree?

Take all suffixes of a string and insert them into a trie, then compress edges.

Example string: `"banana"`

Suffixes:

```
banana
anana
nana
ana
na
a
```

A suffix tree stores these efficiently so any substring is just a path.

---

## 2. Why append a sentinel?

The implementation appends a sentinel (`\0`) to ensure:

- every suffix ends at a **leaf**,
- no suffix is a prefix of another.

Example `"aa"`:

```
Suffixes without sentinel: "aa", "a"
Suffixes with sentinel:    "aa\0", "a\0", "\0"
```

Now each suffix ends cleanly at a leaf.

---

## 3. Visual structure (compressed edges)

Text: `"banana\0"`

Simplified tree:

```
root
 ├── "a" ── "na" ── "na\0"
 │          └── "\0"
 ├── "banana\0"
 └── "na" ── "na\0"
            └── "\0"
```

Edges are **substrings**, not single characters.

---

## 4. Substring search idea

To check if pattern `P` is a substring:

1. Start at root.
2. Follow edges matching `P`.
3. If you consume all of `P`, it exists.

Time: **O(m)**, where m = length of P.

---

## 5. Counting occurrences

If we find the node representing `P`, then:

```
occurrences = number of leaves under that node
```

Each leaf corresponds to one suffix that contains `P`.

---

## 6. Example usage (public API)

```mbt check
///|
test "suffix tree contains" {
  let tree = @suffix_tree.SuffixTree::new("banana")
  inspect(tree.contains("ana"), content="true")
  inspect(tree.contains("apple"), content="false")
}
```

```mbt check
///|
test "suffix tree count" {
  let tree = @suffix_tree.SuffixTree::new("banana")
  inspect(tree.count_occurrences("ana"), content="2")
  inspect(tree.count_occurrences("na"), content="2")
}
```

---

## 7. Small walkthrough

Text: `"banana"`, query `"ana"`.

```
root -> "a" -> "na"
pattern consumed ✓

Leaves under this node = 2
Occurrences at positions 1 and 3.
```

---

## 8. Complexity

```
Build (this impl): O(n²)
Query:             O(m)
Count occurrences: O(m + k)
```

Where k is number of matches (leaf count).

---

## 9. When to use suffix trees

Good for:

- many substring queries on the same text,
- educational understanding of suffix structures.

Not ideal for huge texts (use Ukkonen’s O(n) algorithm).

---

## 10. Summary

Suffix trees are powerful:

- store all suffixes compactly,
- answer substring queries in linear time,
- support fast occurrence counting.
