// @flow
import yargs from 'yargs'
import alinex from 'alinex-core'
import chalk from 'chalk'

import Validator from './index'

// Support quiet mode through switch
let quiet = false
for (const a of ['--get-yargs-completions', 'bashrc', '-q', '--quiet']) {
  if (process.argv.includes(a)) quiet = true
}

// Error management
alinex.initExit()
process.on('exit', () => {
  if (!quiet) console.log('Goodbye\n') // eslint-disable-line no-console
})

// Main routine
if (!quiet) {
  console.log(chalk.grey('Initializing alinex-validator...')) // eslint-disable-line no-console
}

yargs.usage('\nUsage: $0 [options]')
  .env('VALIDATOR') // use environment arguments prefixed with VALIDATOR_
  // examples
  .example('$0 -i config.yml -s schema.js', 'to check the file for validity')
  .example('$0 -i config.yml -s schema.js -o result.json', 'to transform the data to the json file')
  .options({
    // specific options
    input: {
      alias: 'i',
      describe: 'file or directory to read data from',
      type: 'string',
      array: true,
      demand: true,
    },
    schema: {
      alias: 's',
      describe: 'schema to use for validation',
      type: 'string',
      demand: true,
    },
    output: {
      alias: 'o',
      describe: 'file to write resulting data structure to',
      type: 'string',
    },
    force: {
      alias: 'f',
      describe: 'force recreating configuration also if up to date',
      type: 'boolean',
    },
    // general options
    verbose: {
      alias: 'v',
      describe: 'run in verbose mode (multiple makes more verbose)',
      count: true,
      global: true,
    },
    quiet: {
      alias: 'q',
      describe: 'don\'t output header and footer',
      type: 'boolean',
      global: true,
    },
    nocolors: {
      alias: 'C',
      describe: 'turn of color output',
      type: 'boolean',
      global: true,
    },
    help: {
      alias: 'h',
      description: 'display help message',
    },
  })
  // help
yargs.help('help')
  .epilogue('You may use environment variables prefixed with \'VALIDATOR_\' to set any of \
the options like \'VALIDATOR_VERBOSE\' to set the verbose level.\n\
For more information, look into the man page.')
  .completion('bashrc-script', false)
  // validation
  .strict()
  .fail((err) => {
    err = new Error(err)
    err.description = 'Specify --help for usage'
    alinex.exit(2, err)
  })

// now parse the arguments
const argv = yargs.argv

// run commands
if (argv.output) {
  new Validator().transform(argv.input, argv.schema, argv.output, argv)
    .catch((err) => {
      console.log(err.message) // eslint-disable-line
    })
} else new Validator().check(argv.input, argv.schema)
