# Alinex Validator

This module will help validating complex structures. And should be used on all
external information.

- easy build class based schema definitions
- multiple predefined types
- easy to extend schema types
- check value against schema
- supports sanitization and optimization
- also possible in deep and complex data structures
- can give a human readable description
- supports dependency checks
- transform schema and values

The schema based definition using instances of the predefined schema classes gives
the opportunity to define a detailed structure step by step. Later you can run the
check of this created schema structure on your data structure.

This is mostly used in configuration there it will preparse all settings and check
them before running and use them. It will give a detailed description of the problems
if there are some. It can also save the result as pure JavaScript files to be imported
at runtime without the necessary to recheck them.

This library can help you make your life secure and easy but you have to run
every external data through it using a detailed data description. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values like for `handlebars`
type you get a ready to use handlebar function back.
