import { GluegunCommand } from 'gluegun'
import { Allergen, load } from '../types'

const command: GluegunCommand = {
  name: 'sol2',
  run: async toolbox => {
    const { print, filesystem, parameters } = toolbox
    let filename: string = parameters.first;

    print.info('hello world ' + filename)
    let contents: string = await filesystem.readAsync(filename)
    let { allergens, ingredientNames } = load(contents);
    print.info(allergens);
    print.info(ingredientNames);
    let assigned: Allergen[] = [];
    // Walk the allergens. Any that has a single possible ingredient is assigned to that ingredient, which can then be removed from all other ingredients.
    while (allergens.size) {
      let oneIngAllergen: Allergen;
      for (let [_, allergen] of allergens) {
        if (allergen.possibleIngs.size == 1) {
          oneIngAllergen = allergen;
          break;
        }
      }
      if (!oneIngAllergen) {
        // Failed to make progress -- no allergens have a single possible ingredient.
        throw 'oh no';
      }
      allergens.delete(oneIngAllergen.name);
      assigned.push(oneIngAllergen);
      let theIng: string = oneIngAllergen.possibleIngs.values().next().value;
      allergens.forEach(allergen => allergen.possibleIngs.delete(theIng));
    }
    assigned.sort((a1, a2) => a1.name.localeCompare(a2.name));
    print.info([...assigned].map(a => a.possibleIngs.values().next().value).join(','));
  },
}

module.exports = command
