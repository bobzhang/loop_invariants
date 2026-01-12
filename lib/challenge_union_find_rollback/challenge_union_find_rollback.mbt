// ============================================================================
// Challenge: Union-Find with Rollback
// ============================================================================

///|
pub struct RollbackDSU {
  parent : Array[Int]
  size : Array[Int]
  history : Array[(Int, Int)] // (child, parent_size_before)
}

///|
pub fn RollbackDSU::new(n : Int) -> RollbackDSU {
  let parent : Array[Int] = Array::make(n, 0)
  let size : Array[Int] = Array::make(n, 1)
  for i = 0; i < n; i = i + 1 {
    parent[i] = i
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (Parent init):
      #|parent[0..i) are initialized to themselves.
      #|MAINTENANCE:
      #|Set parent[i] = i and advance.
      #|TERMINATION:
      #|At i = n, all parents are initialized.
    ),
  }
  { parent, size, history: [] }
}

///|
pub fn RollbackDSU::find(self : RollbackDSU, x : Int) -> Int {
  for cur = x; self.parent[cur] != cur; {
    continue self.parent[cur]
  } else {
    cur
  } where {
    invariant: cur >= 0,
    reasoning: (
      #|INVARIANT (Root chase):
      #|cur stays on the parent chain of x.
      #|MAINTENANCE:
      #|Advance cur to its parent until a root is found.
      #|TERMINATION:
      #|When parent[cur] == cur, cur is the root.
    ),
  }
}

///|
pub fn RollbackDSU::union(self : RollbackDSU, a : Int, b : Int) -> Bool {
  let mut ra = self.find(a)
  let mut rb = self.find(b)
  if ra == rb {
    self.history.push((-1, 0))
    return false
  }
  if self.size[ra] < self.size[rb] {
    let tmp = ra
    ra = rb
    rb = tmp
  }
  self.history.push((rb, self.size[ra]))
  self.parent[rb] = ra
  self.size[ra] = self.size[ra] + self.size[rb]
  true
}

///|
pub fn RollbackDSU::snapshot(self : RollbackDSU) -> Int {
  self.history.length()
}

///|
#warnings("+missing_invariant+missing_reasoning")
pub fn RollbackDSU::rollback(self : RollbackDSU, snap : Int) -> Unit {
  for len = self.history.length(); len > snap; {
    let (child, parent_size) = self.history.pop().unwrap()
    if child >= 0 {
      let root = self.parent[child]
      self.size[root] = parent_size
      self.parent[child] = child
    }
    continue self.history.length()
  } where {
    invariant: len == self.history.length(),
    reasoning: (
      #|INVARIANT (Rollback stack):
      #|len tracks the current history size as we undo unions.
      #|MAINTENANCE:
      #|Pop one change and restore parent/size if it was a real union.
      #|TERMINATION:
      #|When len == snap, all later unions are undone.
    ),
  }
}

///|
pub fn RollbackDSU::same(self : RollbackDSU, a : Int, b : Int) -> Bool {
  self.find(a) == self.find(b)
}

///|
test "rollback_dsu" {
  let dsu = RollbackDSU::new(4)
  let _ = dsu.union(0, 1)
  let _ = dsu.union(2, 3)
  let snap = dsu.snapshot()
  let _ = dsu.union(1, 2)
  assert_true(dsu.same(0, 3))
  dsu.rollback(snap)
  assert_true(not(dsu.same(0, 3)))
  assert_true(dsu.same(0, 1))
  assert_true(dsu.same(2, 3))
}
