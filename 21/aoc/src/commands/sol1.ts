import { GluegunCommand } from 'gluegun'


class Allergen {
  name: string;
  possibleIngs: Set<string>;

  constructor(name: string, ings: Set<string>) {
    this.name = name;
    this.possibleIngs = ings;
  }
}

const command: GluegunCommand = {
  name: 'sol1',
  run: async toolbox => {
    const { print, filesystem, parameters } = toolbox
    let filename: string = parameters.first;

    print.info('hello world ' + filename)
    let contents: string = await filesystem.readAsync(filename)
    let allers: Map<string, Allergen> = new Map();
    let ings: string[] = [];
    contents.split('\n').forEach(function (line: string) {
      if (!line) return;
      let [iWords, aWords] = line.split(' (contains ');
      let aNames = aWords.replace(')', '').split(', ');
      let iNames = new Set<string>(iWords.split(' '));
      iNames.forEach(i => ings.push(i));
      aNames.forEach(a => {
        if (allers.has(a)) {
          let aller = allers.get(a);
          [...aller.possibleIngs].forEach(ing => {
            if (!iNames.has(ing)) {
              aller.possibleIngs.delete(ing)
              print.info(`removing ${ing} from ${aller.name}`)
            }
          })
        } else {
          print.info([`creating ${a} with`, iNames])
          allers.set(a, new Allergen(a, new Set([...iNames])));
        }
      });
    });

    print.info(allers);
    print.info(ings);
    let unsafeIngs: Set<string> = new Set();
    allers.forEach(a => a.possibleIngs.forEach(i => unsafeIngs.add(i)));
    let safeIngs = [];
    for (let ing of ings) {
      if (!unsafeIngs.has(ing)) safeIngs.push(ing);
    }
    print.info(safeIngs);
    print.info(safeIngs.length);
  },
}

module.exports = command
