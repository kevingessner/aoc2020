const fs = require('fs')


const data = fs.readFileSync('prob.in', 'utf8')
const lines = data.split('\n');

var rules = {};
var tests = [];

var i = 0;
while(lines[i]) { // stop at blank line
    const [num, rhs] = lines[i].split(': ');
    console.log(num, ' - ', rhs);
    rules[num] = rhs;
    i++;
}
i++;
while(lines[i]) { // stop at end
    tests.push(lines[i]);
    i++;
}


function getRuleRegexp(num) {
    console.log(`rule ${num}`);
    const rule = rules[num];
    if (/"[a-z]"/.test(rule)) {
        console.log(`terminal ${num} = ${rule}`);
        return rule[1];
    }
    if (num == '8') {
        // '8: 42 | 42 8' means "one or more 42s". AKA /+/
        return `(${getRuleRegexp(42)})+`
    }
    if (num == '11') {
        // '11: 42 31 | 42 11 31' means "one or more 42s followed by that many 31s". That's not regular, so we fake it:
        // inputs are short so check for 1-4 nested pairs.  i.e. /(42(42(42(42 31)?31)?31)?31)/
        // That is enough for these short inputs.
        var fourtwo = getRuleRegexp(42), threeone = getRuleRegexp(31);
        const nest = function(i) {
            if (i <= 0) {
                return '';
            }
            return `(${fourtwo}(${nest(i-1)})?${threeone})`
        }
        return nest(4);
    }
    const opts = rule.split(' | ');
    const re = opts.map(function(opt) {
        const nums = opt.split(' ');
        return '(' + nums.map(getRuleRegexp).join('') + ')';
    }).join('|')
    console.log(`production ${num} - ${rule} = ${re}`);
    return `(${re})`;
}

const re = new RegExp('^' + getRuleRegexp(0) + '$');
console.log(re);
var matches = 0;
for (var line of tests) {
    if (re.test(line)) {
        matches++;
        console.log(`MATCH ${line}`);
    }
}
console.log(matches);
