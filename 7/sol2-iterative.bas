10 rem chipmunk basic
11 print "hello world"

' First! Read the file, line by line, and process it.
20 open "prob.in" for input as #1
' line$ - current line, ids$ - array of all kinds of bags, lookups$ - array of bag id -> names of contained bags, totalrows - number of lines/entries in ids$
25 dim line$, ids$(600), lookups$(600, 10), counts(600, 10)
26 totalrows = 0
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
62    counts(totalrows, i) = int(field$(line$, i * 4 + 5))
69  next
70 endif

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

' target$ is the string that we are looking for; target is its index in ids$
410 target$ = "shinygold"
415 target = -1
416 push target
420 target = idxof(ids$, target$)
421 print "foo " + str$(target) + "--" + ids$(target)

' will store what we find
480 dim total

500 while
505   otarget = target
507   target$ = ids$(target)
509  rem print "looking for " + target$
520   for lux=0 to 10
521     if counts(otarget, lux) = 0 then exit for
522     in$ = lookups$(otarget, lux)
523     target = idxof(ids$, in$)
525     count = counts(otarget, lux)
526     total = total + count
527     print "found " + str$(count) + " " + in$ + " in " + target$ + str$(otarget) + " at " + str$(lux) + " (" + str$(total) + ")"
535     for c=1 to count
540      push target
550     next c
580   next
589   pop
590 wend target = -1

750 print "found a total of " + str$(total)

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
