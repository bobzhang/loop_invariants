// ============================================================================
// Challenge: Persistent Hash Map (Int -> Int)
// Buckets as immutable lists with path-copying updates
// ============================================================================

///|
enum Bucket {
  Nil
  Cons(key~ : Int, value~ : Int, tail~ : Bucket)
} derive(Show)

///|
pub struct HashMap {
  buckets : Array[Bucket]
  size : Int
} derive(Show)

///|
fn bucket_size(b : Bucket) -> Int {
  match b {
    Bucket::Nil => 0
    Bucket::Cons(key=_, value=_, tail~) => 1 + bucket_size(tail)
  }
}

///|
fn bucket_no_key(b : Bucket, key : Int) -> Bool {
  match b {
    Bucket::Nil => true
    Bucket::Cons(key=k, value=_, tail=t) => key != k && bucket_no_key(t, key)
  }
}

///|
fn reverse_append(rev : Bucket, tail : Bucket) -> Bucket {
  match rev {
    Bucket::Nil => tail
    Bucket::Cons(key=k, value=v, tail=t) =>
      reverse_append(t, Bucket::Cons(key=k, value=v, tail~))
  }
}

///|
pub fn make(capacity : Int) -> HashMap {
  let cap = if capacity <= 0 { 1 } else { capacity }
  { buckets: Array::make(cap, Bucket::Nil), size: 0 }
}

///|
fn index_for(key : Int, cap : Int) -> Int {
  let m = key % cap
  if m < 0 {
    m + cap
  } else {
    m
  }
}

///|
#warnings("+missing_invariant+missing_reasoning")
fn bucket_get(bucket : Bucket, key : Int) -> Int? {
  for cur = bucket, scanned = 0 {
    match cur {
      Bucket::Nil => break None
      Bucket::Cons(key=k, value=v, tail=t) =>
        if k == key {
          break Some(v)
        } else {
          continue t, scanned + 1
        }
    }
  } where {
    invariant: scanned >= 0 && scanned + bucket_size(cur) == bucket_size(bucket),
    reasoning: (
      #|INVARIANT (Bucket scan):
      #|cur is the unscanned suffix; any match must appear in cur.
      #|MAINTENANCE:
      #|Advance to tail when key does not match.
      #|TERMINATION:
      #|At Nil, the key is absent; otherwise return its value.
    ),
  }
}

///|
#warnings("+missing_invariant+missing_reasoning")
fn bucket_insert(bucket : Bucket, key : Int, value : Int) -> (Bucket, Bool) {
  for cur = bucket, rev = Bucket::Nil {
    match cur {
      Bucket::Nil => {
        let updated = Bucket::Cons(key~, value~, tail=Bucket::Nil)
        break (reverse_append(rev, updated), true)
      }
      Bucket::Cons(key=k, value=v, tail=t) =>
        if k == key {
          let updated = Bucket::Cons(key~, value~, tail=t)
          break (reverse_append(rev, updated), false)
        } else {
          continue t, Bucket::Cons(key=k, value=v, tail=rev)
        }
    }
  } where {
    invariant: bucket_size(rev) + bucket_size(cur) == bucket_size(bucket),
    invariant: bucket_no_key(rev, key),
    reasoning: (
      #|INVARIANT (Bucket rebuild):
      #|rev is the reversed prefix with no matching key; cur is the remainder.
      #|MAINTENANCE:
      #|Move one node to rev when the key does not match.
      #|TERMINATION:
      #|Reconstruct the bucket with an inserted or updated node.
    ),
  }
}

///|
pub fn size(map : HashMap) -> Int {
  map.size
}

///|
pub fn capacity(map : HashMap) -> Int {
  map.buckets.length()
}

///|
pub fn get(map : HashMap, key : Int) -> Int? {
  let idx = index_for(key, map.buckets.length())
  bucket_get(map.buckets[idx], key)
}

///|
pub fn put(map : HashMap, key : Int, value : Int) -> HashMap {
  let idx = index_for(key, map.buckets.length())
  let bucket = map.buckets[idx]
  let (new_bucket, added) = bucket_insert(bucket, key, value)
  let new_buckets = map.buckets.copy()
  new_buckets[idx] = new_bucket
  let new_size = if added { map.size + 1 } else { map.size }
  { buckets: new_buckets, size: new_size }
}

///|
test "persistent_hash_map" {
  let map0 = make(4)
  let map1 = put(map0, 1, 10)
  let map2 = put(map1, 5, 50)
  let map3 = put(map2, 1, 11)
  assert_eq(get(map3, 1), Some(11))
  assert_eq(get(map3, 5), Some(50))
  assert_eq(get(map1, 1), Some(10))
  assert_eq(get(map1, 5), None)
}
