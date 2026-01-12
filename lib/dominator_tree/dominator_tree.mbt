// ============================================================================
// DOMINATOR TREE - Lengauer-Tarjan Algorithm
// ============================================================================
//
// In a directed graph with a start node s:
// A vertex u dominates v if every path from s to v goes through u.
// The immediate dominator idom[v] is the closest strict dominator of v.
//
// The dominator tree is formed by edges idom[v] -> v for all v != s.
//
// ALGORITHM (Lengauer-Tarjan, O((V+E) * alpha)):
// 1. DFS from s, numbering vertices by discovery order (dfs index)
// 2. Compute semi-dominators (sdom) using union-find with path compression
// 3. Compute idom candidates via buckets
// 4. Finalize idom with a second pass
//
// INVARIANTS:
// 1. DFS numbering is a tree: parent index < child index
// 2. sdom[i] is the minimal dfs index reachable from i via one back edge
//    and any number of tree edges
// 3. The union-find structure maintains the best label for semi-dominator queries
//
// TIME COMPLEXITY: O((V + E) * alpha(V))
// SPACE COMPLEXITY: O(V + E)

///|
priv struct Counter {
  mut val : Int
}

///|
fn build_adj_lists(n : Int) -> Array[Array[Int]] {
  let adj = Array::make(n, [])
  for i = 0; i < n; i = i + 1 {
    adj[i] = []
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (adj init):
      #|adj[0..i) are distinct empty lists.
      #|MAINTENANCE:
      #|Assign a fresh list at adj[i].
      #|TERMINATION:
      #|At i = n, adjacency is initialized.
    ),
  }
  adj
}

///|
priv struct DominatorWork {
  n : Int
  adj : Array[Array[Int]]
  pred : Array[Array[Int]]
  arr : Array[Int] // vertex -> dfs index (0 if unreachable)
  rev : Array[Int] // dfs index -> vertex
  parent : Array[Int] // dfs parent (by dfs index)
  sdom : Array[Int]
  idom : Array[Int]
  dsu : Array[Int]
  label : Array[Int]
  bucket : Array[Array[Int]]
  time : Counter
}

///|
fn DominatorWork::new(n : Int) -> DominatorWork {
  let adj = build_adj_lists(n)
  let pred = build_adj_lists(n + 1)
  {
    n,
    adj,
    pred,
    arr: Array::make(n, 0),
    rev: Array::make(n + 1, 0),
    parent: Array::make(n + 1, 0),
    sdom: Array::make(n + 1, 0),
    idom: Array::make(n + 1, 0),
    dsu: Array::make(n + 1, 0),
    label: Array::make(n + 1, 0),
    bucket: build_adj_lists(n + 1),
    time: { val: 0 },
  }
}

///|
fn DominatorWork::add_edge(self : DominatorWork, u : Int, v : Int) -> Unit {
  self.adj[u].push(v)
}

///|
fn DominatorWork::dfs(self : DominatorWork, u : Int) -> Unit {
  self.time.val = self.time.val + 1
  let t = self.time.val
  self.arr[u] = t
  self.rev[t] = u
  self.sdom[t] = t
  self.label[t] = t
  self.dsu[t] = t
  for i = 0; i < self.adj[u].length(); i = i + 1 {
    let v = self.adj[u][i]
    if self.arr[v] == 0 {
      self.dfs(v)
      self.parent[self.arr[v]] = t
    }
  } where {
    invariant: i >= 0 && i <= self.adj[u].length(),
    reasoning: (
      #|INVARIANT (DFS tree):
      #|Vertices in adj[u][0..i) are explored; their dfs indices are assigned
      #|and parent[] recorded in the DFS tree.
      #|MAINTENANCE:
      #|Recurse on unvisited neighbors and set their parent index to t.
      #|TERMINATION:
      #|At i = deg(u), all reachable neighbors are discovered.
    ),
  }
}

///|
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn DominatorWork::compress(self : DominatorWork, v : Int) -> Unit {
  if self.dsu[self.dsu[v]] != self.dsu[v] {
    self.compress(self.dsu[v])
    if self.sdom[self.label[self.dsu[v]]] < self.sdom[self.label[v]] {
      self.label[v] = self.label[self.dsu[v]]
    }
    self.dsu[v] = self.dsu[self.dsu[v]]
  }
}

///|
fn DominatorWork::eval(self : DominatorWork, v : Int) -> Int {
  if self.dsu[v] == v {
    v
  } else {
    self.compress(v)
    self.label[v]
  }
}

///|
fn DominatorWork::link(self : DominatorWork, u : Int, v : Int) -> Unit {
  self.dsu[v] = u
}

///|
fn DominatorWork::build_predecessors(
  self : DominatorWork,
  edges : ArrayView[(Int, Int)],
) -> Unit {
  for i = 0; i < edges.length(); i = i + 1 {
    let (u, v) = edges[i]
    if u >= 0 && u < self.n && v >= 0 && v < self.n {
      let du = self.arr[u]
      let dv = self.arr[v]
      if du != 0 && dv != 0 {
        self.pred[dv].push(du)
      }
    }
  } where {
    invariant: i >= 0 && i <= edges.length(),
    reasoning: (
      #|INVARIANT (pred build):
      #|All edges[0..i) between reachable vertices are added to pred by dfs index.
      #|MAINTENANCE:
      #|Insert the predecessor index for each reachable edge.
      #|TERMINATION:
      #|At i = edges.length(), all predecessors are collected.
    ),
  }
}

///|
fn DominatorWork::compute_idom(self : DominatorWork, root_idx : Int) -> Unit {
  let n = self.time.val
  // Process vertices in reverse dfs order
  for i = n; i >= 1; i = i - 1 {
    // Compute semi-dominator
    for p in self.pred[i] {
      let u = self.eval(p)
      self.sdom[i] = min(self.sdom[i], self.sdom[u])
    }
    if i > 1 {
      self.bucket[self.sdom[i]].push(i)
    }

    // Resolve immediate dominators in bucket
    for v in self.bucket[i] {
      let u = self.eval(v)
      if self.sdom[u] == self.sdom[v] {
        self.idom[v] = self.sdom[v]
      } else {
        self.idom[v] = u
      }
    }
    if i > 1 {
      self.link(self.parent[i], i)
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (reverse pass):
      #|For all indices > i, sdom and tentative idom are computed and buckets
      #|processed; union-find links are established for those indices.
      #|MAINTENANCE:
      #|Compute sdom[i], resolve bucket[i], and link parent[i] to i.
      #|TERMINATION:
      #|At i = 1, all vertices have tentative idom values.
    ),
  }

  // Finalize idom with second pass
  for i = 2; i <= n; i = i + 1 {
    if self.idom[i] != self.sdom[i] {
      self.idom[i] = self.idom[self.idom[i]]
    }
  } where {
    invariant: i >= 2 && i <= n + 1,
    reasoning: (
      #|INVARIANT (idom fix):
      #|For indices in [2..i), idom is corrected to the nearest dominator.
      #|MAINTENANCE:
      #|Replace idom[i] by idom[idom[i]] when necessary.
      #|TERMINATION:
      #|At i = n+1, all idom values are finalized.
    ),
  }
  self.idom[root_idx] = root_idx
}

///|
/// Dominator tree result.
pub(all) struct DominatorTree {
  root : Int
  idom : Array[Int] // immediate dominator (root dominates itself, -1 unreachable)
  tree : Array[Array[Int]]
}

///|
/// Build a dominator tree from a directed graph rooted at `root`.
/// Returns None if root is invalid.
pub fn build_dominator_tree(
  n : Int,
  edges : ArrayView[(Int, Int)],
  root : Int,
) -> DominatorTree? {
  if n <= 0 || root < 0 || root >= n {
    return None
  }
  let work = DominatorWork::new(n)
  for i = 0; i < edges.length(); i = i + 1 {
    let (u, v) = edges[i]
    if u >= 0 && u < n && v >= 0 && v < n {
      work.add_edge(u, v)
    }
  } where {
    invariant: i >= 0 && i <= edges.length(),
    reasoning: (
      #|INVARIANT (edge add):
      #|Edges[0..i) are inserted into adjacency lists.
      #|MAINTENANCE:
      #|Insert the next edge if endpoints are in range.
      #|TERMINATION:
      #|At i = edges.length(), the graph is fully built.
    ),
  }
  work.dfs(root)
  let root_idx = work.arr[root]
  if root_idx == 0 {
    return None
  }
  work.build_predecessors(edges)
  work.compute_idom(root_idx)
  let idom_vertex = Array::make(n, -1)
  for i = 1; i <= work.time.val; i = i + 1 {
    let v = work.rev[i]
    let id = work.idom[i]
    idom_vertex[v] = work.rev[id]
  } where {
    invariant: i >= 1 && i <= work.time.val + 1,
    reasoning: (
      #|INVARIANT (idom map):
      #|idom_vertex is filled for dfs indices in [1..i).
      #|MAINTENANCE:
      #|Map the idom dfs index back to vertex id.
      #|TERMINATION:
      #|At i = time+1, all reachable vertices have idom set.
    ),
  }
  let tree = build_adj_lists(n)
  for v = 0; v < n; v = v + 1 {
    let p = idom_vertex[v]
    if p >= 0 && v != root {
      tree[p].push(v)
    }
  } where {
    invariant: v >= 0 && v <= n,
    reasoning: (
      #|INVARIANT (tree build):
      #|Dominator tree children are added for vertices in [0..v).
      #|MAINTENANCE:
      #|Add edge idom[v] -> v when v is reachable and not root.
      #|TERMINATION:
      #|At v = n, the dominator tree is built.
    ),
  }
  Some({ root, idom: idom_vertex, tree })
}

///|
/// Check if u dominates v in the dominator tree (O(depth)).
pub fn DominatorTree::dominates(self : DominatorTree, u : Int, v : Int) -> Bool {
  if u < 0 || v < 0 || u >= self.idom.length() || v >= self.idom.length() {
    return false
  }
  if self.idom[v] == -1 {
    return false
  }
  let mut cur = v
  while true {
    if cur == u {
      return true
    }
    let p = self.idom[cur]
    if p == cur || p < 0 {
      break
    }
    cur = p
  }
  false
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "dominator tree basic" {
  let edges : Array[(Int, Int)] = [
    (0, 1),
    (1, 2),
    (2, 3),
    (1, 3),
    (3, 4),
    (4, 5),
    (2, 5),
  ]
  let dom = build_dominator_tree(6, edges[:], 0).unwrap()
  inspect(dom.idom[0], content="0")
  inspect(dom.idom[1], content="0")
  inspect(dom.idom[2], content="1")
  inspect(dom.idom[3], content="1")
  inspect(dom.idom[4], content="3")
  inspect(dom.idom[5], content="1")
  inspect(dom.dominates(1, 5), content="true")
  inspect(dom.dominates(2, 5), content="false")
}

///|
test "dominator tree unreachable" {
  let edges : Array[(Int, Int)] = [(0, 1), (2, 3)]
  let dom = build_dominator_tree(4, edges[:], 0).unwrap()
  inspect(dom.idom[2], content="-1")
  inspect(dom.dominates(0, 2), content="false")
}
