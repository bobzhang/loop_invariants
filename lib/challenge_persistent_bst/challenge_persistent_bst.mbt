// ============================================================================
// Challenge: Persistent Binary Search Tree
// Immutable insert and iterative search with bounds invariants
// ============================================================================

///|
pub enum Tree[T] {
  Empty
  Node(value~ : T, left~ : Tree[T], right~ : Tree[T])
} derive(Show)

///|
fn[T] tree_size(t : Tree[T]) -> Int {
  match t {
    Tree::Empty => 0
    Tree::Node(value=_, left~, right~) => 1 + tree_size(left) + tree_size(right)
  }
}

///|

///|
/// Create an empty persistent BST.
pub fn[T] empty() -> Tree[T] {
  Tree::Empty
}

///|
/// Return number of nodes in the tree.
pub fn[T] size(t : Tree[T]) -> Int {
  tree_size(t)
}

///|
/// Insert a value and return the new tree.
pub fn[T : Compare] insert(t : Tree[T], value : T) -> Tree[T] {
  match t {
    Tree::Empty => Tree::Node(value~, left=Tree::Empty, right=Tree::Empty)
    Tree::Node(value=v, left=l, right=r) =>
      if value == v {
        t
      } else if value < v {
        Tree::Node(value=v, left=insert(l, value), right=r)
      } else {
        Tree::Node(value=v, left=l, right=insert(r, value))
      }
  }
}

///|
/// Check whether value exists in the tree.
pub fn[T : Compare] contains(t : Tree[T], value : T) -> Bool {
  match t {
    Tree::Empty => false
    Tree::Node(value=v, left=l, right=r) =>
      if value == v {
        true
      } else if value < v {
        contains(l, value)
      } else {
        contains(r, value)
      }
  }
}

///|
/// Build a BST by inserting elements in order.
pub fn[T : Compare] from_array(arr : ArrayView[T]) -> Tree[T] {
  let mut tree = Tree::Empty
  for value in arr {
    tree = insert(tree, value)
  }
  tree
}

///|
/// Return an in-order traversal (sorted values).
pub fn[T] inorder(t : Tree[T]) -> Array[T] {
  match t {
    Tree::Empty => []
    Tree::Node(value=v, left=l, right=r) => inorder(l) + [v] + inorder(r)
  }
}
