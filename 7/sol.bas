10 rem chipmunk basic
11 print "hello world"

' First! Read the file, line by line, and process it.
20 open "prob.in" for input as #1
' line$ - current line, ids$ - array of all kinds of bags, lookups$ - array of bag id -> names of contained bags, totalrows - number of lines/entries in ids$
25 dim line$, ids$(600), lookups$(600, 10), totalrows
26 n = 0
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
60  for i=0 to contained-1
61    lookups$(totalrows, i) = field$(line$, i * 4 + 6) + field$(line$, i * 4 + 7)
69  next
70 endif

99  totalrows = totalrows + 1
100 wend eof(1)


299 rem debug output
300 print ids$(0)
301 print lookups$(0,0)
302 print lookups$(0,1)
303 print lookups$(2,0)

' target$ is the string that we are looking for; target is its index in ids$
410 target$ = "shinygold"
415 target = 0
416 push target
420 target = idxof(ids$, target$)
421 print "foo " + str$(target) + "--" + ids$(target)

' will store what we find
480 dim allfound$(1000), numfound

' search! implemented with a stack. Take an item from the stack, and search all other bags to see which bags contain it.  Record then push those bags onto the stack.  Continue until the stack is empty.
500 while
507  target$ = ids$(target)
509   print "looking for " + target$
510   for idx=0 to totalrows
520    for lux=0 to 10
521     if lookups$(idx, lux) = target$ then
522      in$ = ids$(idx)
525      if idxof(allfound$, in$) = -1 then ' continue with bags we have not seen yet
527       target = idx
528       push target
530       print "found " + target$ + " in " + in$
536       allfound$(numfound) = in$
538       numfound = numfound + 1
540      endif
550     endif
570    next
580   next
589  pop
590 wend target = 0

700 for i=0 to numfound - 1
720  print "FOUND " + allfound$(i)
740 next i
750 print "found a total of " + str$(numfound)

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
