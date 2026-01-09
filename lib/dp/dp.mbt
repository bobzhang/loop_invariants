///|
/// Dynamic Programming Examples
///
/// This file demonstrates classic dynamic programming algorithms with
/// rigorous loop invariants that capture the correctness of the recurrences.
///
/// Key Insight: DP invariants express that dp[i] contains the optimal solution
/// for the subproblem of size i, allowing us to build larger solutions.

///|
/// 0/1 Knapsack Problem
///
/// MATHEMATICAL FOUNDATION:
/// Given n items with weights w[i] and values v[i], and capacity W,
/// find the maximum value achievable without exceeding capacity.
///
/// Recurrence: dp[i][w] = max(dp[i-1][w], dp[i-1][w-w[i]] + v[i]) if w >= w[i]
///
/// Space-optimized to O(W) by processing weights in reverse.
fn knapsack_01(
  weights : ArrayView[Int],
  values : ArrayView[Int],
  capacity : Int,
) -> Int {
  let n = weights.length()
  if n == 0 || capacity == 0 {
    return 0
  }

  // dp[w] = max value achievable with capacity w using items considered so far
  let dp = Array::make(capacity + 1, 0)
  for i = 0; i < n; i = i + 1 {
    let weight = weights[i]
    let value = values[i]

    // Process weights in reverse to avoid using same item twice
    for w = capacity; w >= weight; w = w - 1 {
      let without_item = dp[w]
      let with_item = dp[w - weight] + value
      dp[w] = if with_item > without_item { with_item } else { without_item }
    } where {
      invariant: w >= weight - 1 && w <= capacity,
      reasoning: (
        #|LOOP INVARIANT: dp[w..capacity] has been updated for item i
        #|
        #|Processing in reverse ensures dp[w - weight] still holds the value
        #|from considering items [0..i), not including item i.
        #|
        #|This prevents using the same item multiple times.
      ),
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|LOOP INVARIANT: dp[w] = max value achievable with capacity w using items [0..i)
      #|
      #|BASE CASE (i = 0): dp[w] = 0 for all w (no items considered)
      #|
      #|INDUCTIVE STEP (i → i + 1):
      #|  For each capacity w from high to low:
      #|    dp[w] = max(dp[w], dp[w - weight[i]] + value[i])
      #|  This correctly considers including or excluding item i.
      #|
      #|TERMINATION: dp[capacity] = optimal value using all n items.
    ),
  }
  dp[capacity]
}

///|
test "knapsack 01" {
  let weights = [1, 2, 3, 4]
  let values = [1, 4, 5, 7]
  assert_eq(knapsack_01(weights[:], values[:], 7), 12) // items 1,3 (4+7=11, wait let me recalc)
  // weights: 1,2,3,4  values: 1,4,5,7
  // capacity 7: take items with w=2,3 -> v=4+5=9, or w=3,4 -> 5+7=12, or w=1,2,4 -> 1+4+7=12
  // Actually w=1+2+4=7, v=1+4+7=12
}

///|
/// Unbounded Knapsack - Can use items multiple times
///
/// Recurrence: dp[w] = max(dp[w], dp[w-w[i]] + v[i]) for all i where w >= w[i]
fn knapsack_unbounded(
  weights : ArrayView[Int],
  values : ArrayView[Int],
  capacity : Int,
) -> Int {
  let n = weights.length()
  if n == 0 || capacity == 0 {
    return 0
  }
  let dp = Array::make(capacity + 1, 0)

  // Process weights in forward direction (allows reusing items)
  for w = 1; w <= capacity; w = w + 1 {
    for i = 0; i < n; i = i + 1 {
      if weights[i] <= w {
        let candidate = dp[w - weights[i]] + values[i]
        if candidate > dp[w] {
          dp[w] = candidate
        }
      }
    }
  } where {
    invariant: w >= 1 && w <= capacity + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[0..w) contains optimal values for capacities 0 to w-1
      #|
      #|For each capacity w, we try all items and take the best option.
      #|Since we process w in increasing order and dp[w - weight] is already
      #|computed, we can use the same item multiple times.
    ),
  }
  dp[capacity]
}

///|
test "knapsack unbounded" {
  let weights = [1, 3, 4]
  let values = [1, 4, 5]
  // Capacity 7: best is 2 items of weight 3 (value 8) + 1 item of weight 1 (value 1) = 9
  // Or: 1 item of weight 4 (5) + 1 item of weight 3 (4) = 9
  assert_eq(knapsack_unbounded(weights[:], values[:], 7), 9)
}

///|
/// Longest Increasing Subsequence (LIS) with Binary Search
///
/// MATHEMATICAL FOUNDATION:
/// tails[i] = smallest ending element of any increasing subsequence of length i+1
/// tails is always sorted, so we can use binary search.
///
/// Time: O(n log n), Space: O(n)
fn lis_binary_search(nums : ArrayView[Int]) -> Int {
  let n = nums.length()
  if n == 0 {
    return 0
  }

  // tails[i] = smallest tail of all increasing subsequences of length i+1
  let tails : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    let num = nums[i]
    // Binary search for the position to insert/replace
    let pos = lower_bound_lis(tails[:], num)
    if pos == tails.length() {
      tails.push(num)
    } else {
      tails[pos] = num
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|LOOP INVARIANT:
      #|  - tails[j] = smallest ending element of LIS of length j+1 in nums[0..i)
      #|  - tails is strictly increasing
      #|  - tails.length() = length of LIS in nums[0..i)
      #|
      #|BASE CASE (i = 0): tails is empty
      #|
      #|INDUCTIVE STEP:
      #|  Let pos = first index where tails[pos] >= nums[i]
      #|  - If pos == tails.length(): nums[i] extends the longest LIS
      #|  - Otherwise: nums[i] gives a smaller tail for length pos+1
      #|
      #|TERMINATION: tails.length() is the LIS length
    ),
  }
  tails.length()
}

///|
fn lower_bound_lis(arr : ArrayView[Int], target : Int) -> Int {
  for lo = 0, hi = arr.length(); lo < hi; {
    let mid = (lo + hi) / 2
    if arr[mid] < target {
      continue mid + 1, hi
    } else {
      continue lo, mid
    }
  } else {
    lo
  } where {
    invariant: lo >= 0 && hi >= 0 && lo <= hi + 1,
    reasoning: (
      #|Standard binary search for lower bound
    ),
  }
}

///|
test "LIS binary search" {
  let nums = [10, 9, 2, 5, 3, 7, 101, 18]
  assert_eq(lis_binary_search(nums[:]), 4) // [2, 3, 7, 101] or [2, 3, 7, 18]
  let nums2 = [0, 1, 0, 3, 2, 3]
  assert_eq(lis_binary_search(nums2[:]), 4) // [0, 1, 2, 3]
}

///|
/// Coin Change - Minimum coins to make amount
///
/// Recurrence: dp[a] = min(dp[a - coin] + 1) for all valid coins
fn coin_change_min(coins : ArrayView[Int], amount : Int) -> Int {
  if amount == 0 {
    return 0
  }
  let inf = amount + 1 // Represents impossible
  let dp = Array::make(amount + 1, inf)
  dp[0] = 0
  for a = 1; a <= amount; a = a + 1 {
    for i = 0; i < coins.length(); i = i + 1 {
      let coin = coins[i]
      if coin <= a && dp[a - coin] < inf {
        let candidate = dp[a - coin] + 1
        if candidate < dp[a] {
          dp[a] = candidate
        }
      }
    }
  } where {
    invariant: a >= 1 && a <= amount + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[0..a) contains minimum coins needed for amounts 0 to a-1
      #|
      #|For amount a, we try each coin and take the minimum.
      #|dp[a] = min(dp[a - coin] + 1) over all valid coins.
      #|
      #|If dp[a] remains inf, amount a is unreachable.
    ),
  }
  if dp[amount] > amount {
    -1
  } else {
    dp[amount]
  }
}

///|
test "coin change min" {
  let coins = [1, 2, 5]
  assert_eq(coin_change_min(coins[:], 11), 3) // 5 + 5 + 1
  let coins2 = [2]
  assert_eq(coin_change_min(coins2[:], 3), -1) // impossible
}

///|
/// Coin Change - Number of ways to make amount
fn coin_change_ways(coins : ArrayView[Int], amount : Int) -> Int {
  let dp = Array::make(amount + 1, 0)
  dp[0] = 1 // One way to make 0: use no coins

  // Process coins first to avoid counting permutations as different
  for i = 0; i < coins.length(); i = i + 1 {
    let coin = coins[i]
    for a = coin; a <= amount; a = a + 1 {
      dp[a] = dp[a] + dp[a - coin]
    } where {
      invariant: a >= coin && a <= amount + 1,
      reasoning: (
        #|INNER LOOP INVARIANT: dp[0..a) updated to include coin i
        #|Processing amounts in increasing order allows using coin multiple times.
      ),
    }
  } where {
    invariant: i >= 0 && i <= coins.length(),
    reasoning: (
      #|LOOP INVARIANT: dp[a] = number of ways to make amount a using coins[0..i]
      #|
      #|By processing coins one at a time (outer loop on coins),
      #|we count combinations, not permutations.
      #|
      #|Each coin is either used 0, 1, 2, ... times.
    ),
  }
  dp[amount]
}

///|
test "coin change ways" {
  let coins = [1, 2, 5]
  assert_eq(coin_change_ways(coins[:], 5), 4) // [5], [2,2,1], [2,1,1,1], [1,1,1,1,1]
}

///|
/// Longest Common Subsequence (LCS)
///
/// MATHEMATICAL FOUNDATION:
/// LCS(i, j) = length of LCS of s1[0..i) and s2[0..j)
/// Recurrence:
///   LCS(i, j) = LCS(i-1, j-1) + 1       if s1[i-1] == s2[j-1]
///   LCS(i, j) = max(LCS(i-1, j), LCS(i, j-1))  otherwise
fn longest_common_subsequence(s1 : String, s2 : String) -> Int {
  let chars1 = s1.to_array()
  let chars2 = s2.to_array()
  let m = chars1.length()
  let n = chars2.length()
  if m == 0 || n == 0 {
    return 0
  }

  // Space optimization: only need two rows
  let prev = Array::make(n + 1, 0)
  let curr = Array::make(n + 1, 0)
  for i = 1; i <= m; i = i + 1 {
    for j = 1; j <= n; j = j + 1 {
      if chars1[i - 1] == chars2[j - 1] {
        curr[j] = prev[j - 1] + 1
      } else {
        curr[j] = if prev[j] > curr[j - 1] { prev[j] } else { curr[j - 1] }
      }
    } where {
      invariant: j >= 1 && j <= n + 1,
      reasoning: (
        #|INNER LOOP INVARIANT: curr[0..j) contains LCS lengths for row i
      ),
    }
    // Swap rows
    for k = 0; k <= n; k = k + 1 {
      prev[k] = curr[k]
    }
  } where {
    invariant: i >= 1 && i <= m + 1,
    reasoning: (
      #|LOOP INVARIANT: prev[j] = LCS(i-1, j) for all j
      #|
      #|After processing row i:
      #|  curr[j] = LCS(i, j) = LCS of s1[0..i) and s2[0..j)
      #|
      #|This correctly implements the recurrence relation.
    ),
  }
  prev[n]
}

///|
test "longest common subsequence" {
  assert_eq(longest_common_subsequence("abcde", "ace"), 3) // "ace"
  assert_eq(longest_common_subsequence("abc", "abc"), 3)
  assert_eq(longest_common_subsequence("abc", "def"), 0)
}

///|
/// Maximum Subarray Sum (Kadane's Algorithm) - Already in examples.mbt
/// Here we show the full DP formulation.
///
/// dp[i] = maximum sum of subarray ending at index i
/// Recurrence: dp[i] = max(nums[i], dp[i-1] + nums[i])
fn max_subarray_dp(nums : ArrayView[Int]) -> Int {
  let n = nums.length()
  if n == 0 {
    return 0
  }
  for i = 1, max_ending_here = nums[0], max_so_far = nums[0]; i < n; i = i + 1 {
    // Either start fresh at nums[i] or extend previous subarray
    let extend = max_ending_here + nums[i]
    let new_max_ending = if nums[i] > extend { nums[i] } else { extend }
    let new_max_so_far = if new_max_ending > max_so_far {
      new_max_ending
    } else {
      max_so_far
    }
    continue i + 1, new_max_ending, new_max_so_far
  } else {
    max_so_far
  } where {
    invariant: i >= 1 && i <= n,
    reasoning: (
      #|LOOP INVARIANT:
      #|  - max_ending_here = max sum of subarray ending at index i-1
      #|  - max_so_far = max sum of any subarray in nums[0..i)
      #|
      #|The decision at each step is whether to extend or start fresh.
      #|This is exactly Kadane's algorithm.
    ),
  }
}

///|
test "max subarray dp" {
  let nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
  assert_eq(max_subarray_dp(nums[:]), 6) // [4, -1, 2, 1]
}

///|
/// House Robber - Maximum sum with no adjacent elements
///
/// Recurrence: dp[i] = max(dp[i-1], dp[i-2] + nums[i])
fn house_robber(nums : ArrayView[Int]) -> Int {
  let n = nums.length()
  if n == 0 {
    return 0
  }
  if n == 1 {
    return nums[0]
  }
  for i = 2, prev2 = nums[0], prev1 = (if nums[1] > nums[0] {
          nums[1]
        } else {
          nums[0]
        })
      i < n
      i = i + 1 {
    let rob_current = prev2 + nums[i]
    let skip_current = prev1
    let current = if rob_current > skip_current {
      rob_current
    } else {
      skip_current
    }
    continue i + 1, prev1, current
  } else {
    prev1
  } where {
    invariant: i >= 2 && i <= n,
    reasoning: (
      #|LOOP INVARIANT:
      #|  - prev2 = dp[i-2] = max sum robbing from houses [0..i-2]
      #|  - prev1 = dp[i-1] = max sum robbing from houses [0..i-1]
      #|
      #|At each house i:
      #|  - If we rob it: profit = prev2 + nums[i] (can't rob i-1)
      #|  - If we skip it: profit = prev1
      #|
      #|We take the maximum.
    ),
  }
}

///|
test "house robber" {
  let nums = [2, 7, 9, 3, 1]
  assert_eq(house_robber(nums[:]), 12) // 2 + 9 + 1
  let nums2 = [1, 2, 3, 1]
  assert_eq(house_robber(nums2[:]), 4) // 1 + 3
}

///|
/// Unique Paths - Count paths in grid from (0,0) to (m-1, n-1)
///
/// Recurrence: dp[i][j] = dp[i-1][j] + dp[i][j-1]
fn unique_paths(m : Int, n : Int) -> Int {
  if m == 0 || n == 0 {
    return 0
  }

  // Space optimization: only need one row
  let dp = Array::make(n, 1)
  for i = 1; i < m; i = i + 1 {
    for j = 1; j < n; j = j + 1 {
      dp[j] = dp[j] + dp[j - 1]
    } where {
      invariant: j >= 1 && j <= n,
      reasoning: (
        #|INNER LOOP: dp[j] = paths to (i, j)
        #|dp[j] was paths to (i-1, j), dp[j-1] is paths to (i, j-1)
      ),
    }
  } where {
    invariant: i >= 1 && i <= m,
    reasoning: (
      #|LOOP INVARIANT: After row i, dp[j] = number of paths to cell (i, j)
      #|
      #|First row is all 1s (only one path: all right moves)
      #|First column is all 1s (only one path: all down moves)
      #|Other cells: sum of paths from above and left
    ),
  }
  dp[n - 1]
}

///|
test "unique paths" {
  assert_eq(unique_paths(3, 7), 28)
  assert_eq(unique_paths(3, 2), 3)
}

///|
/// Minimum Path Sum in Grid
///
/// Recurrence: dp[i][j] = grid[i][j] + min(dp[i-1][j], dp[i][j-1])
fn min_path_sum(grid : Array[Array[Int]]) -> Int {
  let m = grid.length()
  if m == 0 {
    return 0
  }
  let n = grid[0].length()
  if n == 0 {
    return 0
  }

  // Space optimization
  let dp = Array::make(n, 0)
  dp[0] = grid[0][0]

  // Initialize first row
  for j = 1; j < n; j = j + 1 {
    dp[j] = dp[j - 1] + grid[0][j]
  }

  // Fill remaining rows
  for i = 1; i < m; i = i + 1 {
    dp[0] = dp[0] + grid[i][0]
    for j = 1; j < n; j = j + 1 {
      let from_above = dp[j]
      let from_left = dp[j - 1]
      dp[j] = grid[i][j] +
        (if from_above < from_left { from_above } else { from_left })
    } where {
      invariant: j >= 1 && j <= n,
      reasoning: (
        #|INNER LOOP: dp[j] = min path sum to (i, j)
      ),
    }
  } where {
    invariant: i >= 1 && i <= m,
    reasoning: (
      #|LOOP INVARIANT: dp[j] = minimum path sum to cell (i, j)
      #|
      #|Each cell's min path = its value + min(path from above, path from left)
    ),
  }
  dp[n - 1]
}

///|
test "min path sum" {
  let grid = [[1, 3, 1], [1, 5, 1], [4, 2, 1]]
  assert_eq(min_path_sum(grid), 7) // 1→3→1→1→1
}

///|
/// Word Break - Can string be segmented into dictionary words?
///
/// dp[i] = true if s[0..i) can be segmented
fn word_break(s : String, word_dict : Array[String]) -> Bool {
  let chars = s.to_array()
  let n = chars.length()

  // Convert word dict to char arrays for comparison
  let words : Array[Array[Char]] = []
  for i = 0; i < word_dict.length(); i = i + 1 {
    words.push(word_dict[i].to_array())
  }
  let dp = Array::make(n + 1, false)
  dp[0] = true // Empty string can be segmented
  for i = 1; i <= n; i = i + 1 {
    for w = 0; w < words.length(); w = w + 1 {
      let word = words[w]
      let word_len = word.length()
      if word_len <= i && dp[i - word_len] {
        // Check if s[i-word_len..i) matches word
        if matches_word(chars, i - word_len, word) {
          dp[i] = true
          break
        }
      }
    }
  } where {
    invariant: i >= 1 && i <= n + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[0..i) correctly indicates segmentability
      #|
      #|dp[i] = true iff s[0..i) can be segmented into dictionary words
      #|
      #|For each position i, we check all words in dictionary:
      #|  If dp[i - len(word)] is true and s[i-len(word)..i) == word,
      #|  then dp[i] = true
    ),
  }
  dp[n]
}

///|
fn matches_word(chars : Array[Char], start : Int, word : Array[Char]) -> Bool {
  let word_len = word.length()
  for i = 0; i < word_len; i = i + 1 {
    if chars[start + i] != word[i] {
      return false
    }
  } else {
    true
  } where {
    invariant: i >= 0 && i <= word_len,
    reasoning: (
      #|Compare characters one by one
    ),
  }
}

///|
test "word break" {
  let s = "leetcode"
  let dict = ["leet", "code"]
  assert_eq(word_break(s, dict), true)
  let s2 = "applepenapple"
  let dict2 = ["apple", "pen"]
  assert_eq(word_break(s2, dict2), true)
}

///|
/// Palindrome Partitioning - Minimum cuts for palindrome partitions
///
/// dp[i] = minimum cuts needed for s[0..i)
fn min_palindrome_cuts(s : String) -> Int {
  let chars = s.to_array()
  let n = chars.length()
  if n <= 1 {
    return 0
  }

  // is_palindrome[i][j] = true if s[i..j+1) is palindrome
  let is_palindrome : Array[Array[Bool]] = []
  for i = 0; i < n; i = i + 1 {
    is_palindrome.push(Array::make(n, false))
    is_palindrome[i][i] = true
  }

  // Fill palindrome table
  for length = 2; length <= n; length = length + 1 {
    for i = 0; i <= n - length; i = i + 1 {
      let j = i + length - 1
      if length == 2 {
        is_palindrome[i][j] = chars[i] == chars[j]
      } else {
        is_palindrome[i][j] = chars[i] == chars[j] &&
          is_palindrome[i + 1][j - 1]
      }
    }
  }

  // dp[i] = min cuts for s[0..i)
  let dp = Array::make(n + 1, 0)
  for i = 0; i <= n; i = i + 1 {
    dp[i] = i - 1 // Maximum cuts = i - 1
  }
  for i = 1; i <= n; i = i + 1 {
    if is_palindrome[0][i - 1] {
      dp[i] = 0 // Entire prefix is palindrome
    } else {
      for j = 1; j < i; j = j + 1 {
        if is_palindrome[j][i - 1] {
          let candidate = dp[j] + 1
          if candidate < dp[i] {
            dp[i] = candidate
          }
        }
      } where {
        invariant: j >= 1 && j <= i,
        reasoning: (
          #|Try all possible last palindrome partitions
        ),
      }
    }
  } where {
    invariant: i >= 1 && i <= n + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[0..i) contains minimum cuts for prefixes
      #|
      #|dp[i] = min over j < i where s[j..i) is palindrome of (dp[j] + 1)
      #|Or 0 if entire s[0..i) is palindrome
    ),
  }
  dp[n]
}

///|
test "min palindrome cuts" {
  assert_eq(min_palindrome_cuts("aab"), 1) // "aa" | "b"
  assert_eq(min_palindrome_cuts("a"), 0)
  assert_eq(min_palindrome_cuts("ab"), 1)
}

///|
/// Egg Drop Problem - Minimum attempts with k eggs and n floors
///
/// MATHEMATICAL FOUNDATION:
/// dp[k][n] = minimum attempts to find critical floor with k eggs and n floors
///
/// Recurrence: dp[k][n] = 1 + min over all x in [1,n] of max(dp[k-1][x-1], dp[k][n-x])
///
/// Optimized with binary search.
fn egg_drop(eggs : Int, floors : Int) -> Int {
  if floors == 0 || floors == 1 {
    return floors
  }
  if eggs == 1 {
    return floors // Must try floor by floor
  }

  // dp[k] = max floors we can check with k eggs and t trials
  // We find minimum t such that dp[eggs] >= floors
  let dp = Array::make(eggs + 1, 0)
  for trials = 1; dp[eggs] < floors; trials = trials + 1 {
    // Update dp in reverse to avoid using updated values
    for k = eggs; k >= 1; k = k - 1 {
      // With k eggs and t trials:
      // If egg breaks: we checked dp[k-1] floors below
      // If egg survives: we can check dp[k] floors above
      // Plus the current floor
      dp[k] = 1 + dp[k - 1] + dp[k]
    } where {
      invariant: k >= 0 && k <= eggs,
      reasoning: (
        #|dp[k] = max floors checkable with k eggs and current trials
        #|After update: dp[k] with t+1 trials = 1 + dp[k-1,t] + dp[k,t]
      ),
    }
  } else {
    trials - 1
  } where {
    invariant: trials >= 1,
    reasoning: (
      #|LOOP INVARIANT: dp[k] = max floors checkable with k eggs and trials-1 trials
      #|
      #|We increment trials until dp[eggs] >= floors.
      #|This finds the minimum trials needed.
      #|
      #|The recurrence dp[k] = 1 + dp[k-1] + dp[k] captures:
      #|  - 1 floor tested this trial
      #|  - dp[k-1] floors checkable below (if egg breaks)
      #|  - dp[k] floors checkable above (if egg survives)
    ),
  }
}

///|
test "egg drop" {
  assert_eq(egg_drop(1, 10), 10) // With 1 egg, need 10 trials worst case
  assert_eq(egg_drop(2, 10), 4) // With 2 eggs, 4 trials suffice
  assert_eq(egg_drop(2, 100), 14) // With 2 eggs, 14 trials for 100 floors
}

///|
/// Longest Palindromic Subsequence
///
/// dp[i][j] = length of longest palindromic subsequence in s[i..j+1)
fn longest_palindromic_subsequence(s : String) -> Int {
  let chars = s.to_array()
  let n = chars.length()
  if n == 0 {
    return 0
  }

  // Full 2D DP table
  let dp : Array[Array[Int]] = []
  for i = 0; i < n; i = i + 1 {
    dp.push(Array::make(n, 0))
    dp[i][i] = 1 // Single character is palindrome of length 1
  }

  // Fill for lengths 2 to n
  for length = 2; length <= n; length = length + 1 {
    for i = 0; i <= n - length; i = i + 1 {
      let j = i + length - 1
      if chars[i] == chars[j] {
        dp[i][j] = dp[i + 1][j - 1] + 2
      } else {
        dp[i][j] = if dp[i + 1][j] > dp[i][j - 1] {
          dp[i + 1][j]
        } else {
          dp[i][j - 1]
        }
      }
    } where {
      invariant: i >= 0 && i <= n - length + 1,
      reasoning: (
        #|INNER LOOP: dp[i][j] = LPS length for s[i..j+1)
      ),
    }
  } where {
    invariant: length >= 2 && length <= n + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[i][j] computed for all substrings of length < current
      #|
      #|If s[i] == s[j]: LPS(i,j) = LPS(i+1,j-1) + 2
      #|Otherwise: LPS(i,j) = max(LPS(i+1,j), LPS(i,j-1))
    ),
  }
  dp[0][n - 1]
}

///|
test "longest palindromic subsequence" {
  assert_eq(longest_palindromic_subsequence("bbbab"), 4) // "bbbb"
  assert_eq(longest_palindromic_subsequence("cbbd"), 2) // "bb"
}

///|
/// Matrix Chain Multiplication - Minimum scalar multiplications
///
/// Given dimensions p[0..n], matrix i has dimensions p[i-1] x p[i].
/// Find optimal parenthesization to minimize multiplications.
///
/// dp[i][j] = min cost to multiply matrices i through j
fn matrix_chain_mult(dimensions : ArrayView[Int]) -> Int {
  let n = dimensions.length() - 1 // Number of matrices
  if n <= 1 {
    return 0
  }

  // dp[i][j] = min cost to multiply matrices i..j (1-indexed)
  let dp : Array[Array[Int]] = []
  for i = 0; i <= n; i = i + 1 {
    dp.push(Array::make(n + 1, 0))
  }

  // Chain length from 2 to n
  for len = 2; len <= n; len = len + 1 {
    for i = 1; i <= n - len + 1; i = i + 1 {
      let j = i + len - 1
      dp[i][j] = 2147483647 // INT_MAX

      // Try all split points
      for k = i; k < j; k = k + 1 {
        let cost = dp[i][k] +
          dp[k + 1][j] +
          dimensions[i - 1] * dimensions[k] * dimensions[j]
        if cost < dp[i][j] {
          dp[i][j] = cost
        }
      } where {
        invariant: k >= i && k <= j,
        reasoning: (
          #|Try splitting (M_i * ... * M_k) * (M_{k+1} * ... * M_j)
        ),
      }
    } where {
      invariant: i >= 1 && i <= n - len + 2,
      reasoning: (
        #|INNER LOOP: compute dp[i][j] for all chains of current length
      ),
    }
  } where {
    invariant: len >= 2 && len <= n + 1,
    reasoning: (
      #|LOOP INVARIANT: dp[i][j] computed for all chains of length < len
      #|
      #|Recurrence: dp[i][j] = min over k in [i,j) of
      #|  dp[i][k] + dp[k+1][j] + p[i-1] * p[k] * p[j]
      #|
      #|This tries all ways to split the product into two subchains.
    ),
  }
  dp[1][n]
}

///|
test "matrix chain multiplication" {
  // Matrices: 10x30, 30x5, 5x60
  let dims = [10, 30, 5, 60]
  // Option 1: (AB)C = 10*30*5 + 10*5*60 = 1500 + 3000 = 4500
  // Option 2: A(BC) = 30*5*60 + 10*30*60 = 9000 + 18000 = 27000
  assert_eq(matrix_chain_mult(dims[:]), 4500)
}
