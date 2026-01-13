# Binary Trie for XOR Queries

## Overview

A binary trie stores integers by their binary representation, enabling fast
XOR queries. At each bit, we choose the best branch to maximize (or minimize)
XOR with a given query value.

- **Time**: O(B) per operation (B = number of bits)
- **Space**: O(N · B)

## Quick Start

1. Choose a bit width `max_bits` (highest bit index you will query).
2. `insert` values into the trie.
3. `max_xor`/`min_xor` answer best matches.

```mbt check
///|
test "binary trie xor quick start" {
  // max_bits = 5 means the trie stores bits [5..0]
  let trie = @binary_trie_xor.BinaryTrie::new(5)
  trie.insert(5L) // 0b00101
  trie.insert(1L) // 0b00001
  trie.insert(7L) // 0b00111
  inspect(trie.size(), content="3")
  inspect(trie.max_xor(2L), content="7")
  inspect(trie.min_xor(2L), content="3")
}
```

## Choosing `max_bits`

If your values are up to `2^k - 1`, use `max_bits = k - 1`.
For example, values in `[0, 63]` fit in 6 bits, so use `max_bits = 5`.

## Duplicate Keys and Deletion

The trie keeps a count per node, so duplicates are allowed and removal is safe.

```mbt check
///|
test "binary trie delete and duplicates" {
  let trie = @binary_trie_xor.BinaryTrie::new(5)
  trie.insert(5L)
  trie.insert(5L)
  inspect(trie.size(), content="2")
  inspect(trie.remove(5L), content="true")
  inspect(trie.size(), content="1")
  inspect(trie.remove(5L), content="true")
  inspect(trie.size(), content="0")
  inspect(trie.remove(5L), content="false")
}
```

## API Summary

- `BinaryTrie::new(max_bits)` create an empty trie.
- `insert(x)` insert one key.
- `remove(x)` remove one key if present.
- `max_xor(x)` / `min_xor(x)` best XOR with `x`.
- `size()` number of stored keys.
