# Alinex Validator

This module will help validating complex structures. And should be used on all external information.
Like configuration or user input. It's strength are very complex structures.

- class based schema definitions
- multiple predefined types
- multiple options per type
- check and transform values
- specialized in deep and complex data structures
- supports dependency checks with references
- can give a human readable description
- command line interface
- including data loading

The core builds a schema which is build as combination of different type instances from the schema
classes. This schema builder mechanism allows to setup complex structures with optimizations
and logical validation. It can be build step by step, cloned and redefined...

With such a schema you can directly validate your data structure or use it to load and validate
data structure or to transform them into optimized js data files using the command line interface.
A schema can also describe itself human readable for users to describe what is needed.
If some value failed an error message is given with reference to the original value and the
description what failed and what is needed.

This library can help you make your life secure and easy but you should have to
define your data structure deeply, before. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values like for `handlebars`
type you get a ready to use handlebar function back.
