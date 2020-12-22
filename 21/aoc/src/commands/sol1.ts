import { GluegunCommand } from 'gluegun'
import { load } from '../types'

const command: GluegunCommand = {
  name: 'sol1',
  run: async toolbox => {
    const { print, filesystem, parameters } = toolbox
    let filename: string = parameters.first;

    print.info('hello world ' + filename)
    let contents: string = await filesystem.readAsync(filename)
    let { allergens, ingredientNames } = load(contents);
    print.info(allergens);
    print.info(ingredientNames);

    let unsafeIngs: Set<string> = new Set();
    allergens.forEach(a => a.possibleIngs.forEach(i => unsafeIngs.add(i)));
    let safeIngs = [];
    for (let ing of ingredientNames) {
      if (!unsafeIngs.has(ing)) safeIngs.push(ing);
    }
    print.info(safeIngs);
    print.info(safeIngs.length);
  },
}

module.exports = command
