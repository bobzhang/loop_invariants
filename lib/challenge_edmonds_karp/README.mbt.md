# Challenge: Max Flow (Edmonds-Karp)

BFS-based augmenting path algorithm for max flow.

## Example

```mbt check
///|
test "edmonds-karp example" {
  let g = @challenge_edmonds_karp.make(4)
  @challenge_edmonds_karp.add_edge(g, 0, 1, 3)
  @challenge_edmonds_karp.add_edge(g, 0, 2, 2)
  @challenge_edmonds_karp.add_edge(g, 1, 2, 1)
  @challenge_edmonds_karp.add_edge(g, 1, 3, 2)
  @challenge_edmonds_karp.add_edge(g, 2, 3, 4)
  let flow = @challenge_edmonds_karp.max_flow(g, 0, 3)
  inspect(flow, content="5")
}
```

## Another Example

```mbt check
///|
test "edmonds-karp simple" {
  let g = @challenge_edmonds_karp.make(2)
  @challenge_edmonds_karp.add_edge(g, 0, 1, 7)
  let flow = @challenge_edmonds_karp.max_flow(g, 0, 1)
  inspect(flow, content="7")
}
```
