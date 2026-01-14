// ============================================================================
// Challenge: Persistent Leftist Heap
// Meldable priority queue with rank (null-path length)
// ============================================================================

///|
pub enum Heap[T] {
  Empty
  Node(value~ : T, rank~ : Int, left~ : Heap[T], right~ : Heap[T])
} derive(Show)

///|
fn[T] rank(h : Heap[T]) -> Int {
  match h {
    Heap::Empty => 0
    Heap::Node(value=_, rank~, left=_, right=_) => rank
  }
}

///|
fn[T] heap_size(h : Heap[T]) -> Int {
  match h {
    Heap::Empty => 0
    Heap::Node(value=_, rank=_, left~, right~) =>
      1 + heap_size(left) + heap_size(right)
  }
}

///|
fn[T : Compare] heap_valid(h : Heap[T]) -> Bool {
  match h {
    Heap::Empty => true
    Heap::Node(value~, rank=node_rank, left~, right~) => {
      let left_rank = rank(left)
      let right_rank = rank(right)
      let left_ok = match left {
        Heap::Empty => true
        Heap::Node(value=v, rank=_, left=_, right=_) => value <= v
      }
      let right_ok = match right {
        Heap::Empty => true
        Heap::Node(value=v, rank=_, left=_, right=_) => value <= v
      }
      let order_ok = left_ok && right_ok
      let rank_ok = left_rank >= right_rank && node_rank == right_rank + 1
      order_ok && rank_ok && heap_valid(left) && heap_valid(right)
    }
  }
}

///|
fn[T] make_node(value : T, left : Heap[T], right : Heap[T]) -> Heap[T] {
  let left_rank = rank(left)
  let right_rank = rank(right)
  if left_rank < right_rank {
    Heap::Node(value~, rank=left_rank + 1, left=right, right=left)
  } else {
    Heap::Node(value~, rank=right_rank + 1, left~, right~)
  }
}

///|
/// Create an empty leftist heap.
pub fn[T] empty() -> Heap[T] {
  Heap::Empty
}

///|
/// Return number of elements in the heap.
pub fn[T] size(h : Heap[T]) -> Int {
  heap_size(h)
}

///|
/// Merge two heaps and return the result.
pub fn[T : Compare] merge(a : Heap[T], b : Heap[T]) -> Heap[T] {
  match (a, b) {
    (Heap::Empty, _) => b
    (_, Heap::Empty) => a
    (
      Heap::Node(value=va, rank=_, left=la, right=ra),
      Heap::Node(value=vb, rank=_, left=lb, right=rb),
    ) =>
      if va <= vb {
        let merged = merge(ra, b)
        make_node(va, la, merged)
      } else {
        let merged = merge(a, rb)
        make_node(vb, lb, merged)
      }
  }
}

///|
fn[T] singleton(value : T) -> Heap[T] {
  Heap::Node(value~, rank=1, left=Heap::Empty, right=Heap::Empty)
}

///|
/// Insert a value and return the new heap.
pub fn[T : Compare] insert(h : Heap[T], value : T) -> Heap[T] {
  merge(h, singleton(value))
}

///|
/// Return the minimum value, or None if empty.
pub fn[T] find_min(h : Heap[T]) -> T? {
  match h {
    Heap::Empty => None
    Heap::Node(value~, rank=_, left=_, right=_) => Some(value)
  }
}

///|
/// Delete the minimum element and return the new heap.
pub fn[T : Compare] delete_min(h : Heap[T]) -> Heap[T]? {
  match h {
    Heap::Empty => None
    Heap::Node(value=_, rank=_, left~, right~) => Some(merge(left, right))
  }
}

///|
/// Build a heap by inserting elements in sequence.
#warnings("+missing_invariant+missing_reasoning")
pub fn[T : Compare] from_array(arr : ArrayView[T]) -> Heap[T] {
  let n = arr.length()
  for i = 0, heap = Heap::Empty {
    if i >= n {
      break heap
    } else {
      continue i + 1, insert(heap, arr[i])
    }
  } where {
    invariant: i >= 0 && i <= n,
    invariant: heap_size(heap) == i,
    invariant: heap_valid(heap),
    reasoning: (
      #|INVARIANT (Incremental heap build):
      #|heap contains exactly the first i elements and maintains leftist order.
      #|MAINTENANCE:
      #|Insert arr[i], preserving heap validity and increasing size by one.
      #|TERMINATION:
      #|At i = n, heap contains all array elements.
    ),
  }
}

///|
test "persistent_leftist_heap" {
  let h0 : Heap[Int] = Heap::Empty
  let h1 = insert(h0, 5)
  let h2 = insert(h1, 3)
  let h3 = insert(h2, 7)
  assert_eq(find_min(h3), Some(3))
  guard delete_min(h3) is Some(h4) else { fail("expected delete_min") }
  assert_eq(find_min(h4), Some(5))
  let built = from_array([5, 3, 7, 1][:])
  assert_eq(find_min(built), Some(1))
}
