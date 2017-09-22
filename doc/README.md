# Alinex Validator

This module will help validating complex structures. And should be used on all external information.
Like configuration or user input. It's strength are very complex structures but as easily it works
with simple things. It's the best validator ever, see the comparison with others later.

- class based schema definitions
- multiple predefined types
- multiple options per type
- __check and transform__ values
- specialized in deep and complex data structures
- supports __dependency checks__ with references
- can give a human readable description
- command line interface (cli)
- including data loading
- precompile JSON config for any system

The core builds a __schema__ which is build as combination of different type instances from the schema
classes. This schema builder mechanism allows to setup complex structures with optimizations
and logical validation. It can be build step by step, cloned and redefined...

With such a schema you can directly __validate__ your data structure or use it to load and validate
data structure or to transform them into optimized JSON data files using the command line interface.
A schema can also describe itself human readable for users to describe what is needed.
If some value failed an error message is given with reference to the original value and the
description what failed and what is needed.

This library can help you make your life secure and easy but you should have to
define your data structure deeply, before. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values and easy to use configuration files back.

You may also split up complex configuration files for any system into multiple files which are
combined together by the validator after each change.
