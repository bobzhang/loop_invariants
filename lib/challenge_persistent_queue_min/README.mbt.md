# Persistent Min-Queue

Queue with O(1) min queries using two min-stacks.

## Example

```mbt check
///|
test "persistent min queue" {
  let q0 = @challenge_persistent_queue_min.empty()
  let q1 = @challenge_persistent_queue_min.enqueue(q0, 5)
  let q2 = @challenge_persistent_queue_min.enqueue(q1, 2)
  let q3 = @challenge_persistent_queue_min.enqueue(q2, 7)
  inspect(@challenge_persistent_queue_min.peek(q3), content="Some(5)")
  inspect(@challenge_persistent_queue_min.min_queue(q3), content="Some(2)")
  guard @challenge_persistent_queue_min.dequeue(q3) is Some((5, q4)) else {
    fail("expected dequeue")
  }
  inspect(@challenge_persistent_queue_min.min_queue(q4), content="Some(2)")
  inspect(@challenge_persistent_queue_min.size(q4), content="2")
}
```
