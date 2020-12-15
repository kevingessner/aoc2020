#!/usr/bin/env ruby

# faster, the sol1 will take ages for 30,000,000 -- avoid scanning the array
def iterate(nums, total)
  lastidx = {} # most recent index of each seen number
  previdx = {} # next-most recent
  total.times do |n|
    if nums[n].nil?
      last = nums[n-1]
      if previdx[last].nil?
        # we've only seen the last number once
        nxt = 0
      else
        # we've only seen the last number at least twice, and we have the latest twoindexes
        nxt = lastidx[last] - previdx[last]
      end
      nums.push(nxt)
    else
      nxt = nums[n]
    end
    previdx[nxt] = lastidx[nxt]
    lastidx[nxt] = n
  end
  nums[-1]
end

puts iterate([0,3,6], 2020) # 436
puts iterate([1,3,2], 2020) # 1
puts iterate([2,1,3], 2020) # 10
puts iterate([2,3,1], 2020) # 78

puts iterate([7,14,0,17,11,1,2], 30000000) # 206
