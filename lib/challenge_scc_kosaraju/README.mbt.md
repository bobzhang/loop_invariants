# Challenge: SCC (Kosaraju)

Two-pass DFS to compute strongly connected components.

## Example

```mbt check
///|
test "scc kosaraju example" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (3, 4)]
  let comp = @challenge_scc_kosaraju.scc_kosaraju(5, edges[:])
  inspect(comp[0] == comp[1] && comp[1] == comp[2], content="true")
}
```

## Another Example

```mbt check
///|
test "scc kosaraju isolated" {
  let edges : Array[(Int, Int)] = []
  let comp = @challenge_scc_kosaraju.scc_kosaraju(3, edges[:])
  inspect(comp[0] != comp[1] && comp[1] != comp[2], content="true")
}
```
