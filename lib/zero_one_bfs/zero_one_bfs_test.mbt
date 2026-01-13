///|
test "0-1 bfs unreachable" {
  let g = @zero_one_bfs.Graph::new(4)
  g.add_edge(0, 1, 1)
  g.add_edge(1, 2, 0)
  let dist = @zero_one_bfs.zero_one_bfs(g, 0)
  inspect(dist, content="[0, 1, 1, 1000000000]")
}

///|
test "0-1 bfs undirected" {
  let g = @zero_one_bfs.Graph::new(4)
  g.add_undirected_edge(0, 1, 0)
  g.add_undirected_edge(1, 2, 1)
  g.add_undirected_edge(2, 3, 0)
  let dist = @zero_one_bfs.zero_one_bfs(g, 3)
  inspect(dist, content="[1, 1, 0, 0]")
}
