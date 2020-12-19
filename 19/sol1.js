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
    const opts = rule.split(' | ');
    const re = opts.map(function(opt) {
        const nums = opt.split(' ');
        return '(' + nums.map(getRuleRegexp).join('') + ')';
    }).join('|')
    console.log(`production ${num} - ${rule} = ${re}`);
    return `(${re})`;
}

const re = new RegExp('^' + getRuleRegexp(0) + '$');
var matches = 0;
for (var line of tests) {
    if (re.test(line)) {
        matches++;
    }
}
console.log(matches);
