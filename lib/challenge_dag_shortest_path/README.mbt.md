# Challenge: DAG Shortest Paths

Topological-order dynamic programming for DAG shortest paths.

## Core Idea

Compute a topological order, then relax edges following that order.
Because the graph is acyclic, each node’s shortest distance is finalized when
processed. Negative edge weights are allowed in DAGs.

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

## Another Example

```mbt check
///|
test "dag shortest path chain" {
  let edges : Array[(Int, Int, Int)] = [(0, 1, 1), (1, 2, 2)]
  let dist = @challenge_dag_shortest_path.dag_shortest_paths(3, edges[:], 0)
  guard dist is Some(d) else { fail("expected distances") }
  inspect(d, content="[0, 1, 3]")
}
```

## Cycle Detection

If the graph has a cycle, no topological order exists:

```mbt check
///|
test "dag shortest path cycle" {
  let edges : Array[(Int, Int, Int)] = [(0, 1, 1), (1, 2, 2), (2, 0, 3)]
  let dist = @challenge_dag_shortest_path.dag_shortest_paths(3, edges[:], 0)
  inspect(dist is None, content="true")
}
```

## Notes

- Runs in O(n + m).
