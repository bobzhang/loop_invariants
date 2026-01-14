///|
/// Get the k-th smallest element (0-indexed).
pub fn[T] Treap::kth_element(self : Treap[T], k : Int) -> T? {
  kth_helper(self.root, k)
}

///|
/// Walk by subtree sizes to locate the k-th element.
fn[T] kth_helper(node : TreapNode[T]?, k : Int) -> T? {
  loop (node, k) {
    (None, _) => None
    (Some(n), k) => {
      let left_size = get_size(n.left)
      if k < left_size {
        continue (n.left, k)
      } else if k == left_size {
        Some(n.key)
      } else {
        continue (n.right, k - left_size - 1)
      }
    }
  }
}
