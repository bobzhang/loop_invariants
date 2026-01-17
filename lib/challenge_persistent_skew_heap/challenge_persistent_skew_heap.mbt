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
pub fn[T : Compare] from_array(arr : ArrayView[T]) -> Heap[T] {
  arr.fold(init=Heap::Empty, (heap, value) => insert(heap, value))
}
