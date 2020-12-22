// export types
export class Allergen {
  name: string;
  possibleIngs: Set<string>;

  constructor(name: string, ings: Set<string>) {
    this.name = name;
    this.possibleIngs = ings;
  }
}

export function load(contents: string): { allergens: Map<string, Allergen>, ingredientNames: string[] } {
  let allergens: Map<string, Allergen> = new Map();
  let ingredientNames: string[] = [];
  contents.split('\n').forEach(function (line: string) {
    if (!line) return;
    let [iWords, aWords] = line.split(' (contains ');
    let aNames = aWords.replace(')', '').split(', ');
    let iNames = new Set<string>(iWords.split(' '));
    iNames.forEach(i => ingredientNames.push(i));
    aNames.forEach(a => {
      if (allergens.has(a)) {
        let aller = allergens.get(a);
        [...aller.possibleIngs].forEach(ing => {
          if (!iNames.has(ing)) {
            aller.possibleIngs.delete(ing)
            //print.info(`removing ${ing} from ${aller.name}`)
          }
        })
      } else {
      //print.info([`creating ${a} with`, iNames])
        allergens.set(a, new Allergen(a, new Set([...iNames])));
      }
    });
  });

  return { allergens, ingredientNames };
}
