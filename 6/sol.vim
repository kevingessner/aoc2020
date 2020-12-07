r prob.in
execute "normal! ggdd"
while line('.') < line('$')
 " set mark a here and mark b at the next blank line.
 " the marks delineate the current input section.
 execute "normal! ma/^$\<cr>mb"
 " insert a newline after every character, as long it is followed by a character (i.e. it's not the last on the line).  \ze starts lookahead.
 'a,'bs/\(.\)\ze./\1\r/eg
 " sort and unique the input lines.  this leaves one of each character in the input section, on its own line.
 'a,'b-1sort u
 " concat the lines in each section to a single line.
 .,'b-1s/\n//
 " move down one then loop
 execute "normal! 'bj"

endwhile

func! ItemLen(k,v)
 return strlen(a:v)
endfunc

let lens = map(getbufline(bufnr('%'), 0, '$'), function('ItemLen'))
let total = 0
for l in lens
    let total += l
endfor
echom join(lens, "+") "=" total
