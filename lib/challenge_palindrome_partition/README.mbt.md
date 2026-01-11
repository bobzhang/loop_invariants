# Challenge: Palindrome Partition (Min Cuts)

DP for minimal palindrome partitioning cuts.

## Example

```mbt check
///|
test "palindrome partition example" {
  let cuts = @challenge_palindrome_partition.min_palindrome_cuts("aab")
  inspect(cuts, content="1")
}
```
