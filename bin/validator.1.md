Alinex Validator
=================================================

This module will help validating complex structures. And should be used on all external information.
Like configuration or user input. It's strength are very complex structures and detailed checks.


Usage
-------------------------------------------------

    validator [options]...

You can run two different tasks.

__Only check data structure:__

    validator --input <file-or-dir> --schema <file>

This will validate the data structure and show you possible errors. This may be used every time
after something is changed.

__Preparse and transform data structure:__

    validator --input <file-or-dir> --schema <file> --output <json-file>

After validation and optimization the resulting data structure will be written as JSON file to
be easily and fast imported in the program.

Options:

    --input, -i     file or directory to read data from       [string] [mandatory]
    --schema, -s    schema to use for validation              [string] [mandatory]
    --output, -o    file to write resulting data structure to             [string]
    --force, -f     force recreating configuration also if up to date    [boolean]

General Options:

    --verbose, -v   run in verbose mode (multiple makes more verbose)      [count]
    --quiet, -q     don't output header and footer                       [boolean]
    --nocolors, -C  turn of color output                                 [boolean]
    --help, -h      Show help                                            [boolean]

You may use environment variables prefixed with 'BUILDER_' to set any of
the options like 'BUILDER_VERBOSE' to set the verbose level.


Benefit of CLI Use
-------------------------------------------------
You may always directly load and validate the data structure in your application but it gives you
more speed and less memory use to call it through CLI before.
- CLI only transforms if source is changed
- no pollution of application memory
- transform may be called on demand manually
- highest performance in config reading
- easy import/require like js modules


Documentation
-------------------------------------------------
See the online [documentation](https://alinex.gitbooks.io/validator) for more information and also
how to setup the schema and use of API.


License
-------------------------------------------------

(C) Copyright 2014-2017 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
