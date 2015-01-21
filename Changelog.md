Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 0.3.5 (2015-01-21)
-------------------------------------------------
- Fixed bug in debug output caused missing option display.
- Extended string test.

Version 0.3.4 (2014-12-10)
-------------------------------------------------
- Fixed mathjs package specification.

Version 0.3.3 (2014-12-04)
-------------------------------------------------
- Updates allowed versions for alinex-fs module.
- Use absolute path on basedir in file validator.
- Finished basic version of file validator.
- Adding file validator stubs.
- Added unit support for integer and float.
- Add support for derived unit 'bps' in byte type.
- Removed test output.
- Added subelement errors in error message of 'any'-type.
- Fixed indentation in format description.

Version 0.3.2 (2014-11-03)
-------------------------------------------------
- Updated package description.
- Fixed small bug in which stripTags is done on string without specifications.
- Moved error description into error properties for better display.
- Added list of keys to error description in object.
- Fixed package.json version notation.
- Fixed bug with not using new chalk module.

Version 0.3.1 (2014-10-08)
-------------------------------------------------
- Fixed npmignore file.
- Fixed bug with path and duplicate callback in async call.
- Add informal unit setting for byte type.
- Updated alinex-make.
- Allow 'default: false' in boolen type.
- Fixed bug in objects with one rule for all keys and optimized description text.

Version 0.3.0 (2014-09-24)
-------------------------------------------------
- Updated description for objects.
- Added describe text to error messages.
- Finished rewriting of object checks.
- Extended object documentation.
- Started rework for optional use in objects.
- Added new validation type 'byte'.
- Make reference selfcheck more specific.
- Add possibility to use operations on references.
- Added 'hostname' type as example for string extension.
- Removed async there not needed.
- Bug fixes in selfcheck and object validation.
- Added new check type 'and'.
- Adding description for selfcheck.
- Allow the general keys 'title' and 'description' in all selftests.

Version 0.2.3 (2014-09-17)
-------------------------------------------------
- Differentiate between normale function and class in check.
- Optimized source in error message and fixed bug in object test.
- Fixed 'function' check.
- Initial version of function check.
- Added selfcheck for other types.
- Added selfcheck for float and string and removed old reference implementation.
- Added selfcheck method for integers.
- Updated to debug 2.0.0

Version 0.2.2 (2014-08-24)
-------------------------------------------------
- Fixed references with mocha tests.
- Added support for references.

Version 0.2.1 (2014-08-21)
-------------------------------------------------
- Finished internal rewrite but removed reference implementation.
- Updated string type to new structure.
- Updated interval type to new structure.
- Updated percent type to new structure.
- Update integer and float types to new validator structure.
- Internal restructure of module working only for boolean type, yet.
- Start to restructure into classes.
- Fixed reference bug and optimized debug messages.
- Added percent validator.

Version 0.2.0 (2014-08-18)
-------------------------------------------------
- Added time format in interval type.
- Added first reference check with name resolution.
- Check optional and default parameter globally instead of in type.
- Restructured all types and added async checks.
- Restructured base system, boolean and string checks.
- Updated to alinex-make 3.0 for development.
- Renamed check libraries.
- Report the key description for missing keys.
- Rename list to entries in type.any setup.
- Added support to only use allowedKeys = true instead of list.
- Add documentation for default option and real world example.
- Optimized error messages for object keys.
- Optimized debug output and fixed async array check bug.
- Added default option and made internal restructure.

Version 0.1.1 (2014-08-09)
-------------------------------------------------
- Fixed bug in asynchronous call of type.any

Version 0.1.0 (2014-08-08)
-------------------------------------------------
- Added short documentation of type.any check.
- Changed structure to use central result method with better debugging.
- Added type.any for alternative checks.
- Added possibility to give title and description for error reporting of values.
- Fixed some async problems and added typecheck to date.interval.

Version 0.0.3 (2014-08-08)
-------------------------------------------------
- Added async module.
- Make it possible to not define allowed keys but only the mandatory keys and other may exist.
- Removed debugging console output.

Version 0.0.2 (2014-08-07)
-------------------------------------------------
- Fixed date.interval checks.
- Basically running date.interval check with some small errors.
- Added describe texts for array and object options.

Version 0.0.1 (2014-08-06)
-------------------------------------------------
- Finished array and object checks.
- Removed options sublevel in configuration to make simpler definitions.
- Added more checks to array and object types.
- Added basic tests for array and object.
- Added float type checks.
- Some infos
- Add integer type checks.
- Finished string type check.
- Addded validate methods for string test.
- Added type.string check with sanitize options.
- First runable version with only a boolean check.
- Initial commit

