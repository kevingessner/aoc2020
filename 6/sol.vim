let pcounts = []
let total = 0
r prob.in
execute "normal! ggdd"
while line('.') < line('$')
 " set mark a here and mark b at the next blank line.
 " the marks delineate the current input section.
 execute "normal! ma/^$\<cr>mb"
 let pcount = line("'b") - line("'a")
 let pcounts += [pcount]
 " insert a newline after every character, as long it is followed by a character (i.e. it's not the last on the line).  \ze starts lookahead.
 'a,'bs/\(.\)\ze./\1\r/eg
 " sort and unique the input lines.  this leaves each character in the input section on its own line.
 'a,'b-1sort
 " concat the lines in each section to a single line.
 .,'b-1s/\n//
 let line = getline(line("'b"))
 for c in uniq(split(line, '\zs'))
     echom "got" count(line, c) "/" pcount c "in" line
     if count(line, c) == pcount
         let total += 1
     endif
 endfor
 echom ""
 " move down one then loop
 execute "normal! 'bj"

endwhile

echom "total:" total
