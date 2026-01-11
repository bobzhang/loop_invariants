# Challenge: Centroid Decomposition

Decompose a tree into a centroid tree with parent and level arrays.

## Example

```mbt check
///|
test "centroid decomposition example" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3), (3, 4)]
  let cd = @challenge_centroid_decomposition.build_centroid(5, edges[:])
  inspect(cd.level[2] == 0, content="true")
}
```
