// ============================================================================
// Challenge: Persistent Treap (Set)
// Random-priority BST with immutable insertions
// ============================================================================

///|
pub enum Treap[T] {
  Empty
  Node(
    key~ : T,
    priority~ : Int,
    size~ : Int,
    left~ : Treap[T],
    right~ : Treap[T]
  )
} derive(Show)

///|
/// Return the number of keys in the treap.
pub fn[T] size(t : Treap[T]) -> Int {
  match t {
    Treap::Empty => 0
    Treap::Node(key=_, priority=_, size~, left=_, right=_) => size
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
fn[T : Compare] treap_valid(t : Treap[T], lo : T?, hi : T?) -> Bool {
  match t {
    Treap::Empty => true
    Treap::Node(key~, priority~, size=sz, left~, right~) => {
      let bounds_ok = within_bounds(key, lo, hi)
      let left_ok = match left {
        Treap::Empty => true
        Treap::Node(key=_, priority=p, size=_, left=_, right=_) => priority >= p
      }
      let right_ok = match right {
        Treap::Empty => true
        Treap::Node(key=_, priority=p, size=_, left=_, right=_) => priority >= p
      }
      let size_ok = sz == 1 + size(left) + size(right)
      bounds_ok &&
      left_ok &&
      right_ok &&
      size_ok &&
      treap_valid(left, lo, Some(key)) &&
      treap_valid(right, Some(key), hi)
    }
  }
}

///|
fn[T : Hash] priority_for(key : T) -> Int {
  key.hash()
}

///|
fn[T] make_node(
  key : T,
  priority : Int,
  left : Treap[T],
  right : Treap[T],
) -> Treap[T] {
  let sz = 1 + size(left) + size(right)
  Treap::Node(key~, priority~, size=sz, left~, right~)
}

///|
/// Create an empty treap.
pub fn[T] empty() -> Treap[T] {
  Treap::Empty
}

///|
/// Split the treap into (< key) and (>= key).
pub fn[T : Compare] split(t : Treap[T], key : T) -> (Treap[T], Treap[T]) {
  match t {
    Treap::Empty => (Treap::Empty, Treap::Empty)
    Treap::Node(key=k, priority=p, size=_, left=l, right=r) =>
      if key <= k {
        let (l1, l2) = split(l, key)
        (l1, make_node(k, p, l2, r))
      } else {
        let (r1, r2) = split(r, key)
        (make_node(k, p, l, r1), r2)
      }
  }
}

///|
/// Merge two treaps assuming all keys in a are < keys in b.
pub fn[T] merge(a : Treap[T], b : Treap[T]) -> Treap[T] {
  match (a, b) {
    (Treap::Empty, _) => b
    (_, Treap::Empty) => a
    (
      Treap::Node(key=ka, priority=pa, size=_, left=la, right=ra),
      Treap::Node(key=kb, priority=pb, size=_, left=lb, right=rb),
    ) =>
      if pa >= pb {
        make_node(ka, pa, la, merge(ra, b))
      } else {
        make_node(kb, pb, merge(a, lb), rb)
      }
  }
}

///|
/// Check whether key exists in the treap.
pub fn[T : Compare] contains(t : Treap[T], key : T) -> Bool {
  match t {
    Treap::Empty => false
    Treap::Node(key=k, priority=_, size=_, left=l, right=r) =>
      if key == k {
        true
      } else if key < k {
        contains(l, key)
      } else {
        contains(r, key)
      }
  }
}

///|
/// Insert key and return the new treap (no duplicates).
pub fn[T : Compare + Hash] insert(t : Treap[T], key : T) -> Treap[T] {
  if contains(t, key) {
    t
  } else {
    let (l, r) = split(t, key)
    let node = make_node(key, priority_for(key), Treap::Empty, Treap::Empty)
    merge(merge(l, node), r)
  }
}

///|
/// Build a treap by inserting elements in order.
#warnings("+missing_invariant+missing_reasoning")
pub fn[T : Compare + Hash] from_array(arr : ArrayView[T]) -> Treap[T] {
  let n = arr.length()
  for i = 0, tree = Treap::Empty {
    if i >= n {
      break tree
    } else {
      continue i + 1, insert(tree, arr[i])
    }
  } where {
    invariant: i >= 0 && i <= n,
    invariant: size(tree) == i,
    invariant: treap_valid(tree, None, None),
    reasoning: (
      #|INVARIANT (Treap build):
      #|tree contains the first i keys, satisfying BST order and heap priority.
      #|MAINTENANCE:
      #|Insert arr[i], preserving treap invariants and increasing size by one.
      #|TERMINATION:
      #|At i = n, all keys are inserted.
    ),
  }
}
