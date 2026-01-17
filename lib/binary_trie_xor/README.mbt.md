# Binary Trie for XOR Queries

A binary trie stores integers bit by bit and answers XOR queries quickly. It is
especially useful for problems like:

- "What is the maximum XOR value with x?"
- "What is the minimum XOR value with x?"

Brute force checks all numbers and costs O(n) per query. The trie reduces this
to O(B), where B is the number of bits.

## Key idea: greedily choose bits

XOR is decided bit by bit from most significant to least significant. At each
bit position:

- To **maximize** XOR, you want the opposite bit if it exists.
- To **minimize** XOR, you want the same bit if it exists.

The trie lets you check whether that desired bit exists among the stored
numbers at the current prefix.

## What this package provides

`BinaryTrie` supports:

- `insert(x)` and `remove(x)`
- `max_xor(x)` and `min_xor(x)`
- `size()`

Duplicates are supported by reference counts in each node.

## Example 1: basic usage

```mbt check
///|
test "basic xor queries" {
  let trie = @binary_trie_xor.BinaryTrie::new(3) // bits 3..0
  trie.insert(5L) // 0101
  trie.insert(1L) // 0001
  trie.insert(7L) // 0111
  inspect(trie.size(), content="3")
  inspect(trie.max_xor(2L), content="7") // 2 xor 5 = 7
  inspect(trie.min_xor(2L), content="3") // 2 xor 1 = 3
}
```

Note: `max_xor` and `min_xor` return the **XOR value**, not the actual key.

## Example 2: duplicates and removal

```mbt check
///|
test "duplicates and remove" {
  let trie = @binary_trie_xor.BinaryTrie::new(2)
  trie.insert(3L) // 11
  trie.insert(3L) // duplicate
  trie.insert(1L) // 01
  inspect(trie.size(), content="3")
  inspect(trie.max_xor(0L), content="3")
  inspect(trie.remove(3L), content="true")
  inspect(trie.size(), content="2")
  inspect(trie.max_xor(0L), content="3") // still present once
  inspect(trie.remove(3L), content="true")
  inspect(trie.size(), content="1")
  inspect(trie.max_xor(0L), content="1")
}
```

## Example 3: empty trie behavior

```mbt check
///|
test "empty trie" {
  let trie = @binary_trie_xor.BinaryTrie::new(4)
  inspect(trie.size(), content="0")
  inspect(trie.max_xor(10L), content="0")
  inspect(trie.min_xor(10L), content="0")
  inspect(trie.remove(10L), content="false")
}
```

## Choosing `max_bits`

`max_bits` is the index of the highest bit you want to store. If all numbers
are in `[0, 2^k - 1]`, use `max_bits = k - 1`.

Examples:

- values up to 255 (8 bits) -> `max_bits = 7`
- values up to 1e9 (30 bits) -> `max_bits = 29`
- values up to 2^63 - 1 -> `max_bits = 62`

If you use too few bits, high bits are ignored and results are wrong. If you
use too many bits, the trie is still correct but uses more memory.

## Practical notes and pitfalls

- This trie assumes non-negative values (or that you treat Int64 as an unsigned
  bit pattern). For signed negatives, set `max_bits` high enough to include the
  sign bit.
- `remove` only deletes if the full path exists and the count is positive.
- The structure stores only the XOR value, not which key produced it.

## Complexity

- Insert / Remove / Query: O(B)
- Space: O(N * B)

Here, `B = max_bits + 1`.
