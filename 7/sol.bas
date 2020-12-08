10 rem chipmunk basic
11 print "hello world"

' First! Read the file, line by line, and process it.
20 open "prob.in" for input as #1

21 rem line$ - current line, ids$ - array of all kinds of bags lookups$ - array of bag id -> names of contained bags
22 rem counts - array of bag id -> numbers of contained bags totals -> memoized count of bags inside each bag totalrows - number of lines/entries in ids$
23 rem the bag ids in ids$, lookups$, counts, and totals line up. the second index in lookups and counts line up (e.g. counts(n, p) is
24 rem the count of the bag lookups$(n, p) in the bag ids$(n))

25 dim line$, ids$(600), lookups$(600, 10)
26 dim counts(600, 10), totals(600)
29 totalrows = 0
30 while
35  input #1, line$ : rem read a line
36  if eof(1) then exit while
' extract the two adjectives as an id
40  id$ = field$(line$, 1) + field$(line$, 2) : rem extract the first two words
45  ids$(totalrows) = id$

46 rem Process each line -- extract the contained bags as two adjectives

47  dim fields
48  fields = len(field$(line$, -1)) : rem "If VAL is -1 then returns a string with a length equal to the number of seperators in the first string." (!!!!)
50 if fields > 6
' rem 6 == contains no bags
55  dim contained
56  contained = (fields - 3) / 4 : rem 7 fields = 1 contained, 11 fields = 2 contained, etc
57  totals(totalrows) = -1
60  for i=0 to contained-1
61    lookups$(totalrows, i) = field$(line$, i * 4 + 6) + field$(line$, i * 4 + 7)
62    counts(totalrows, i) = int(field$(line$, i * 4 + 5))
69  next
75 else
76  totals(totalrows) = 0
80 endif

99  totalrows = totalrows + 1
100 wend eof(1)


299 rem debug output
300 print ids$(9)
301 print lookups$(9,0)
302 print str$(counts(9,0))
303 print lookups$(9,1)
304 print counts(9,1)
305 print lookups$(9,2)
306 print counts(9,2)
330 print ids$(299)
331 print lookups$(299,0)
332 print str$(counts(299,0))
333 print lookups$(299,1)
334 print counts(299,1)

' do the full count
499 target$ = "shinygold"
500 print "count for " + target$ + " = " + str$(count(target$))

1000 exit

' returns the index of needle$ in array$, or -1 if not found
1500 sub idxof(array$, needle$, ret, ix)
1505 ret = -1 : ix = 0
1510 while
1511  rem print "check " + needle$ + " at " + str$(ix)
1525  if array$(ix) = needle$
1528   ret = ix
1530   exit while
1540  endif
1550  ix = ix + 1
1560 wend array$(ix) = ""
1605 idxof = ret
1610 end sub

' recursively counts the number of bags inside needle$.
2000 sub count(needle$, ret, idx, other$, lux)
2010  ret = -1
2100  idx = idxof(ids$, needle$)
2110  if ids$(idx) <> needle$ then
2111   print "fuck" ' sanity check
2112   exit
2113  endif
' check if it's memoized
2120  if totals(idx) >= 0 then
2130   ret = totals(idx)
2150  else
2160   ret = 0
2200   for lux=0 to 10
' for every bag in this bag, count it + all the bags it contains, the number of times it's inside this bag.
2210    if counts(idx, lux) = 0 then exit for
2220    other$ = lookups$(idx, lux)
2250    ret = ret + (counts(idx, lux) * (count(other$) + 1))
2280   next lux
2300  endif
' memoize
2350  totals(idx) = ret
2400  count = ret
2450 end sub
