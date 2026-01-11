# Challenge: SCC (Tarjan)

Single-pass SCC decomposition using low-link values.

## Example

```mbt check
///|
test "scc tarjan example" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (3, 4)]
  let comp = @challenge_scc_tarjan.scc_tarjan(5, edges[:])
  inspect(comp[0] == comp[1] && comp[1] == comp[2], content="true")
}
```
