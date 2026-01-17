# Trie (Prefix Tree) - Beginner-Friendly Guide

A **trie** stores strings so that **common prefixes share the same path**.
This makes prefix queries and autocomplete fast.

This package implements:

- a classic trie for lowercase letters `a..z`
- a compressed trie (radix tree) for saving space

The implementation is internal, but the tests show how to use it.

---

## 1) Why a trie?

Consider these words:

```
car, card, care, cat
```

A normal set stores each word separately.  
A trie stores shared prefixes once:

```
root
 |
'c'
 |
'a'
 / \
'r'   't'
 |     |
 |     [end]
 |
[end]--'d'--[end]
 |
 'e'--[end]
```

`[end]` marks a complete word.

Prefix queries like `"ca"` or `"car"` are now just a path walk.

---

## 2) Core operations (all O(length))

If `m` is the word length:

- Insert: O(m)
- Search exact word: O(m)
- Starts-with prefix: O(m)
- Count words with a prefix: O(m)
- Autocomplete: O(m + output size)

---

## 3) Basic trie (lowercase a..z)

### Conceptual structure

Each node has:

- `children[26]` for letters
- `is_end` (is this a full word?)
- `count` (how many times word ends here)
- `prefix_count` (how many words share this prefix)

This implementation only accepts lowercase letters `a..z`.  
Other characters are skipped.

---

## 4) Example 1: insert + search

```mbt nocheck
///|
test "trie insert and search" {
  let trie = Trie::new()
  trie.insert("hello")
  trie.insert("world")
  trie.insert("help")
  inspect(trie.search("hello"), content="true")
  inspect(trie.search("help"), content="true")
  inspect(trie.search("hell"), content="false")
}
```

---

## 5) Example 2: prefix queries

```mbt nocheck
///|
test "trie prefix queries" {
  let trie = Trie::new()
  trie.insert("car")
  trie.insert("card")
  trie.insert("care")
  trie.insert("cat")
  inspect(trie.starts_with("ca"), content="true")
  inspect(trie.count_prefix("ca"), content="4")
  inspect(trie.count_prefix("car"), content="3")
  inspect(trie.count_prefix("dog"), content="0")
}
```

---

## 6) Example 3: duplicates

Duplicates are tracked with `count`.

```mbt nocheck
///|
test "trie duplicates" {
  let trie = Trie::new()
  trie.insert("hello")
  trie.insert("hello")
  trie.insert("hello")
  inspect(trie.count_word("hello"), content="3")
  inspect(trie.count_prefix("hello"), content="3")
}
```

---

## 7) Example 4: delete

`delete` removes **one** copy.

```mbt nocheck
///|
test "trie delete one copy" {
  let trie = Trie::new()
  trie.insert("hello")
  trie.insert("hello")
  inspect(trie.count_word("hello"), content="2")
  inspect(trie.delete("hello"), content="true")
  inspect(trie.count_word("hello"), content="1")
  inspect(trie.search("hello"), content="true")
  inspect(trie.delete("hello"), content="true")
  inspect(trie.search("hello"), content="false")
}
```

---

## 8) Example 5: autocomplete

Autocomplete returns all words with a prefix.

```mbt nocheck
///|
test "trie autocomplete" {
  let trie = Trie::new()
  trie.insert("car")
  trie.insert("card")
  trie.insert("care")
  trie.insert("cat")
  let results = trie.autocomplete("car")
  inspect(results.length(), content="3") // car, card, care
}
```

---

## 9) Example 6: longest prefix

Find the longest prefix of a word that exists in the trie.

```mbt nocheck
///|
test "trie longest prefix" {
  let trie = Trie::new()
  trie.insert("a")
  trie.insert("app")
  trie.insert("apple")
  inspect(trie.longest_prefix("application"), content="app")
  inspect(trie.longest_prefix("apple"), content="apple")
  inspect(trie.longest_prefix("appetizer"), content="app")
}
```

---

## 10) Compressed trie (radix tree)

The compressed trie stores **strings on edges** instead of single characters.
This reduces memory when many nodes have only one child.

Example:

```
Normal trie for:
  test, testing, tested

root - t - e - s - t - [end]
                         |
                         i - n - g - [end]
                         |
                         e - d - [end]

Compressed trie:
root
 |
"test" [end]
   |
  "ing" [end]
   |
  "ed" [end]
```

The implementation here supports insert and search.

```mbt nocheck
///|
test "compressed trie basic" {
  let trie = CompressedTrie::new()
  trie.insert("test")
  trie.insert("testing")
  trie.insert("tested")
  inspect(trie.search("test"), content="true")
  inspect(trie.search("testing"), content="true")
  inspect(trie.search("tested"), content="true")
  inspect(trie.search("tes"), content="false")
}
```

---

## 11) Common pitfalls

- This trie is **lowercase only** (`a..z`).
  Non-lowercase letters are skipped.
- Autocomplete output order depends on traversal order (lexicographic here).
- The structure is mutable; if you need persistence, use a persistent trie.

---

## 12) Complexity summary

```
Operation            Time
--------------------------------
insert/search         O(m)
starts_with           O(m)
count_prefix          O(m)
autocomplete          O(m + output)
delete                O(m)
```

`m` = string length.
