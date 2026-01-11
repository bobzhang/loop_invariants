// ============================================================================
// MONOTONIC STACK - Next Greater/Smaller Element Problems
// ============================================================================
//
// A monotonic stack maintains elements in sorted order (increasing or decreasing).
// Used for efficiently finding next greater/smaller elements, histogram areas, etc.
//
// KEY INSIGHT: When we encounter an element that breaks monotonicity, we pop
// elements and process them with the current element as their "answer."
//
// APPLICATIONS:
// 1. Next Greater Element (NGE)
// 2. Previous Greater Element (PGE)
// 3. Largest Rectangle in Histogram
// 4. Trapping Rain Water
// 5. Stock Span Problem
//
// INVARIANTS:
// 1. Stack maintains monotonic property after each operation
// 2. Each element is pushed and popped at most once → O(n) total
// 3. When element is popped, the popping element is its answer
//
// TIME COMPLEXITY: O(n) for all problems
// SPACE COMPLEXITY: O(n) for stack

///|
/// Find next greater element for each position
/// Returns -1 if no greater element exists to the right
fn next_greater_element(arr : Array[Int64]) -> Array[Int] {
  let n = arr.length()
  let result = Array::make(n, -1)
  let stack : Array[Int] = [] // Stack of indices
  for i = 0; i < n; i = i + 1 {
    // Pop elements smaller than current
    while stack.length() > 0 && arr[stack[stack.length() - 1]] < arr[i] {
      let top = stack[stack.length() - 1]
      let _ = stack.pop()
      result[top] = i
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack, result=-1 for all. M: For each element, pop smaller elements (they found their NGE at current position i). Push current index. Stack remains decreasing. T: Elements remaining in stack have no NGE (result stays -1).",
  }
  result
}

///|
/// Find next smaller element for each position
fn next_smaller_element(arr : Array[Int64]) -> Array[Int] {
  let n = arr.length()
  let result = Array::make(n, -1)
  let stack : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    while stack.length() > 0 && arr[stack[stack.length() - 1]] > arr[i] {
      let top = stack[stack.length() - 1]
      let _ = stack.pop()
      result[top] = i
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack. M: Pop larger elements (current is their NSE). Push current. Stack remains increasing. T: Remaining elements have no NSE.",
  }
  result
}

///|
/// Find previous greater element for each position
fn previous_greater_element(arr : Array[Int64]) -> Array[Int] {
  let n = arr.length()
  let result = Array::make(n, -1)
  let stack : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    // Pop elements smaller than or equal to current
    while stack.length() > 0 && arr[stack[stack.length() - 1]] <= arr[i] {
      let _ = stack.pop()

    }
    // Top of stack (if exists) is previous greater
    if stack.length() > 0 {
      result[i] = stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack. M: Pop elements <= current (can't be PGE for future elements). Top of stack is PGE for current. Push current. T: All PGE values computed.",
  }
  result
}

///|
/// Find previous smaller element for each position
fn previous_smaller_element(arr : Array[Int64]) -> Array[Int] {
  let n = arr.length()
  let result = Array::make(n, -1)
  let stack : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    while stack.length() > 0 && arr[stack[stack.length() - 1]] >= arr[i] {
      let _ = stack.pop()

    }
    if stack.length() > 0 {
      result[i] = stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack. M: Pop elements >= current. Top is PSE. Push current. T: All PSE values computed.",
  }
  result
}

// ============================================================================
// LARGEST RECTANGLE IN HISTOGRAM
// ============================================================================

///|
/// Find largest rectangle area in histogram
/// heights[i] = height of bar at position i
fn largest_rectangle_in_histogram(heights : Array[Int64]) -> Int64 {
  let n = heights.length()
  if n == 0 {
    return 0L
  }

  // Find previous and next smaller elements
  let prev_smaller = Array::make(n, -1)
  let next_smaller = Array::make(n, n) // Default to n (past the end)

  // Compute previous smaller
  let stack : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    while stack.length() > 0 && heights[stack[stack.length() - 1]] >= heights[i] {
      let _ = stack.pop()

    }
    if stack.length() > 0 {
      prev_smaller[i] = stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Stack stores indices of a strictly increasing height sequence for [0,i). M: Pop while height >= current so top is nearest smaller to the left; record prev_smaller[i], then push i to maintain monotonicity. T: After i = n, prev_smaller is computed for all bars.",
  }

  // Compute next smaller
  stack.clear()
  for i = n - 1; i >= 0; i = i - 1 {
    while stack.length() > 0 && heights[stack[stack.length() - 1]] >= heights[i] {
      let _ = stack.pop()

    }
    if stack.length() > 0 {
      next_smaller[i] = stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= -1 && i <= n - 1,
    reasoning: "I: Stack stores indices of a strictly increasing height sequence to the right of i. M: Pop while height >= current so top is nearest smaller to the right; record next_smaller[i] (or keep n), then push i. T: After i = -1, next_smaller is computed for all bars.",
  }

  // Calculate max area
  let mut max_area = 0L
  for i = 0; i < n; i = i + 1 {
    let width = (next_smaller[i] - prev_smaller[i] - 1).to_int64()
    let area = heights[i] * width
    if area > max_area {
      max_area = area
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: max_area=0. M: For bar i, it extends from prev_smaller[i]+1 to next_smaller[i]-1. Area = height[i] * width. Track maximum. T: All bars considered, max_area is answer.",
  }
  max_area
}

// ============================================================================
// TRAPPING RAIN WATER
// ============================================================================

///|
/// Calculate total water trapped between bars
fn trap_rain_water(heights : Array[Int64]) -> Int64 {
  let n = heights.length()
  if n <= 2 {
    return 0L
  }

  // Method 1: Using monotonic stack
  let stack : Array[Int] = []
  let mut water = 0L
  for i = 0; i < n; i = i + 1 {
    while stack.length() > 0 && heights[stack[stack.length() - 1]] < heights[i] {
      let mid = stack[stack.length() - 1]
      let _ = stack.pop()
      if stack.length() == 0 {
        break
      }
      let left = stack[stack.length() - 1]
      let width = (i - left - 1).to_int64()
      let bounded_height = (if heights[left] < heights[i] {
          heights[left]
        } else {
          heights[i]
        }) -
        heights[mid]
      water = water + width * bounded_height
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack, water=0. M: When we find a taller bar, we can trap water above shorter bars in between. Pop until stack empty or taller bar found. Water trapped = width * min(left, right) - height. T: All water pockets computed.",
  }
  water
}

// ============================================================================
// STOCK SPAN PROBLEM
// ============================================================================

///|
/// Calculate span for each day
/// Span = number of consecutive days before (including current) with price <= current price
fn stock_span(prices : Array[Int64]) -> Array[Int] {
  let n = prices.length()
  let span = Array::make(n, 0)
  let stack : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    // Pop days with price <= current
    while stack.length() > 0 && prices[stack[stack.length() - 1]] <= prices[i] {
      let _ = stack.pop()

    }
    // Span is distance to previous greater element (or i+1 if none)
    span[i] = if stack.length() == 0 {
      i + 1
    } else {
      i - stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Empty stack. M: Pop smaller/equal prices. If stack empty, span includes all days so far (i+1). Otherwise, span is distance to previous greater. T: All spans computed.",
  }
  span
}

// ============================================================================
// SUM OF SUBARRAY MINIMUMS
// ============================================================================

///|
/// Sum of minimum values of all contiguous subarrays
fn sum_subarray_mins(arr : Array[Int64]) -> Int64 {
  let n = arr.length()
  if n == 0 {
    return 0L
  }
  let mod_val = 1000000007L

  // For each element, count subarrays where it's the minimum
  // left[i] = distance to previous smaller element
  // right[i] = distance to next smaller or equal element
  let left = Array::make(n, 0)
  let right = Array::make(n, 0)
  let stack : Array[Int] = []

  // Previous smaller (strictly less)
  for i = 0; i < n; i = i + 1 {
    while stack.length() > 0 && arr[stack[stack.length() - 1]] >= arr[i] {
      let _ = stack.pop()

    }
    left[i] = if stack.length() == 0 {
      i + 1
    } else {
      i - stack[stack.length() - 1]
    }
    stack.push(i)
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Stack is increasing in value for indices in [0,i). M: Pop until a strictly smaller element remains; left[i] is distance to previous smaller (or i+1 if none). Push i to maintain monotonicity. T: left distances are computed for all positions.",
  }

  // Next smaller or equal (to handle duplicates correctly)
  stack.clear()
  for i = n - 1; i >= 0; i = i - 1 {
    while stack.length() > 0 && arr[stack[stack.length() - 1]] > arr[i] {
      let _ = stack.pop()

    }
    right[i] = if stack.length() == 0 {
      n - i
    } else {
      stack[stack.length() - 1] - i
    }
    stack.push(i)
  } where {
    invariant: i >= -1 && i <= n - 1,
    reasoning: "I: Stack is non-decreasing in value for indices to the right. M: Pop while value > current so top is next smaller-or-equal; right[i] is distance to that index (or to n). Push i. T: right distances are computed for all positions.",
  }

  // Sum contributions
  let mut result = 0L
  for i = 0; i < n; i = i + 1 {
    let contribution = arr[i] *
      left[i].to_int64() %
      mod_val *
      right[i].to_int64() %
      mod_val
    result = (result + contribution) % mod_val
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: result=0. M: Element arr[i] is minimum for left[i] * right[i] subarrays. Add arr[i] * count to result. T: All element contributions summed.",
  }
  result
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "next greater element" {
  let arr : Array[Int64] = [4L, 5L, 2L, 10L, 8L]
  let nge = next_greater_element(arr)
  // NGE: 5(idx 1), 10(idx 3), 10(idx 3), none(-1), none(-1)
  inspect(nge[0], content="1")
  inspect(nge[1], content="3")
  inspect(nge[2], content="3")
  inspect(nge[3], content="-1")
  inspect(nge[4], content="-1")
}

///|
test "next smaller element" {
  let arr : Array[Int64] = [4L, 5L, 2L, 10L, 8L]
  let nse = next_smaller_element(arr)
  // NSE: 2(idx 2), 2(idx 2), none(-1), 8(idx 4), none(-1)
  inspect(nse[0], content="2")
  inspect(nse[1], content="2")
  inspect(nse[2], content="-1")
  inspect(nse[3], content="4")
  inspect(nse[4], content="-1")
}

///|
test "previous greater element" {
  let arr : Array[Int64] = [4L, 5L, 2L, 10L, 8L]
  let pge = previous_greater_element(arr)
  // PGE: none(-1), none(-1), 5(idx 1), none(-1), 10(idx 3)
  inspect(pge[0], content="-1")
  inspect(pge[1], content="-1")
  inspect(pge[2], content="1")
  inspect(pge[3], content="-1")
  inspect(pge[4], content="3")
}

///|
test "previous smaller element" {
  let arr : Array[Int64] = [4L, 5L, 2L, 10L, 8L]
  let pse = previous_smaller_element(arr)
  // PSE: none(-1), 4(idx 0), none(-1), 2(idx 2), 2(idx 2)
  inspect(pse[0], content="-1")
  inspect(pse[1], content="0")
  inspect(pse[2], content="-1")
  inspect(pse[3], content="2")
  inspect(pse[4], content="2")
}

///|
test "largest rectangle in histogram" {
  let heights : Array[Int64] = [2L, 1L, 5L, 6L, 2L, 3L]
  // Largest rectangle: height 5, width 2 (indices 2-3) = 10
  inspect(largest_rectangle_in_histogram(heights), content="10")
}

///|
test "largest rectangle uniform" {
  let heights : Array[Int64] = [3L, 3L, 3L, 3L]
  inspect(largest_rectangle_in_histogram(heights), content="12")
}

///|
test "trap rain water" {
  let heights : Array[Int64] = [0L, 1L, 0L, 2L, 1L, 0L, 1L, 3L, 2L, 1L, 2L, 1L]
  // Classic example: traps 6 units of water
  inspect(trap_rain_water(heights), content="6")
}

///|
test "trap rain water simple" {
  let heights : Array[Int64] = [3L, 0L, 2L]
  // Traps 2 units at index 1
  inspect(trap_rain_water(heights), content="2")
}

///|
test "stock span" {
  let prices : Array[Int64] = [100L, 80L, 60L, 70L, 60L, 75L, 85L]
  let span = stock_span(prices)
  // Spans: 1, 1, 1, 2, 1, 4, 6
  inspect(span[0], content="1")
  inspect(span[1], content="1")
  inspect(span[2], content="1")
  inspect(span[3], content="2")
  inspect(span[4], content="1")
  inspect(span[5], content="4")
  inspect(span[6], content="6")
}

///|
test "sum subarray mins" {
  let arr : Array[Int64] = [3L, 1L, 2L, 4L]
  // Subarrays: [3]=3, [1]=1, [2]=2, [4]=4,
  //            [3,1]=1, [1,2]=1, [2,4]=2,
  //            [3,1,2]=1, [1,2,4]=1,
  //            [3,1,2,4]=1
  // Sum = 3+1+2+4+1+1+2+1+1+1 = 17
  inspect(sum_subarray_mins(arr), content="17")
}

///|
test "monotonic stack empty" {
  let arr : Array[Int64] = []
  inspect(next_greater_element(arr).length(), content="0")
  inspect(largest_rectangle_in_histogram(arr), content="0")
}

///|
test "monotonic stack single" {
  let arr : Array[Int64] = [5L]
  let nge = next_greater_element(arr)
  inspect(nge[0], content="-1")
  inspect(largest_rectangle_in_histogram(arr), content="5")
}
