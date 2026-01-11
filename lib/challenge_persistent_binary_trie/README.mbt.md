# Persistent Binary Trie

Bitwise trie that supports maximum-xor queries with path copying.

## Example

```mbt check
///|
test "persistent binary trie" {
  let max_bit = 4
  let root0 = @challenge_persistent_binary_trie.empty()
  let root1 = @challenge_persistent_binary_trie.insert(root0, 5, max_bit)
  let root2 = @challenge_persistent_binary_trie.insert(root1, 10, max_bit)
  let root3 = @challenge_persistent_binary_trie.insert(root2, 25, max_bit)
  inspect(
    @challenge_persistent_binary_trie.max_xor(root3, 5, max_bit),
    content="28",
  )
  inspect(
    @challenge_persistent_binary_trie.max_xor(root3, 10, max_bit),
    content="19",
  )
  inspect(@challenge_persistent_binary_trie.count(root1), content="1")
}
```
