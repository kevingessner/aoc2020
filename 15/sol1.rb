#!/usr/bin/env ruby

def iterate(nums, total)
  total.times do |n|
    if nums[n].nil?
      last = nums[n-1]
      seen = nums.count(last)
      if seen == 1
        nums.push 0
      else
        idx = nums.rindex(last)
        pidx = nums.slice(0, idx).rindex(last)
        nums.push(idx - pidx)
      end
    else
      nums[n]
    end
  end
  nums[-1]
end

puts iterate([0,3,6], 2020)
puts iterate([1,3,2], 2020)
puts iterate([2,1,3], 2020)
puts iterate([2,3,1], 2020)

puts iterate([7,14,0,17,11,1,2], 2020)
