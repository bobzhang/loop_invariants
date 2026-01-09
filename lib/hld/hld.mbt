// ============================================================================
// HEAVY-LIGHT DECOMPOSITION - O(log²n) Path Queries on Trees
// ============================================================================
//
// Heavy-Light Decomposition (HLD) is a technique to decompose a tree into
// chains, enabling efficient path queries using segment trees.
//
// KEY INSIGHT: Define "heavy" child as the child with largest subtree.
// Heavy edges form chains. Any root-to-leaf path has O(log n) light edges
// because each light edge at least halves the subtree size.
//
// STRUCTURE:
// - Each node has at most one heavy child
// - Heavy edges form contiguous chains
// - Light edges connect chains
// - Chains are numbered and each node knows its chain head
//
// For path queries (u, v):
// 1. Move the node in the deeper chain up to its chain head
// 2. Query/update the segment within the chain
// 3. Repeat until both nodes are in same chain
// 4. Query/update the segment between them
//
// EXAMPLE:
//        1 (heavy child: 2)
//       /|\
//      2 3 4
//     /|   |
//    5 6   7
//   /
//  8
//
// Heavy chains: [1-2-5-8], [3], [4-7], [6]
// Path 8->7: 8->5->2->1->4->7 crosses 2 light edges
//
// WHY O(log n) chains per path:
// - At each light edge, subtree size at least halves
// - Starting from n, can halve at most log(n) times
// - So at most O(log n) light edges on any path
//
// INVARIANTS:
// 1. Each node has exactly one heavy child (or none if leaf)
// 2. heavy_child[v] = argmax(subtree_size[child]) over children of v
// 3. chain_head[v] = topmost node in v's heavy chain
// 4. chain_pos[v] = position of v in its chain's segment tree array
//
// TIME COMPLEXITY:
// - Preprocessing: O(n)
// - Path query: O(log²n) - O(log n) chains, O(log n) per segment query
// - Path update: O(log²n)
//
// SPACE COMPLEXITY: O(n)

///|
/// Heavy-Light Decomposition structure
priv struct HLD {
  n : Int
  adj : Array[Array[Int]] // Adjacency list
  parent : Array[Int] // Parent of each node
  depth : Array[Int] // Depth of each node
  subtree_size : Array[Int] // Size of subtree rooted at each node
  heavy_child : Array[Int] // Heavy child of each node (-1 if none)
  chain_head : Array[Int] // Head of chain containing each node
  chain_pos : Array[Int] // Position in segment tree array
  node_at_pos : Array[Int] // Inverse of chain_pos
  values : Array[Int64] // Original node values
  seg_tree : Array[Int64] // Segment tree for path sums
}

///|
/// Build HLD from tree with given adjacency list and root
/// adj[i] contains neighbors of node i
/// values[i] is the value at node i
fn HLD::new(adj : Array[Array[Int]], values : Array[Int64], root : Int) -> HLD {
  let n = adj.length()
  if n == 0 {
    return {
      n: 0,
      adj: [],
      parent: [],
      depth: [],
      subtree_size: [],
      heavy_child: [],
      chain_head: [],
      chain_pos: [],
      node_at_pos: [],
      values: [],
      seg_tree: [],
    }
  }

  let parent = Array::make(n, -1)
  let depth = Array::make(n, 0)
  let subtree_size = Array::make(n, 0)
  let heavy_child = Array::make(n, -1)
  let chain_head = Array::make(n, -1)
  let chain_pos = Array::make(n, 0)
  let node_at_pos = Array::make(n, 0)

  // DFS 1: Compute parent, depth, subtree_size, heavy_child
  // INVARIANT: After visiting node v, subtree_size[v] and heavy_child[v] are set
  dfs_size(adj, root, -1, 0, parent, depth, subtree_size, heavy_child)

  // DFS 2: Decompose into chains
  // INVARIANT: chain_head[v] is set for all visited nodes
  // Process heavy child first to ensure chain continuity
  let mut pos = 0
  pos = dfs_decompose(
    adj,
    root,
    root,
    pos,
    parent,
    heavy_child,
    chain_head,
    chain_pos,
    node_at_pos,
  )

  // Build segment tree
  let seg_tree = Array::make(4 * n, 0L)
  for i = 0; i < n; i = i + 1 {
    let node = node_at_pos[i]
    update_seg_tree(seg_tree, 1, 0, n - 1, i, values[node])
  }

  {
    n,
    adj,
    parent,
    depth,
    subtree_size,
    heavy_child,
    chain_head,
    chain_pos,
    node_at_pos,
    values,
    seg_tree,
  }
}

///|
fn dfs_size(
  adj : Array[Array[Int]],
  v : Int,
  p : Int,
  d : Int,
  parent : Array[Int],
  depth : Array[Int],
  subtree_size : Array[Int],
  heavy_child : Array[Int]
) -> Unit {
  parent[v] = p
  depth[v] = d
  subtree_size[v] = 1
  let mut max_child_size = 0

  for i = 0; i < adj[v].length(); i = i + 1 {
    let u = adj[v][i]
    if u != p {
      dfs_size(adj, u, v, d + 1, parent, depth, subtree_size, heavy_child)
      subtree_size[v] = subtree_size[v] + subtree_size[u]
      if subtree_size[u] > max_child_size {
        max_child_size = subtree_size[u]
        heavy_child[v] = u
      }
    }
  }
}

///|
fn dfs_decompose(
  adj : Array[Array[Int]],
  v : Int,
  head : Int,
  pos : Int,
  parent : Array[Int],
  heavy_child : Array[Int],
  chain_head : Array[Int],
  chain_pos : Array[Int],
  node_at_pos : Array[Int]
) -> Int {
  chain_head[v] = head
  chain_pos[v] = pos
  node_at_pos[pos] = v
  let mut next_pos = pos + 1

  // Process heavy child first to keep chain contiguous in segment tree
  if heavy_child[v] != -1 {
    next_pos = dfs_decompose(
      adj,
      heavy_child[v],
      head,
      next_pos,
      parent,
      heavy_child,
      chain_head,
      chain_pos,
      node_at_pos,
    )
  }

  // Process light children (each starts new chain)
  for i = 0; i < adj[v].length(); i = i + 1 {
    let u = adj[v][i]
    if u != parent[v] && u != heavy_child[v] {
      // u starts a new chain with itself as head
      next_pos = dfs_decompose(
        adj,
        u,
        u,
        next_pos,
        parent,
        heavy_child,
        chain_head,
        chain_pos,
        node_at_pos,
      )
    }
  }

  next_pos
}

// ============================================================================
// SEGMENT TREE OPERATIONS
// ============================================================================

///|
fn update_seg_tree(
  tree : Array[Int64],
  node : Int,
  start : Int,
  end : Int,
  idx : Int,
  val : Int64
) -> Unit {
  if start == end {
    tree[node] = val
    return
  }
  let mid = (start + end) / 2
  if idx <= mid {
    update_seg_tree(tree, 2 * node, start, mid, idx, val)
  } else {
    update_seg_tree(tree, 2 * node + 1, mid + 1, end, idx, val)
  }
  tree[node] = tree[2 * node] + tree[2 * node + 1]
}

///|
fn query_seg_tree(
  tree : Array[Int64],
  node : Int,
  start : Int,
  end : Int,
  l : Int,
  r : Int
) -> Int64 {
  if r < start || end < l {
    return 0L
  }
  if l <= start && end <= r {
    return tree[node]
  }
  let mid = (start + end) / 2
  let left = query_seg_tree(tree, 2 * node, start, mid, l, r)
  let right = query_seg_tree(tree, 2 * node + 1, mid + 1, end, l, r)
  left + right
}

// ============================================================================
// PATH OPERATIONS
// ============================================================================

///|
/// Query sum of values on path from u to v
/// REASONING: Move the deeper chain head up, accumulating segment queries
fn HLD::path_sum(self : HLD, u : Int, v : Int) -> Int64? {
  if u < 0 || v < 0 || u >= self.n || v >= self.n {
    return None
  }

  let mut u = u
  let mut v = v
  let mut result = 0L

  // INVARIANT: Move the node whose chain head is deeper
  // until both are in same chain
  while self.chain_head[u] != self.chain_head[v] {
    if self.depth[self.chain_head[u]] < self.depth[self.chain_head[v]] {
      // v's chain head is deeper, swap
      let tmp = u
      u = v
      v = tmp
    }
    // Query from u to its chain head
    let head = self.chain_head[u]
    result = result +
      query_seg_tree(
        self.seg_tree,
        1,
        0,
        self.n - 1,
        self.chain_pos[head],
        self.chain_pos[u],
      )
    // Move u up to parent of chain head
    u = self.parent[head]
  }

  // Now u and v are in same chain
  // Query the segment between them
  let left = if self.chain_pos[u] < self.chain_pos[v] {
    self.chain_pos[u]
  } else {
    self.chain_pos[v]
  }
  let right = if self.chain_pos[u] > self.chain_pos[v] {
    self.chain_pos[u]
  } else {
    self.chain_pos[v]
  }
  result = result +
    query_seg_tree(self.seg_tree, 1, 0, self.n - 1, left, right)

  Some(result)
}

///|
/// Find LCA of two nodes using HLD
fn HLD::lca(self : HLD, u : Int, v : Int) -> Int? {
  if u < 0 || v < 0 || u >= self.n || v >= self.n {
    return None
  }

  let mut u = u
  let mut v = v

  // Move up chains until same chain
  while self.chain_head[u] != self.chain_head[v] {
    if self.depth[self.chain_head[u]] < self.depth[self.chain_head[v]] {
      let tmp = u
      u = v
      v = tmp
    }
    u = self.parent[self.chain_head[u]]
  }

  // LCA is the shallower node
  if self.depth[u] < self.depth[v] { Some(u) } else { Some(v) }
}

///|
/// Update value at node v
fn HLD::update_node(self : HLD, v : Int, new_val : Int64) -> Bool {
  if v < 0 || v >= self.n {
    return false
  }
  self.values[v] = new_val
  update_seg_tree(self.seg_tree, 1, 0, self.n - 1, self.chain_pos[v], new_val)
  true
}

///|
/// Get value at node v
fn HLD::get_value(self : HLD, v : Int) -> Int64? {
  if v < 0 || v >= self.n {
    return None
  }
  Some(self.values[v])
}

///|
/// Get depth of node v
fn HLD::get_depth(self : HLD, v : Int) -> Int? {
  if v < 0 || v >= self.n {
    return None
  }
  Some(self.depth[v])
}

///|
/// Get parent of node v
fn HLD::get_parent(self : HLD, v : Int) -> Int? {
  if v < 0 || v >= self.n {
    return None
  }
  if self.parent[v] == -1 {
    None
  } else {
    Some(self.parent[v])
  }
}

///|
fn HLD::length(self : HLD) -> Int {
  self.n
}

// ============================================================================
// HLD FOR MAXIMUM QUERIES
// ============================================================================

///|
/// HLD with segment tree for path maximum queries
priv struct HLDMax {
  n : Int
  adj : Array[Array[Int]]
  parent : Array[Int]
  depth : Array[Int]
  subtree_size : Array[Int]
  heavy_child : Array[Int]
  chain_head : Array[Int]
  chain_pos : Array[Int]
  node_at_pos : Array[Int]
  values : Array[Int64]
  seg_tree : Array[Int64] // Stores max instead of sum
}

///|
fn HLDMax::new(adj : Array[Array[Int]], values : Array[Int64], root : Int) -> HLDMax {
  let n = adj.length()
  if n == 0 {
    return {
      n: 0,
      adj: [],
      parent: [],
      depth: [],
      subtree_size: [],
      heavy_child: [],
      chain_head: [],
      chain_pos: [],
      node_at_pos: [],
      values: [],
      seg_tree: [],
    }
  }

  let parent = Array::make(n, -1)
  let depth = Array::make(n, 0)
  let subtree_size = Array::make(n, 0)
  let heavy_child = Array::make(n, -1)
  let chain_head = Array::make(n, -1)
  let chain_pos = Array::make(n, 0)
  let node_at_pos = Array::make(n, 0)

  dfs_size(adj, root, -1, 0, parent, depth, subtree_size, heavy_child)
  let mut pos = 0
  pos = dfs_decompose(
    adj,
    root,
    root,
    pos,
    parent,
    heavy_child,
    chain_head,
    chain_pos,
    node_at_pos,
  )

  let seg_tree = Array::make(4 * n, -9223372036854775808L) // Int64 min
  for i = 0; i < n; i = i + 1 {
    let node = node_at_pos[i]
    update_max_seg_tree(seg_tree, 1, 0, n - 1, i, values[node])
  }

  {
    n,
    adj,
    parent,
    depth,
    subtree_size,
    heavy_child,
    chain_head,
    chain_pos,
    node_at_pos,
    values,
    seg_tree,
  }
}

///|
fn update_max_seg_tree(
  tree : Array[Int64],
  node : Int,
  start : Int,
  end : Int,
  idx : Int,
  val : Int64
) -> Unit {
  if start == end {
    tree[node] = val
    return
  }
  let mid = (start + end) / 2
  if idx <= mid {
    update_max_seg_tree(tree, 2 * node, start, mid, idx, val)
  } else {
    update_max_seg_tree(tree, 2 * node + 1, mid + 1, end, idx, val)
  }
  tree[node] = if tree[2 * node] > tree[2 * node + 1] {
    tree[2 * node]
  } else {
    tree[2 * node + 1]
  }
}

///|
fn query_max_seg_tree(
  tree : Array[Int64],
  node : Int,
  start : Int,
  end : Int,
  l : Int,
  r : Int
) -> Int64 {
  if r < start || end < l {
    return -9223372036854775808L // Int64 min
  }
  if l <= start && end <= r {
    return tree[node]
  }
  let mid = (start + end) / 2
  let left = query_max_seg_tree(tree, 2 * node, start, mid, l, r)
  let right = query_max_seg_tree(tree, 2 * node + 1, mid + 1, end, l, r)
  if left > right { left } else { right }
}

///|
/// Query maximum on path from u to v
fn HLDMax::path_max(self : HLDMax, u : Int, v : Int) -> Int64? {
  if u < 0 || v < 0 || u >= self.n || v >= self.n {
    return None
  }

  let mut u = u
  let mut v = v
  let mut result = -9223372036854775808L

  while self.chain_head[u] != self.chain_head[v] {
    if self.depth[self.chain_head[u]] < self.depth[self.chain_head[v]] {
      let tmp = u
      u = v
      v = tmp
    }
    let head = self.chain_head[u]
    let seg_max = query_max_seg_tree(
      self.seg_tree,
      1,
      0,
      self.n - 1,
      self.chain_pos[head],
      self.chain_pos[u],
    )
    if seg_max > result {
      result = seg_max
    }
    u = self.parent[head]
  }

  let left = if self.chain_pos[u] < self.chain_pos[v] {
    self.chain_pos[u]
  } else {
    self.chain_pos[v]
  }
  let right = if self.chain_pos[u] > self.chain_pos[v] {
    self.chain_pos[u]
  } else {
    self.chain_pos[v]
  }
  let seg_max = query_max_seg_tree(
    self.seg_tree,
    1,
    0,
    self.n - 1,
    left,
    right,
  )
  if seg_max > result {
    result = seg_max
  }

  Some(result)
}

///|
fn HLDMax::update_node(self : HLDMax, v : Int, new_val : Int64) -> Bool {
  if v < 0 || v >= self.n {
    return false
  }
  self.values[v] = new_val
  update_max_seg_tree(self.seg_tree, 1, 0, self.n - 1, self.chain_pos[v], new_val)
  true
}

///|
fn HLDMax::length(self : HLDMax) -> Int {
  self.n
}

// ============================================================================
// TESTS
// ============================================================================

///|
/// Build adjacency list from edges
fn build_adj(n : Int, edges : Array[(Int, Int)]) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = []
  for i = 0; i < n; i = i + 1 {
    adj.push([])
  }
  for i = 0; i < edges.length(); i = i + 1 {
    let (u, v) = edges[i]
    adj[u].push(v)
    adj[v].push(u)
  }
  adj
}

///|
test "hld construction basic" {
  // Tree:
  //     0
  //    /|\
  //   1 2 3
  //  /|
  // 4 5
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (0, 3), (1, 4), (1, 5)]
  let adj = build_adj(6, edges)
  let values : Array[Int64] = [1L, 2L, 3L, 4L, 5L, 6L]
  let hld = HLD::new(adj, values, 0)

  inspect(hld.length(), content="6")

  // Check depths
  inspect(hld.get_depth(0), content="Some(0)")
  inspect(hld.get_depth(1), content="Some(1)")
  inspect(hld.get_depth(4), content="Some(2)")
}

///|
test "hld path sum simple" {
  // Linear tree: 0 - 1 - 2 - 3
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3)]
  let adj = build_adj(4, edges)
  let values : Array[Int64] = [1L, 2L, 3L, 4L]
  let hld = HLD::new(adj, values, 0)

  // Path 0 to 3: sum = 1 + 2 + 3 + 4 = 10
  inspect(hld.path_sum(0, 3), content="Some(10)")

  // Path 1 to 2: sum = 2 + 3 = 5
  inspect(hld.path_sum(1, 2), content="Some(5)")

  // Path 0 to 0: just node 0
  inspect(hld.path_sum(0, 0), content="Some(1)")
}

///|
test "hld path sum tree" {
  // Tree:
  //     0
  //    / \
  //   1   2
  //  / \
  // 3   4
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let adj = build_adj(5, edges)
  let values : Array[Int64] = [1L, 2L, 3L, 4L, 5L]
  let hld = HLD::new(adj, values, 0)

  // Path 3 to 4: 4 + 2 + 5 = 11
  inspect(hld.path_sum(3, 4), content="Some(11)")

  // Path 3 to 2: 4 + 2 + 1 + 3 = 10
  inspect(hld.path_sum(3, 2), content="Some(10)")
}

///|
test "hld lca" {
  // Tree:
  //       0
  //      / \
  //     1   2
  //    / \
  //   3   4
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let adj = build_adj(5, edges)
  let values : Array[Int64] = [1L, 2L, 3L, 4L, 5L]
  let hld = HLD::new(adj, values, 0)

  // LCA of 3 and 4 is 1
  inspect(hld.lca(3, 4), content="Some(1)")

  // LCA of 3 and 2 is 0
  inspect(hld.lca(3, 2), content="Some(0)")

  // LCA of 3 and 3 is 3
  inspect(hld.lca(3, 3), content="Some(3)")
}

///|
test "hld update" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2)]
  let adj = build_adj(3, edges)
  let values : Array[Int64] = [1L, 2L, 3L]
  let hld = HLD::new(adj, values, 0)

  // Initial sum
  inspect(hld.path_sum(0, 2), content="Some(6)")

  // Update node 1 to 10
  let _ = hld.update_node(1, 10L)
  inspect(hld.path_sum(0, 2), content="Some(14)")
}

///|
test "hld empty" {
  let adj : Array[Array[Int]] = []
  let values : Array[Int64] = []
  let hld = HLD::new(adj, values, 0)

  inspect(hld.length(), content="0")
  inspect(hld.path_sum(0, 0), content="None")
}

///|
test "hld single node" {
  let adj : Array[Array[Int]] = [[]]
  let values : Array[Int64] = [42L]
  let hld = HLD::new(adj, values, 0)

  inspect(hld.path_sum(0, 0), content="Some(42)")
  inspect(hld.lca(0, 0), content="Some(0)")
}

///|
test "hld max path" {
  // Linear tree
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 3)]
  let adj = build_adj(4, edges)
  let values : Array[Int64] = [1L, 5L, 2L, 4L]
  let hld = HLDMax::new(adj, values, 0)

  // Max on path 0 to 3 is 5
  inspect(hld.path_max(0, 3), content="Some(5)")

  // Max on path 2 to 3 is 4
  inspect(hld.path_max(2, 3), content="Some(4)")
}

///|
test "hld max tree" {
  //     0(10)
  //    / \
  //   1(5) 2(3)
  //  / \
  // 3(8) 4(2)
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let adj = build_adj(5, edges)
  let values : Array[Int64] = [10L, 5L, 3L, 8L, 2L]
  let hld = HLDMax::new(adj, values, 0)

  // Max on path 3 to 4: 8, 5, 2 -> max = 8
  inspect(hld.path_max(3, 4), content="Some(8)")

  // Max on path 3 to 2: 8, 5, 10, 3 -> max = 10
  inspect(hld.path_max(3, 2), content="Some(10)")
}

///|
test "hld max update" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2)]
  let adj = build_adj(3, edges)
  let values : Array[Int64] = [1L, 2L, 3L]
  let hld = HLDMax::new(adj, values, 0)

  inspect(hld.path_max(0, 2), content="Some(3)")

  // Update node 0 to 100
  let _ = hld.update_node(0, 100L)
  inspect(hld.path_max(0, 2), content="Some(100)")
}

///|
test "hld larger tree" {
  // Binary tree of depth 3
  //        0
  //       / \
  //      1   2
  //     / \ / \
  //    3  4 5  6
  let edges : Array[(Int, Int)] = [
    (0, 1),
    (0, 2),
    (1, 3),
    (1, 4),
    (2, 5),
    (2, 6),
  ]
  let adj = build_adj(7, edges)
  let values : Array[Int64] = [1L, 2L, 3L, 4L, 5L, 6L, 7L]
  let hld = HLD::new(adj, values, 0)

  // Path 3 to 6: 4 + 2 + 1 + 3 + 7 = 17
  inspect(hld.path_sum(3, 6), content="Some(17)")

  // Path 4 to 5: 5 + 2 + 1 + 3 + 6 = 17
  inspect(hld.path_sum(4, 5), content="Some(17)")

  // LCA of 3 and 6 is 0
  inspect(hld.lca(3, 6), content="Some(0)")

  // LCA of 3 and 4 is 1
  inspect(hld.lca(3, 4), content="Some(1)")
}

///|
test "hld chain structure" {
  // Verify heavy chain selection
  // Left-heavy tree:
  //     0
  //    / \
  //   1   2
  //  /
  // 3
  // Heavy path should be 0-1-3
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3)]
  let adj = build_adj(4, edges)
  let values : Array[Int64] = [1L, 1L, 1L, 1L]
  let hld = HLD::new(adj, values, 0)

  // 0 and 1 should have same chain head (0)
  // 1 and 3 should have same chain head (0)
  // 2 should have different chain head (2, starts new chain)
  inspect(hld.chain_head[0] == hld.chain_head[1], content="true")
  inspect(hld.chain_head[1] == hld.chain_head[3], content="true")
}

///|
test "hld invalid queries" {
  let edges : Array[(Int, Int)] = [(0, 1)]
  let adj = build_adj(2, edges)
  let values : Array[Int64] = [1L, 2L]
  let hld = HLD::new(adj, values, 0)

  inspect(hld.path_sum(-1, 0), content="None")
  inspect(hld.path_sum(0, 10), content="None")
  inspect(hld.lca(-1, 0), content="None")
}

///|
test "hld get operations" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2)]
  let adj = build_adj(3, edges)
  let values : Array[Int64] = [5L, 10L, 15L]
  let hld = HLD::new(adj, values, 0)

  inspect(hld.get_value(0), content="Some(5)")
  inspect(hld.get_value(1), content="Some(10)")
  inspect(hld.get_parent(0), content="None") // Root has no parent
  inspect(hld.get_parent(1), content="Some(0)")
  inspect(hld.get_parent(2), content="Some(1)")
}

///|
test "hld max empty" {
  let adj : Array[Array[Int]] = []
  let values : Array[Int64] = []
  let hld = HLDMax::new(adj, values, 0)

  inspect(hld.length(), content="0")
  inspect(hld.path_max(0, 0), content="None")
}
