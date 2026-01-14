// ============================================================================
// Challenge: Persistent Skew Heap
// Self-adjusting meldable heap with subtree swaps
// ============================================================================

///|
pub enum Heap[T] {
  Empty
  Node(value~ : T, left~ : Heap[T], right~ : Heap[T])
} derive(Show)

///|
fn[T] heap_size(h : Heap[T]) -> Int {
  match h {
    Heap::Empty => 0
    Heap::Node(value=_, left~, right~) => 1 + heap_size(left) + heap_size(right)
  }
}

///|
fn[T : Compare] heap_valid(h : Heap[T]) -> Bool {
  match h {
    Heap::Empty => true
    Heap::Node(value~, left~, right~) => {
      let left_ok = match left {
        Heap::Empty => true
        Heap::Node(value=v, left=_, right=_) => value <= v
      }
      let right_ok = match right {
        Heap::Empty => true
        Heap::Node(value=v, left=_, right=_) => value <= v
      }
      left_ok && right_ok && heap_valid(left) && heap_valid(right)
    }
  }
}

///|
/// Create an empty skew heap.
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
      Heap::Node(value=va, left=la, right=ra),
      Heap::Node(value=vb, left=lb, right=rb),
    ) =>
      if va <= vb {
        let merged = merge(ra, b)
        Heap::Node(value=va, left=merged, right=la)
      } else {
        let merged = merge(a, rb)
        Heap::Node(value=vb, left=merged, right=lb)
      }
  }
}

///|
fn[T] singleton(value : T) -> Heap[T] {
  Heap::Node(value~, left=Heap::Empty, right=Heap::Empty)
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
    Heap::Node(value~, left=_, right=_) => Some(value)
  }
}

///|
/// Delete the minimum element and return the new heap.
pub fn[T : Compare] delete_min(h : Heap[T]) -> Heap[T]? {
  match h {
    Heap::Empty => None
    Heap::Node(value=_, left~, right~) => Some(merge(left, right))
  }
}

///|
/// Build a skew heap by inserting elements in sequence.
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
      #|INVARIANT (Skew heap build):
      #|heap holds the first i elements and satisfies the min-heap order.
      #|MAINTENANCE:
      #|Melding in arr[i] preserves heap order and increases size by one.
      #|TERMINATION:
      #|At i = n, all elements are present in the heap.
    ),
  }
}
