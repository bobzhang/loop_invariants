# Binary Trie for XOR Queries

## Overview

A binary trie stores integers by their binary representation, enabling fast
XOR queries. At each bit, we choose the best branch to maximize (or minimize)
XOR with a given query value.

- **Time**: O(B) per operation (B = number of bits)
- **Space**: O(N · B)

## Example

```mbt check
///|
test "binary trie xor example" {
  let trie = @binary_trie_xor.BinaryTrie::new(5)
  trie.insert(5L) // 00101
  trie.insert(1L) // 00001
  trie.insert(7L) // 00111
  inspect(trie.max_xor(2L), content="7")
  inspect(trie.min_xor(2L), content="3")
}
```
