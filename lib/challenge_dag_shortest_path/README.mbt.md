# Challenge: DAG Shortest Paths

Topological-order dynamic programming for DAG shortest paths.

## Example

```mbt check
///|
test "dag shortest path example" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 2),
    (0, 2, 5),
    (1, 2, 1),
    (1, 3, 2),
    (2, 3, 1),
  ]
  let dist = @challenge_dag_shortest_path.dag_shortest_paths(4, edges[:], 0)
  guard dist is Some(d) else { fail("expected distances") }
  inspect(d, content="[0, 2, 3, 4]")
}
```
