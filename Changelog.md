Version changes
=================================================

The following list gives a short overview about what is changed between
individual versions:

Version 1.0.1 (2015-06-19)
-------------------------------------------------
- Extended tests.
- Fixed key checking in objects.
- Fixed description of object types.
- Added test for interval to run with multiple unit parts.
- Extended test coverage.
- Fixed bugs in file check with exists and filetype.
- Add coveralls badge.
- Remove io.js from travis tests.
- Added more tests and fixed bug in references with auto join.
- Optimized API documentation.

Version 1.0.0 (2015-06-16)
-------------------------------------------------
- Updated documentation.
- Only use values for references after they are checked.
- Added test for circular reference.
- Allow references to references.
- Extend selfchecks to checck that max >= min values.
- Allow shortcut for structure references.
- Allow references in schema definition.
- Fixed bug with old option reference implementation.
- Remove first try to get option variables running.
- Add backreference support in references and fix some bugs since the last changes.
- Added test case for references in options.
- Added support to join arrays together in references.
- Fixed structure and object matching in references and allowed regexp to work.
- Allow structure references to search with asterisk.
- Audded autodetect parser for references.
- Change separator in split values from %% to //.
- Implemented range selection for references.
- Added parse option for references.
- Added match support for references.
- Allow split to use regular expressions as separator.
- Added split functionality for references.
- Added comments for additional checks to fullfill references.
- Updated documentation about context and environment references.
- Fixed reference tests.
- Renamed reference work structure internally.
- Integrate references into values.
- Add hooks for integration.
- Removed old unused code.
- Check all entries of array or object to later add reference checks everywhere.
- Updated documentation for all types.
- Updated byte check.
- Upgraded handlebars check.
- Upgraded file checks.
- Upgraded hostname check.
- Upgraded the interval check.
- Upgraded percent check.
- Upgraded regexp check.
- Upgraded the ipaddr checks.
- Added type any for internal use.
- Added selfcheck tests.
- Optimize schema definition for and and or for better readability.
- Upgraded the and test.
- Rewritten any check as or test.
- Make describe method also asynchronous.
- Upgraded array check to work in new validator.
- Update the function check.
- Restructured object validator with optimized syntax.
- Updated string tests and renamed tostring option to toString.
- Optimized type checks integer and float.
- Restructured library and updated boolean to new structure.
- Added the command references.
- Added command references.
- Finished web references.
- Make the reference.replace() method async.
- Added file and web references.
- Reference can now read struct and context information.
- Added new reference function (basic routines only).
- Integrade concept for regexp in reference path.
- Change the reference syntax description to be more readable and powerful.
- Updated description.
- Document more simple reference syntax.
- Added DATA references code.
- Added possibility to specify allowedKeys in object as RegExp.
- Add reference checks to array.
- Fixed bug in boolean check.
- Move reference check to general rules.
- Fixed code to run async reference tests.
- Make all reference tests work.
- Updated debug messages to have new style in all types.
- Added/updated inline code documentation.
- Optimized line length of comments for better readiness.
- Optimized second run to make only things nit done in the first run.
- Made references for values work using a second round if needed.
- Optimized debug output in check and object.
- Merge branch 'master' of https://github.com/alinex/node-validator
- Text changes.
- Try to restructure again loop.
- Finished struct references to use different path mappings.
- Added debug message with results for calls and subcalls.
- Basic unit checks running.
- First rudimentary implementation.
- Document compositing by example.
- Add rudimentary reference type used for new reference checks.
- Glue first sentences of description text into one to make it more natural sounding.
- Optimize headings in documentation.
- Don't support leading 0 as optional but read it as octal notation.
- Changed reference plan.
- Planing referenc restructuring.
- Give file checks more time on slow test machines.
- Fixed test assert values for byte tests.
- Extended selfchecks to be more strict in allow and deny ranges.
- Finished ipaddr type with api description.
- Changed ipv4 and ipv6 types to combined ipaddr type.
- Initial ipv6 check and planing for new references.
- Finished ipv4 check with tests.
- Added ip version 4 checks.
- Extended allowed time to run some tests.
- Fixed handlebars check to also return function if no handlebars are included.
- Added example for reference checks in the documentation.
- Added tests for regexp and made small fixes.
- Add simple handlebar validation.

Version 0.3.15 (2015-03-20)
-------------------------------------------------
- Added debug message for directory search paths.

Version 0.3.14 (2015-03-18)
-------------------------------------------------
- Added possibility to use dynamic find values for file search.

Version 0.3.13 (2015-03-10)
-------------------------------------------------
- More async changes.
- Added information for version 0.3.13
- Revert version number.
- More fixes for alinex-async.
- Added information for version 0.3.13
- Replace async with alinex-async.

Version 0.3.13 (2015-03-10)
-------------------------------------------------
- Revert version number.
- More fixes for alinex-async.
- Added information for version 0.3.13
- Replace async with alinex-async.

Version 0.3.13 (2015-03-10)
-------------------------------------------------
- Replace async with alinex-async.

Version 0.3.12 (2015-03-10)
-------------------------------------------------
- Fix file.find to work with multiple folders.
- Update documentation structure.

Version 0.3.11 (2015-03-05)
-------------------------------------------------
- Added correct error message if referenced file could not be found.

Version 0.3.10 (2015-03-04)
-------------------------------------------------
- Optimized description text display.
- Optimized wording in error messages.
- Rewrite examples in coffeescript.
- Updated dependent modules.

Version 0.3.9 (2015-02-12)
-------------------------------------------------
- Fixed type error in regexp check.

Version 0.3.8 (2015-02-12)
-------------------------------------------------
- Added regexp validation.

Version 0.3.7 (2015-02-03)
-------------------------------------------------
- Extended file find check to use multiple search paths.
- Small code optimization, prevent duplicate call of same function.
- Bugfix: async file check exitst because of uncatched throw.

Version 0.3.6 (2015-01-21)
-------------------------------------------------
- Fixed bug in async checks for files.
- Fixed bug with check for existing path.

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

