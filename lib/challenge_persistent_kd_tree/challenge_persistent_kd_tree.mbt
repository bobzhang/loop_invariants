// ============================================================================
// Challenge: Persistent KD-Tree (2D)
// Immutable insertion with alternating split axis
// ============================================================================

///|
pub(all) struct Point {
  x : Int
  y : Int
} derive(Show, Eq)

///|
pub enum Kd {
  Empty
  Node(point~ : Point, axis~ : Int, left~ : Kd, right~ : Kd)
} derive(Show)

///|
/// Return the number of points stored in the tree.
pub fn size(t : Kd) -> Int {
  match t {
    Empty => 0
    Node(point=_, axis=_, left~, right~) => 1 + size(left) + size(right)
  }
}

///|
fn coord(p : Point, axis : Int) -> Int {
  if axis == 0 {
    p.x
  } else {
    p.y
  }
}

///|
fn insert_node(t : Kd, p : Point, axis : Int) -> Kd {
  match t {
    Empty => Node(point=p, axis~, left=Empty, right=Empty)
    Node(point=pt, axis=ax, left=l, right=r) =>
      if p == pt {
        t
      } else if coord(p, ax) < coord(pt, ax) {
        Node(point=pt, axis=ax, left=insert_node(l, p, 1 - ax), right=r)
      } else {
        Node(point=pt, axis=ax, left=l, right=insert_node(r, p, 1 - ax))
      }
  }
}

///|
/// Create an empty KD-tree.
pub fn empty() -> Kd {
  Empty
}

///|
/// Insert a point and return the new tree.
pub fn insert(t : Kd, p : Point) -> Kd {
  insert_node(t, p, 0)
}

///|
/// Check whether a point exists in the tree.
pub fn contains(t : Kd, p : Point) -> Bool {
  match t {
    Empty => false
    Node(point=pt, axis=ax, left=l, right=r) =>
      if p == pt {
        true
      } else if coord(p, ax) < coord(pt, ax) {
        contains(l, p)
      } else {
        contains(r, p)
      }
  }
}

///|
/// Iterative containment with reasoning on split axis.
pub fn contains_iter(t : Kd, p : Point) -> Bool {
  match t {
    Empty => false
    Node(point=pt, axis=ax, left=l, right=r) =>
      if p == pt {
        true
      } else if coord(p, ax) < coord(pt, ax) {
        contains_iter(l, p)
      } else {
        contains_iter(r, p)
      }
  }
}

///|
/// Build a KD-tree by inserting points in order.
pub fn from_array(arr : ArrayView[Point]) -> Kd {
  let mut tree = Empty
  for point in arr {
    tree = insert(tree, point)
  }
  tree
}
