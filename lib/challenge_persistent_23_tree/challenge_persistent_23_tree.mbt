// ============================================================================
// Challenge: Persistent 2-3 Tree
// Balanced search tree with node splitting
// ============================================================================

///|
pub enum Tree[T] {
  Empty
  Two(key~ : T, left~ : Tree[T], right~ : Tree[T])
  Three(
    key1~ : T,
    key2~ : T,
    left~ : Tree[T],
    middle~ : Tree[T],
    right~ : Tree[T]
  )
} derive(Show)

///|
enum InsertResult[T] {
  Done(tree~ : Tree[T])
  Split(key~ : T, left~ : Tree[T], right~ : Tree[T])
} derive(Show)

///|
/// Return the number of keys in the tree.
pub fn[T] size(t : Tree[T]) -> Int {
  match t {
    Tree::Empty => 0
    Tree::Two(key=_, left~, right~) => 1 + size(left) + size(right)
    Tree::Three(key1=_, key2=_, left~, middle~, right~) =>
      2 + size(left) + size(middle) + size(right)
  }
}

///|
fn[T : Compare] within_bounds(value : T, lo : T?, hi : T?) -> Bool {
  let lo_ok = match lo {
    None => true
    Some(l) => value > l
  }
  let hi_ok = match hi {
    None => true
    Some(h) => value < h
  }
  lo_ok && hi_ok
}

///|
fn[T : Compare] tree_valid(t : Tree[T], lo : T?, hi : T?) -> Bool {
  match t {
    Tree::Empty => true
    Tree::Two(key=k, left=l, right=r) =>
      within_bounds(k, lo, hi) &&
      tree_valid(l, lo, Some(k)) &&
      tree_valid(r, Some(k), hi)
    Tree::Three(key1=k1, key2=k2, left=l, middle=m, right=r) =>
      k1 < k2 &&
      within_bounds(k1, lo, hi) &&
      within_bounds(k2, lo, hi) &&
      tree_valid(l, lo, Some(k1)) &&
      tree_valid(m, Some(k1), Some(k2)) &&
      tree_valid(r, Some(k2), hi)
  }
}

///|
fn[T : Compare] insert_inner(t : Tree[T], key : T) -> InsertResult[T] {
  match t {
    Tree::Empty =>
      InsertResult::Done(
        tree=Tree::Two(key~, left=Tree::Empty, right=Tree::Empty),
      )
    Tree::Two(key=k, left=l, right=r) =>
      if key == k {
        InsertResult::Done(tree=t)
      } else if key < k {
        match insert_inner(l, key) {
          InsertResult::Done(tree=new_left) =>
            InsertResult::Done(tree=Tree::Two(key=k, left=new_left, right=r))
          InsertResult::Split(key=pk, left=pl, right=pr) =>
            InsertResult::Done(
              tree=Tree::Three(key1=pk, key2=k, left=pl, middle=pr, right=r),
            )
        }
      } else {
        match insert_inner(r, key) {
          InsertResult::Done(tree=new_right) =>
            InsertResult::Done(tree=Tree::Two(key=k, left=l, right=new_right))
          InsertResult::Split(key=pk, left=pl, right=pr) =>
            InsertResult::Done(
              tree=Tree::Three(key1=k, key2=pk, left=l, middle=pl, right=pr),
            )
        }
      }
    Tree::Three(key1=k1, key2=k2, left=l, middle=m, right=r) =>
      if key == k1 || key == k2 {
        InsertResult::Done(tree=t)
      } else if key < k1 {
        match insert_inner(l, key) {
          InsertResult::Done(tree=new_left) =>
            InsertResult::Done(
              tree=Tree::Three(
                key1=k1,
                key2=k2,
                left=new_left,
                middle=m,
                right=r,
              ),
            )
          InsertResult::Split(key=pk, left=pl, right=pr) => {
            let left_node = Tree::Two(key=pk, left=pl, right=pr)
            let right_node = Tree::Two(key=k2, left=m, right=r)
            InsertResult::Split(key=k1, left=left_node, right=right_node)
          }
        }
      } else if key < k2 {
        match insert_inner(m, key) {
          InsertResult::Done(tree=new_mid) =>
            InsertResult::Done(
              tree=Tree::Three(
                key1=k1,
                key2=k2,
                left=l,
                middle=new_mid,
                right=r,
              ),
            )
          InsertResult::Split(key=pk, left=pl, right=pr) => {
            let left_node = Tree::Two(key=k1, left=l, right=pl)
            let right_node = Tree::Two(key=k2, left=pr, right=r)
            InsertResult::Split(key=pk, left=left_node, right=right_node)
          }
        }
      } else {
        match insert_inner(r, key) {
          InsertResult::Done(tree=new_right) =>
            InsertResult::Done(
              tree=Tree::Three(
                key1=k1,
                key2=k2,
                left=l,
                middle=m,
                right=new_right,
              ),
            )
          InsertResult::Split(key=pk, left=pl, right=pr) => {
            let left_node = Tree::Two(key=k1, left=l, right=m)
            let right_node = Tree::Two(key=pk, left=pl, right=pr)
            InsertResult::Split(key=k2, left=left_node, right=right_node)
          }
        }
      }
  }
}

///|
/// Create an empty 2-3 tree.
pub fn[T] empty() -> Tree[T] {
  Tree::Empty
}

///|
/// Insert key and return the new tree.
pub fn[T : Compare] insert(t : Tree[T], key : T) -> Tree[T] {
  match insert_inner(t, key) {
    InsertResult::Done(tree~) => tree
    InsertResult::Split(key=k, left=l, right=r) =>
      Tree::Two(key=k, left=l, right=r)
  }
}

///|
/// Check whether key exists in the tree.
#warnings("+missing_invariant+missing_reasoning")
pub fn[T : Compare] contains(t : Tree[T], key : T) -> Bool {
  let none : T? = None
  for cur = t, lo = none, hi = none {
    match cur {
      Tree::Empty => break false
      Tree::Two(key=k, left=l, right=r) =>
        if key == k {
          break true
        } else if key < k {
          continue l, lo, Some(k)
        } else {
          continue r, Some(k), hi
        }
      Tree::Three(key1=k1, key2=k2, left=l, middle=m, right=r) =>
        if key == k1 || key == k2 {
          break true
        } else if key < k1 {
          continue l, lo, Some(k1)
        } else if key < k2 {
          continue m, Some(k1), Some(k2)
        } else {
          continue r, Some(k2), hi
        }
    }
  } where {
    invariant: tree_valid(cur, lo, hi),
    invariant: within_bounds(key, lo, hi),
    reasoning: (
      #|INVARIANT (2-3 search bounds):
      #|cur is a valid subtree constrained by (lo, hi); key respects bounds.
      #|MAINTENANCE:
      #|Choose the correct child interval, tightening bounds accordingly.
      #|TERMINATION:
      #|Empty subtree means absent; matching key returns true.
    ),
  }
}

///|
/// Build a 2-3 tree by inserting elements in order.
#warnings("+missing_invariant+missing_reasoning")
pub fn[T : Compare] from_array(arr : ArrayView[T]) -> Tree[T] {
  let n = arr.length()
  for i = 0, tree = Tree::Empty {
    if i >= n {
      break tree
    } else {
      continue i + 1, insert(tree, arr[i])
    }
  } where {
    invariant: i >= 0 && i <= n,
    invariant: size(tree) == i,
    invariant: tree_valid(tree, None, None),
    reasoning: (
      #|INVARIANT (2-3 build):
      #|tree contains the first i keys and preserves 2-3 ordering.
      #|MAINTENANCE:
      #|Insert arr[i], preserving balance via splits.
      #|TERMINATION:
      #|At i = n, all keys are inserted.
    ),
  }
}
