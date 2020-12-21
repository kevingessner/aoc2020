
import { GluegunCommand } from 'gluegun'



const command: GluegunCommand = {
  name: 'aoc',
  run: async toolbox => {
    const { print } = toolbox
    print.info('hello')
  },
}

module.exports = command
