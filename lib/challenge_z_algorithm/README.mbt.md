# Challenge: Z-Algorithm

Linear-time prefix matching with a sliding Z-box.

## Example

```mbt check
///|
test "z search example" {
  let matches = @challenge_z_algorithm.z_search("ababa"[:], "aba"[:])
  inspect(matches, content="[0, 2]")
}
```

## Another Example

```mbt check
///|
test "z function example" {
  let z = @challenge_z_algorithm.z_function("aaaaa"[:])
  inspect(z, content="[5, 4, 3, 2, 1]")
}
```
