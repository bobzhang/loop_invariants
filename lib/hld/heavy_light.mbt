// Heavy-Light Decomposition (HLD)
// A powerful technique for path queries on trees with rigorous loop invariants

// ============================================================================
// HEAVY-LIGHT DECOMPOSITION
// ============================================================================
//
// KEY INSIGHT: Decompose tree into chains such that any path from root to leaf
// crosses at most O(log n) light edges. This allows path queries in O(log^2 n).
//
// DEFINITIONS:
// - Heavy child: The child with the largest subtree size
// - Heavy edge: Edge connecting a node to its heavy child
// - Light edge: All other edges
// - Heavy chain: Maximal path of heavy edges
//
// PROPERTY: Any root-to-leaf path crosses at most log(n) light edges
// PROOF: Each light edge reduces subtree size by at least half

///|
struct HLDNode {
  parent : Int // parent node (-1 for root)
  depth : Int // depth in tree
  subtree_size : Int // size of subtree rooted here
  heavy_child : Int // index of heavy child (-1 if leaf)
  chain_head : Int // head of the heavy chain containing this node
  chain_pos : Int // position in the flattened chain array
}

///|
struct HeavyLightDecomposition {
  n : Int
  nodes : Array[HLDNode]
  adj : Array[Array[Int]] // adjacency list
  chain_arr : Array[Int] // flattened array for segment tree
  mut pos_counter : Int // counter for assigning chain positions
}

///|
fn HeavyLightDecomposition::new(n : Int) -> HeavyLightDecomposition {
  let nodes : Array[HLDNode] = Array::make(n, {
    parent: -1,
    depth: 0,
    subtree_size: 0,
    heavy_child: -1,
    chain_head: -1,
    chain_pos: -1,
  })
  let adj : Array[Array[Int]] = Array::make(n, [])
  for i = 0; i < n; i = i + 1 {
    adj[i] = []
  }
  let chain_arr : Array[Int] = Array::make(n, 0)
  { n, nodes, adj, chain_arr, pos_counter: 0 }
}

///|
/// Add an undirected edge between u and v
fn HeavyLightDecomposition::add_edge(
  self : HeavyLightDecomposition,
  u : Int,
  v : Int,
) -> Unit {
  self.adj[u].push(v)
  self.adj[v].push(u)
}

///|
/// DFS to compute parent, depth, subtree sizes, and heavy children
fn HeavyLightDecomposition::dfs_sizes(
  self : HeavyLightDecomposition,
  u : Int,
  parent : Int,
  depth : Int,
) -> Int {
  self.nodes[u] = {
    parent,
    depth,
    subtree_size: 1,
    heavy_child: -1,
    chain_head: -1,
    chain_pos: -1,
  }
  let mut max_child_size = 0
  let mut heavy = -1
  let mut subtree_size = 1
  for v in self.adj[u] {
    if v != parent {
      let child_size = self.dfs_sizes(v, u, depth + 1)
      subtree_size = subtree_size + child_size
      if child_size > max_child_size {
        max_child_size = child_size
        heavy = v
      }
    }
  }
  self.nodes[u] = {
    parent,
    depth,
    subtree_size,
    heavy_child: heavy,
    chain_head: -1,
    chain_pos: -1,
  }
  subtree_size
}

///|
/// DFS to decompose tree into heavy chains
fn HeavyLightDecomposition::dfs_decompose(
  self : HeavyLightDecomposition,
  u : Int,
  chain_head : Int,
) -> Unit {
  // Assign position in chain array
  let pos = self.pos_counter
  self.pos_counter = self.pos_counter + 1
  self.chain_arr[pos] = u
  let node = self.nodes[u]
  self.nodes[u] = {
    parent: node.parent,
    depth: node.depth,
    subtree_size: node.subtree_size,
    heavy_child: node.heavy_child,
    chain_head,
    chain_pos: pos,
  }
  // First, traverse heavy child (continues same chain)
  if node.heavy_child != -1 {
    self.dfs_decompose(node.heavy_child, chain_head)
  }
  // Then traverse light children (each starts new chain)
  for v in self.adj[u] {
    if v != node.parent && v != node.heavy_child {
      self.dfs_decompose(v, v) // v is head of its own chain
    }
  }
}

///|
/// Build the HLD from root node
fn HeavyLightDecomposition::build(
  self : HeavyLightDecomposition,
  root : Int,
) -> Unit {
  let _ = self.dfs_sizes(root, -1, 0)
  self.dfs_decompose(root, root)
}

///|
/// Find LCA using HLD
///  Complexity: O(log n) - at most log(n) chain jumps
fn HeavyLightDecomposition::lca(
  self : HeavyLightDecomposition,
  u_in : Int,
  v_in : Int,
) -> Int {
  let mut u = u_in
  let mut v = v_in
  // Move up chains until both nodes are on the same chain
  for ; self.nodes[u].chain_head != self.nodes[v].chain_head; {
    // Move up the node whose chain head is deeper
    if self.nodes[self.nodes[u].chain_head].depth <
      self.nodes[self.nodes[v].chain_head].depth {
      v = self.nodes[self.nodes[v].chain_head].parent
    } else {
      u = self.nodes[self.nodes[u].chain_head].parent
    }
  } else {
    // Now u and v are on the same chain, LCA is the shallower one
    if self.nodes[u].depth < self.nodes[v].depth {
      u
    } else {
      v
    }
  } where {
    invariant: u >= 0 && v >= 0,
    reasoning: (
      #|HLD LCA INVARIANT:
      #|  At each iteration, u and v move closer to their LCA.
      #|
      #|KEY INSIGHT:
      #|  Each chain jump moves a node to a strictly shallower position.
      #|  The chain head's parent is always at a shallower depth.
      #|
      #|TERMINATION:
      #|  At most O(log n) chain jumps because each light edge
      #|  halves the subtree size, and we only jump at light edges.
      #|
      #|CORRECTNESS:
      #|  When both nodes are on the same chain, the LCA is the
      #|  node with smaller depth (closer to root).
    ),
  }
}

///|
/// Query path from u to v using a combining function
///  Returns the combined value along the path
fn HeavyLightDecomposition::query_path(
  self : HeavyLightDecomposition,
  u_in : Int,
  v_in : Int,
  node_values : Array[Int],
  combine : (Int, Int) -> Int,
  identity : Int,
) -> Int {
  let mut u = u_in
  let mut v = v_in
  let mut result = identity
  // Process chains until u and v are on the same chain
  for ; self.nodes[u].chain_head != self.nodes[v].chain_head; {
    // Always process the deeper chain head first
    if self.nodes[self.nodes[u].chain_head].depth <
      self.nodes[self.nodes[v].chain_head].depth {
      // Process v's chain from v to chain_head
      let chain_head = self.nodes[v].chain_head
      result = self.query_chain_segment(
        self.nodes[chain_head].chain_pos,
        self.nodes[v].chain_pos,
        node_values,
        combine,
        result,
      )
      v = self.nodes[chain_head].parent
    } else {
      // Process u's chain from u to chain_head
      let chain_head = self.nodes[u].chain_head
      result = self.query_chain_segment(
        self.nodes[chain_head].chain_pos,
        self.nodes[u].chain_pos,
        node_values,
        combine,
        result,
      )
      u = self.nodes[chain_head].parent
    }
  } else {
    // u and v are on the same chain, query the segment between them
    let lo = if self.nodes[u].chain_pos < self.nodes[v].chain_pos {
      self.nodes[u].chain_pos
    } else {
      self.nodes[v].chain_pos
    }
    let hi = if self.nodes[u].chain_pos > self.nodes[v].chain_pos {
      self.nodes[u].chain_pos
    } else {
      self.nodes[v].chain_pos
    }
    self.query_chain_segment(lo, hi, node_values, combine, result)
  } where {
    invariant: u >= 0 && v >= 0,
    reasoning: (
      #|HLD PATH QUERY INVARIANT:
      #|  result accumulates the combined value of all processed chains
      #|  u and v move toward their LCA with each chain jump
      #|
      #|COMPLEXITY ANALYSIS:
      #|  - Each chain segment can be queried in O(log n) with segment tree
      #|  - At most O(log n) chains are crossed
      #|  - Total: O(log^2 n)
      #|
      #|CORRECTNESS:
      #|  Every edge on the path u→v is counted exactly once.
      #|  We process from endpoints toward LCA, then the final
      #|  segment on the common chain.
    ),
  }
}

///|
/// Query a segment within the chain array
fn HeavyLightDecomposition::query_chain_segment(
  self : HeavyLightDecomposition,
  lo : Int,
  hi : Int,
  node_values : Array[Int],
  combine : (Int, Int) -> Int,
  initial : Int,
) -> Int {
  for i = lo, result = initial
      i <= hi
      i = i + 1, result = combine(result, node_values[self.chain_arr[i]]) {

  } else {
    result
  } where {
    invariant: i >= lo && i <= hi + 1,
    reasoning: (
      #|CHAIN SEGMENT QUERY INVARIANT:
      #|  result = combine(initial, values[lo], values[lo+1], ..., values[i-1])
      #|
      #|This is a linear scan for simplicity.
      #|In production, this would use a segment tree for O(log n) queries.
    ),
  }
}

// ============================================================================
// SEGMENT TREE FOR HLD (for O(log^2 n) queries)
// ============================================================================

///|
struct HLDSegmentTree {
  n : Int
  tree : Array[Int]
  combine : (Int, Int) -> Int
  identity : Int
}

///|
fn HLDSegmentTree::new(
  arr : Array[Int],
  combine : (Int, Int) -> Int,
  identity : Int,
) -> HLDSegmentTree {
  let n = arr.length()
  let tree : Array[Int] = Array::make(4 * n, identity)
  let st : HLDSegmentTree = { n, tree, combine, identity }
  if n > 0 {
    st.build(arr, 1, 0, n - 1)
  }
  st
}

///|
/// Build segment tree recursively
fn HLDSegmentTree::build(
  self : HLDSegmentTree,
  arr : Array[Int],
  node : Int,
  lo : Int,
  hi : Int,
) -> Unit {
  if lo == hi {
    self.tree[node] = arr[lo]
  } else {
    let mid = (lo + hi) / 2
    self.build(arr, 2 * node, lo, mid)
    self.build(arr, 2 * node + 1, mid + 1, hi)
    self.tree[node] = (self.combine)(
      self.tree[2 * node],
      self.tree[2 * node + 1],
    )
  }
}

///|
/// Point update
fn HLDSegmentTree::update(
  self : HLDSegmentTree,
  node : Int,
  lo : Int,
  hi : Int,
  idx : Int,
  val : Int,
) -> Unit {
  if lo == hi {
    self.tree[node] = val
  } else {
    let mid = (lo + hi) / 2
    if idx <= mid {
      self.update(2 * node, lo, mid, idx, val)
    } else {
      self.update(2 * node + 1, mid + 1, hi, idx, val)
    }
    self.tree[node] = (self.combine)(
      self.tree[2 * node],
      self.tree[2 * node + 1],
    )
  }
}

///|
/// Range query
fn HLDSegmentTree::query(
  self : HLDSegmentTree,
  node : Int,
  lo : Int,
  hi : Int,
  q_lo : Int,
  q_hi : Int,
) -> Int {
  if q_lo > hi || q_hi < lo {
    self.identity
  } else if q_lo <= lo && hi <= q_hi {
    self.tree[node]
  } else {
    let mid = (lo + hi) / 2
    let left = self.query(2 * node, lo, mid, q_lo, q_hi)
    let right = self.query(2 * node + 1, mid + 1, hi, q_lo, q_hi)
    (self.combine)(left, right)
  }
}

// ============================================================================
// HLD WITH SEGMENT TREE (O(log^2 n) operations)
// ============================================================================

///|
struct HLDWithSegTree {
  hld : HeavyLightDecomposition
  seg_tree : HLDSegmentTree
  node_values : Array[Int]
}

///|
fn HLDWithSegTree::new(
  n : Int,
  values : Array[Int],
  edges : Array[(Int, Int)],
  root : Int,
  combine : (Int, Int) -> Int,
  identity : Int,
) -> HLDWithSegTree {
  let hld = HeavyLightDecomposition::new(n)
  for edge in edges {
    let (u, v) = edge
    hld.add_edge(u, v)
  }
  hld.build(root)
  // Reorder values according to chain positions
  let chain_values : Array[Int] = Array::make(n, identity)
  for i = 0; i < n; i = i + 1 {
    chain_values[hld.nodes[i].chain_pos] = values[i]
  } where {
    invariant: i <= n,
    reasoning: (
      #|VALUE REORDERING INVARIANT:
      #|  chain_values[pos] = values[node] where node has chain_pos = pos
      #|
      #|This reordering allows contiguous segment tree queries
      #|for nodes on the same heavy chain.
    ),
  }
  let seg_tree = HLDSegmentTree::new(chain_values, combine, identity)
  { hld, seg_tree, node_values: values }
}

///|
/// Query path from u to v
fn HLDWithSegTree::query_path(
  self : HLDWithSegTree,
  u_in : Int,
  v_in : Int,
) -> Int {
  let mut u = u_in
  let mut v = v_in
  let mut result = self.seg_tree.identity
  let n = self.hld.n
  for ; self.hld.nodes[u].chain_head != self.hld.nodes[v].chain_head; {
    if self.hld.nodes[self.hld.nodes[u].chain_head].depth <
      self.hld.nodes[self.hld.nodes[v].chain_head].depth {
      let chain_head = self.hld.nodes[v].chain_head
      let seg_result = self.seg_tree.query(
        1,
        0,
        n - 1,
        self.hld.nodes[chain_head].chain_pos,
        self.hld.nodes[v].chain_pos,
      )
      result = (self.seg_tree.combine)(result, seg_result)
      v = self.hld.nodes[chain_head].parent
    } else {
      let chain_head = self.hld.nodes[u].chain_head
      let seg_result = self.seg_tree.query(
        1,
        0,
        n - 1,
        self.hld.nodes[chain_head].chain_pos,
        self.hld.nodes[u].chain_pos,
      )
      result = (self.seg_tree.combine)(result, seg_result)
      u = self.hld.nodes[chain_head].parent
    }
  } else {
    let lo = if self.hld.nodes[u].chain_pos < self.hld.nodes[v].chain_pos {
      self.hld.nodes[u].chain_pos
    } else {
      self.hld.nodes[v].chain_pos
    }
    let hi = if self.hld.nodes[u].chain_pos > self.hld.nodes[v].chain_pos {
      self.hld.nodes[u].chain_pos
    } else {
      self.hld.nodes[v].chain_pos
    }
    let seg_result = self.seg_tree.query(1, 0, n - 1, lo, hi)
    (self.seg_tree.combine)(result, seg_result)
  } where {
    invariant: u >= 0 && v >= 0,
    reasoning: (
      #|HLD + SEGMENT TREE PATH QUERY INVARIANT:
      #|
      #|COMPLEXITY: O(log^2 n)
      #|  - O(log n) chain jumps (each light edge halves subtree)
      #|  - O(log n) per segment tree query
      #|
      #|CORRECTNESS:
      #|  result accumulates the combined value of all chain segments
      #|  Each chain segment is queried exactly once via segment tree
      #|  Final segment covers the path on the common chain
      #|
      #|WHY HLD WORKS:
      #|  Heavy edges form contiguous paths in the chain array.
      #|  This contiguity enables efficient segment tree queries.
      #|  Light edges connect chains but are crossed at most O(log n) times.
    ),
  }
}

///|
/// Update a node's value
fn HLDWithSegTree::update(self : HLDWithSegTree, node : Int, val : Int) -> Unit {
  self.node_values[node] = val
  self.seg_tree.update(
    1,
    0,
    self.hld.n - 1,
    self.hld.nodes[node].chain_pos,
    val,
  )
}

// ============================================================================
// EULER TOUR FOR SUBTREE QUERIES
// ============================================================================

///|
struct EulerTourHLD {
  hld : HeavyLightDecomposition
  euler_in : Array[Int] // entry time in Euler tour
  euler_out : Array[Int] // exit time in Euler tour
  mut euler_time : Int
}

///|
fn EulerTourHLD::new(n : Int) -> EulerTourHLD {
  let hld = HeavyLightDecomposition::new(n)
  let euler_in : Array[Int] = Array::make(n, 0)
  let euler_out : Array[Int] = Array::make(n, 0)
  { hld, euler_in, euler_out, euler_time: 0 }
}

///|
/// Build HLD and Euler tour
fn EulerTourHLD::build(self : EulerTourHLD, root : Int) -> Unit {
  self.hld.build(root)
  self.euler_dfs(root, -1)
}

///|
/// DFS for Euler tour
fn EulerTourHLD::euler_dfs(self : EulerTourHLD, u : Int, parent : Int) -> Unit {
  self.euler_in[u] = self.euler_time
  self.euler_time = self.euler_time + 1
  for v in self.hld.adj[u] {
    if v != parent {
      self.euler_dfs(v, u)
    }
  }
  self.euler_out[u] = self.euler_time
}

///|
/// Check if u is ancestor of v
fn EulerTourHLD::is_ancestor(self : EulerTourHLD, u : Int, v : Int) -> Bool {
  self.euler_in[u] <= self.euler_in[v] && self.euler_out[u] >= self.euler_out[v]
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "hld_basic_construction" {
  //     0
  //    /|\
  //   1 2 3
  //   |
  //   4
  let hld = HeavyLightDecomposition::new(5)
  hld.add_edge(0, 1)
  hld.add_edge(0, 2)
  hld.add_edge(0, 3)
  hld.add_edge(1, 4)
  hld.build(0)
  // Check root
  inspect(hld.nodes[0].parent, content="-1")
  inspect(hld.nodes[0].depth, content="0")
  // Check depths
  inspect(hld.nodes[1].depth, content="1")
  inspect(hld.nodes[4].depth, content="2")
  // Node 1 has subtree size 2 (1 and 4), so it should be heavy child of 0
  inspect(hld.nodes[0].heavy_child, content="1")
}

///|
test "hld_lca" {
  //       0
  //      / \
  //     1   2
  //    / \   \
  //   3   4   5
  let hld = HeavyLightDecomposition::new(6)
  hld.add_edge(0, 1)
  hld.add_edge(0, 2)
  hld.add_edge(1, 3)
  hld.add_edge(1, 4)
  hld.add_edge(2, 5)
  hld.build(0)
  inspect(hld.lca(3, 4), content="1")
  inspect(hld.lca(3, 5), content="0")
  inspect(hld.lca(4, 5), content="0")
  inspect(hld.lca(1, 4), content="1")
  inspect(hld.lca(0, 5), content="0")
}

///|
test "hld_path_query_sum" {
  //     0 (val=1)
  //    / \
  //   1   2 (val=2, 3)
  //   |
  //   3 (val=4)
  let hld = HeavyLightDecomposition::new(4)
  hld.add_edge(0, 1)
  hld.add_edge(0, 2)
  hld.add_edge(1, 3)
  hld.build(0)
  let values = [1, 2, 3, 4]
  // Path 3 → 2: goes through 3, 1, 0, 2 = 4 + 2 + 1 + 3 = 10
  let sum = hld.query_path(3, 2, values, fn(a, b) { a + b }, 0)
  inspect(sum, content="10")
}

///|
test "hld_path_query_max" {
  let hld = HeavyLightDecomposition::new(4)
  hld.add_edge(0, 1)
  hld.add_edge(0, 2)
  hld.add_edge(1, 3)
  hld.build(0)
  let values = [10, 5, 20, 3]
  // Path 3 → 2: max of 3, 5, 10, 20 = 20
  let max_val = hld.query_path(
    3,
    2,
    values,
    fn(a, b) { if a > b { a } else { b } },
    0,
  )
  inspect(max_val, content="20")
}

///|
test "hld_with_segtree" {
  //     0 (val=1)
  //    / \
  //   1   2 (val=2, 3)
  //   |
  //   3 (val=4)
  let values = [1, 2, 3, 4]
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3)]
  let hld_st = HLDWithSegTree::new(4, values, edges, 0, fn(a, b) { a + b }, 0)
  // Path 3 → 2: sum = 4 + 2 + 1 + 3 = 10
  inspect(hld_st.query_path(3, 2), content="10")
  // Path 3 → 0: sum = 4 + 2 + 1 = 7
  inspect(hld_st.query_path(3, 0), content="7")
  // Update node 1's value to 10
  hld_st.update(1, 10)
  // Path 3 → 2: sum = 4 + 10 + 1 + 3 = 18
  inspect(hld_st.query_path(3, 2), content="18")
}

///|
test "hld_chain_structure" {
  // Linear chain: 0 - 1 - 2 - 3 - 4
  // Should have one heavy chain
  let hld = HeavyLightDecomposition::new(5)
  hld.add_edge(0, 1)
  hld.add_edge(1, 2)
  hld.add_edge(2, 3)
  hld.add_edge(3, 4)
  hld.build(0)
  // All nodes should have same chain head (root)
  inspect(hld.nodes[0].chain_head, content="0")
  inspect(hld.nodes[1].chain_head, content="0")
  inspect(hld.nodes[2].chain_head, content="0")
  inspect(hld.nodes[3].chain_head, content="0")
  inspect(hld.nodes[4].chain_head, content="0")
}

///|
test "euler_tour_ancestor" {
  //       0
  //      / \
  //     1   2
  //    / \
  //   3   4
  let euler = EulerTourHLD::new(5)
  euler.hld.add_edge(0, 1)
  euler.hld.add_edge(0, 2)
  euler.hld.add_edge(1, 3)
  euler.hld.add_edge(1, 4)
  euler.build(0)
  // 0 is ancestor of all
  inspect(euler.is_ancestor(0, 1), content="true")
  inspect(euler.is_ancestor(0, 3), content="true")
  inspect(euler.is_ancestor(0, 4), content="true")
  inspect(euler.is_ancestor(0, 2), content="true")
  // 1 is ancestor of 3, 4 but not 2
  inspect(euler.is_ancestor(1, 3), content="true")
  inspect(euler.is_ancestor(1, 4), content="true")
  inspect(euler.is_ancestor(1, 2), content="false")
  // 3 is not ancestor of 4
  inspect(euler.is_ancestor(3, 4), content="false")
}
