// ============================================================================
// LI CHAO TREE - Dynamic Convex Hull Trick
// ============================================================================
//
// Li Chao Tree is a segment tree variant for efficiently maintaining a set of
// linear functions f(x) = mx + b and answering maximum/minimum queries at any x.
//
// KEY INSIGHT: At each node, we store a "dominant" line for the interval's midpoint.
// When inserting a new line, we compare at the midpoint:
// - The line winning at midpoint becomes the dominant line
// - The losing line might still win at other points, so we recurse
// - We only need to recurse in ONE direction (where the loser might win)
//
// STRUCTURE:
// - Segment tree over x-coordinates [lo, hi]
// - Each node stores the dominant line for its interval
// - When querying at x, we take max of all dominant lines along the path
//
// EXAMPLE:
// Insert y = 2x + 1, y = -x + 5, y = x + 2
// Query at x=1: max(2*1+1=3, -1+5=4, 1+2=3) = 4
// Query at x=3: max(6+1=7, -3+5=2, 3+2=5) = 7
//
// INVARIANTS:
// 1. Each node's dominant line wins at its interval's midpoint vs any line
//    that was inserted to that node
// 2. The losing line is recursively pushed to a child where it might win
// 3. Query takes max of all O(log N) dominant lines along root-to-leaf path
//
// TIME COMPLEXITY:
// - Insert line: O(log N)
// - Query at x: O(log N)
//
// APPLICATIONS:
// - DP optimization (slope trick, divide and conquer optimization)
// - Maintaining upper/lower envelope of lines
// - Shortest path in DAG with weighted edges

///|
/// A line y = mx + b
priv struct Line {
  m : Int64 // Slope
  b : Int64 // Y-intercept
}

///|
/// Evaluate line at x
fn Line::eval(self : Line, x : Int64) -> Int64 {
  self.m * x + self.b
}

///|
/// Special "undefined" line that always loses
fn undefined_line() -> Line {
  { m: 0L, b: -9223372036854775807L } // MIN_INT64 + 1
}

///|
/// Check if line is undefined
fn Line::is_undefined(self : Line) -> Bool {
  self.b == -9223372036854775807L && self.m == 0L
}

///|
/// Li Chao Tree node
priv struct LCNode {
  mut line : Line
  mut left : Int // Child indices (-1 for none)
  mut right : Int
}

///|
/// Li Chao Tree for maximum queries
priv struct LiChaoTree {
  nodes : Array[LCNode]
  lo : Int64 // Coordinate range
  hi : Int64
}

///|
fn LiChaoTree::new(lo : Int64, hi : Int64) -> LiChaoTree {
  let nodes : Array[LCNode] = []
  // Create root node with undefined line
  nodes.push({ line: undefined_line(), left: -1, right: -1 })
  { nodes, lo, hi }
}

///|
/// Create a new node and return its index
fn LiChaoTree::new_node(self : LiChaoTree) -> Int {
  let idx = self.nodes.length()
  self.nodes.push({ line: undefined_line(), left: -1, right: -1 })
  idx
}

///|
/// Insert a line y = mx + b
/// REASONING: We traverse the tree, at each node comparing our line with the
/// dominant line at the midpoint. The winner stays, the loser recurses to
/// the child where it might still win.
fn LiChaoTree::insert(self : LiChaoTree, m : Int64, b : Int64) -> Unit {
  let line : Line = { m, b }
  insert_line(self, 0, self.lo, self.hi, line)
}

///|
/// Insert line into subtree
/// INVARIANT: After insertion, for any x in [lo, hi], the maximum over all
/// inserted lines is found by taking max of dominant lines on path from root.
fn insert_line(
  tree : LiChaoTree,
  node_idx : Int,
  lo : Int64,
  hi : Int64,
  new_line : Line
) -> Unit {
  let node = tree.nodes[node_idx]

  // If node's line is undefined, just set it
  if node.line.is_undefined() {
    tree.nodes[node_idx].line = new_line
    return
  }

  let mid = (lo + hi) / 2L

  // Compare at midpoint
  let curr_at_mid = node.line.eval(mid)
  let new_at_mid = new_line.eval(mid)

  // Determine winner at midpoint
  let mut winner = node.line
  let mut loser = new_line
  if new_at_mid > curr_at_mid {
    winner = new_line
    loser = node.line
  }

  tree.nodes[node_idx].line = winner

  // The loser might win in one of the halves
  // Check where the loser might dominate based on slopes

  if lo == hi {
    // Leaf node, no children to push to
    return
  }

  // Compare at left endpoint to determine which side loser might win
  let winner_at_lo = winner.eval(lo)
  let loser_at_lo = loser.eval(lo)

  // INVARIANT: Loser might win in left half if it wins at lo
  // Loser might win in right half if it wins at hi
  if loser_at_lo > winner_at_lo {
    // Loser might win in left half
    if tree.nodes[node_idx].left < 0 {
      tree.nodes[node_idx].left = tree.new_node()
    }
    insert_line(tree, tree.nodes[node_idx].left, lo, mid, loser)
  } else {
    // Loser might win in right half
    if tree.nodes[node_idx].right < 0 {
      tree.nodes[node_idx].right = tree.new_node()
    }
    insert_line(tree, tree.nodes[node_idx].right, mid + 1L, hi, loser)
  }
}

///|
/// Query maximum y-value at x
fn LiChaoTree::query(self : LiChaoTree, x : Int64) -> Int64 {
  query_max(self, 0, self.lo, self.hi, x)
}

///|
/// Query maximum from subtree
/// INVARIANT: Returns max of all dominant lines on path to leaf containing x
fn query_max(
  tree : LiChaoTree,
  node_idx : Int,
  lo : Int64,
  hi : Int64,
  x : Int64
) -> Int64 {
  if node_idx < 0 {
    return -9223372036854775807L // Return minimum for undefined
  }

  let node = tree.nodes[node_idx]
  let curr_val = if node.line.is_undefined() {
    -9223372036854775807L
  } else {
    node.line.eval(x)
  }

  if lo == hi {
    return curr_val
  }

  let mid = (lo + hi) / 2L

  // INVARIANT: x is in exactly one child's range
  if x <= mid {
    let child_val = query_max(tree, node.left, lo, mid, x)
    if child_val > curr_val {
      child_val
    } else {
      curr_val
    }
  } else {
    let child_val = query_max(tree, node.right, mid + 1L, hi, x)
    if child_val > curr_val {
      child_val
    } else {
      curr_val
    }
  }
}

///|
/// Get number of nodes in tree
fn LiChaoTree::node_count(self : LiChaoTree) -> Int {
  self.nodes.length()
}

// ============================================================================
// LI CHAO TREE FOR MINIMUM QUERIES
// ============================================================================

///|
/// Special "undefined" line that always loses in min queries
fn undefined_line_min() -> Line {
  { m: 0L, b: 9223372036854775806L } // MAX_INT64 - 1
}

///|
fn Line::is_undefined_min(self : Line) -> Bool {
  self.b == 9223372036854775806L && self.m == 0L
}

///|
/// Li Chao Tree for minimum queries
priv struct LiChaoTreeMin {
  nodes : Array[LCNode]
  lo : Int64
  hi : Int64
}

///|
fn LiChaoTreeMin::new(lo : Int64, hi : Int64) -> LiChaoTreeMin {
  let nodes : Array[LCNode] = []
  nodes.push({ line: undefined_line_min(), left: -1, right: -1 })
  { nodes, lo, hi }
}

///|
fn LiChaoTreeMin::new_node(self : LiChaoTreeMin) -> Int {
  let idx = self.nodes.length()
  self.nodes.push({ line: undefined_line_min(), left: -1, right: -1 })
  idx
}

///|
/// Insert a line y = mx + b for minimum queries
fn LiChaoTreeMin::insert(self : LiChaoTreeMin, m : Int64, b : Int64) -> Unit {
  let line : Line = { m, b }
  insert_line_min(self, 0, self.lo, self.hi, line)
}

///|
fn insert_line_min(
  tree : LiChaoTreeMin,
  node_idx : Int,
  lo : Int64,
  hi : Int64,
  new_line : Line
) -> Unit {
  let node = tree.nodes[node_idx]

  if node.line.is_undefined_min() {
    tree.nodes[node_idx].line = new_line
    return
  }

  let mid = (lo + hi) / 2L
  let curr_at_mid = node.line.eval(mid)
  let new_at_mid = new_line.eval(mid)

  // For minimum, winner has smaller value at midpoint
  let mut winner = node.line
  let mut loser = new_line
  if new_at_mid < curr_at_mid {
    winner = new_line
    loser = node.line
  }

  tree.nodes[node_idx].line = winner

  if lo == hi {
    return
  }

  let winner_at_lo = winner.eval(lo)
  let loser_at_lo = loser.eval(lo)

  // Loser might win (have smaller value) in one half
  if loser_at_lo < winner_at_lo {
    if tree.nodes[node_idx].left < 0 {
      tree.nodes[node_idx].left = tree.new_node()
    }
    insert_line_min(tree, tree.nodes[node_idx].left, lo, mid, loser)
  } else {
    if tree.nodes[node_idx].right < 0 {
      tree.nodes[node_idx].right = tree.new_node()
    }
    insert_line_min(tree, tree.nodes[node_idx].right, mid + 1L, hi, loser)
  }
}

///|
/// Query minimum y-value at x
fn LiChaoTreeMin::query(self : LiChaoTreeMin, x : Int64) -> Int64 {
  query_min_impl(self, 0, self.lo, self.hi, x)
}

///|
fn query_min_impl(
  tree : LiChaoTreeMin,
  node_idx : Int,
  lo : Int64,
  hi : Int64,
  x : Int64
) -> Int64 {
  if node_idx < 0 {
    return 9223372036854775806L
  }

  let node = tree.nodes[node_idx]
  let curr_val = if node.line.is_undefined_min() {
    9223372036854775806L
  } else {
    node.line.eval(x)
  }

  if lo == hi {
    return curr_val
  }

  let mid = (lo + hi) / 2L

  if x <= mid {
    let child_val = query_min_impl(tree, node.left, lo, mid, x)
    if child_val < curr_val {
      child_val
    } else {
      curr_val
    }
  } else {
    let child_val = query_min_impl(tree, node.right, mid + 1L, hi, x)
    if child_val < curr_val {
      child_val
    } else {
      curr_val
    }
  }
}

///|
fn LiChaoTreeMin::node_count(self : LiChaoTreeMin) -> Int {
  self.nodes.length()
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "lichao basic max" {
  let tree = LiChaoTree::new(-100L, 100L)

  // Insert y = 2x + 1
  tree.insert(2L, 1L)

  inspect(tree.query(0L), content="1") // 2*0+1 = 1
  inspect(tree.query(5L), content="11") // 2*5+1 = 11
  inspect(tree.query(-3L), content="-5") // 2*(-3)+1 = -5
}

///|
test "lichao multiple lines max" {
  let tree = LiChaoTree::new(-10L, 10L)

  // Insert y = 2x + 1
  tree.insert(2L, 1L)
  // Insert y = -x + 5
  tree.insert(-1L, 5L)
  // Insert y = x + 2
  tree.insert(1L, 2L)

  // At x = 0: max(1, 5, 2) = 5
  inspect(tree.query(0L), content="5")

  // At x = 1: max(3, 4, 3) = 4
  inspect(tree.query(1L), content="4")

  // At x = 3: max(7, 2, 5) = 7
  inspect(tree.query(3L), content="7")

  // At x = -2: max(-3, 7, 0) = 7
  inspect(tree.query(-2L), content="7")
}

///|
test "lichao single line" {
  let tree = LiChaoTree::new(0L, 100L)

  tree.insert(3L, 5L) // y = 3x + 5

  inspect(tree.query(0L), content="5")
  inspect(tree.query(10L), content="35")
  inspect(tree.query(100L), content="305")
}

///|
test "lichao horizontal lines" {
  let tree = LiChaoTree::new(0L, 100L)

  tree.insert(0L, 10L) // y = 10
  tree.insert(0L, 20L) // y = 20
  tree.insert(0L, 5L) // y = 5

  // All queries should return 20 (maximum horizontal line)
  inspect(tree.query(0L), content="20")
  inspect(tree.query(50L), content="20")
  inspect(tree.query(100L), content="20")
}

///|
test "lichao crossing lines" {
  let tree = LiChaoTree::new(-100L, 100L)

  // y = x (crosses y-axis at 0)
  tree.insert(1L, 0L)
  // y = -x + 10 (crosses y-axis at 10)
  tree.insert(-1L, 10L)

  // They cross at x = 5 where both equal 5
  // For x < 5: -x + 10 > x
  // For x > 5: x > -x + 10

  inspect(tree.query(0L), content="10") // max(0, 10) = 10
  inspect(tree.query(5L), content="5") // max(5, 5) = 5
  inspect(tree.query(10L), content="10") // max(10, 0) = 10
  inspect(tree.query(-5L), content="15") // max(-5, 15) = 15
}

///|
test "lichao min basic" {
  let tree = LiChaoTreeMin::new(-100L, 100L)

  tree.insert(2L, 1L) // y = 2x + 1
  tree.insert(-1L, 5L) // y = -x + 5

  // At x = 0: min(1, 5) = 1
  inspect(tree.query(0L), content="1")

  // At x = 1: min(3, 4) = 3
  inspect(tree.query(1L), content="3")

  // At x = -2: min(-3, 7) = -3
  inspect(tree.query(-2L), content="-3")
}

///|
test "lichao min multiple" {
  let tree = LiChaoTreeMin::new(0L, 100L)

  tree.insert(1L, 100L) // y = x + 100
  tree.insert(2L, 0L) // y = 2x
  tree.insert(-1L, 200L) // y = -x + 200

  // At x = 0: min(100, 0, 200) = 0
  inspect(tree.query(0L), content="0")

  // At x = 50: min(150, 100, 150) = 100
  inspect(tree.query(50L), content="100")

  // At x = 100: min(200, 200, 100) = 100
  inspect(tree.query(100L), content="100")
}

///|
test "lichao large range" {
  let tree = LiChaoTree::new(-1000000000L, 1000000000L)

  tree.insert(1L, 0L)
  tree.insert(-1L, 0L)

  // At x = 0: max(0, 0) = 0
  inspect(tree.query(0L), content="0")

  // At x = 1000000: max(1000000, -1000000) = 1000000
  inspect(tree.query(1000000L), content="1000000")

  // At x = -1000000: max(-1000000, 1000000) = 1000000
  inspect(tree.query(-1000000L), content="1000000")
}

///|
test "lichao node efficiency" {
  let tree = LiChaoTree::new(0L, 1000000L)

  // Insert several lines
  for i = 0; i < 10; i = i + 1 {
    tree.insert(i.to_int64(), (10 - i).to_int64())
  }

  // Should create relatively few nodes
  let nodes = tree.node_count()
  inspect(nodes < 100, content="true")
}

///|
test "lichao empty query" {
  let tree = LiChaoTree::new(0L, 100L)

  // Query on empty tree returns minimum value
  let result = tree.query(50L)
  inspect(result < 0L, content="true")
}

///|
test "lichao parallel lines" {
  let tree = LiChaoTree::new(0L, 100L)

  // Parallel lines with same slope
  tree.insert(2L, 1L) // y = 2x + 1
  tree.insert(2L, 5L) // y = 2x + 5
  tree.insert(2L, 3L) // y = 2x + 3

  // The one with highest intercept always wins
  inspect(tree.query(0L), content="5")
  inspect(tree.query(50L), content="105")
}

///|
test "lichao steep slopes" {
  let tree = LiChaoTree::new(-10L, 10L)

  tree.insert(100L, 0L) // Very steep positive
  tree.insert(-100L, 0L) // Very steep negative

  // At x = 0: max(0, 0) = 0
  inspect(tree.query(0L), content="0")

  // At x = 5: max(500, -500) = 500
  inspect(tree.query(5L), content="500")

  // At x = -5: max(-500, 500) = 500
  inspect(tree.query(-5L), content="500")
}

///|
test "lichao min node count" {
  let tree = LiChaoTreeMin::new(0L, 1000L)

  tree.insert(1L, 0L)
  tree.insert(-1L, 100L)
  tree.insert(0L, 50L)

  // Verify node count is reasonable
  inspect(tree.node_count() < 50, content="true")
}
