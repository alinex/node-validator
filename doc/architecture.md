# Architecture

The Validator is based on classes which helps you to easily define a specific data
schema. Therefore the appropriate class is used to create an instance and set it up
using it´s methods. This newly created schema may also be a structure and combination
of different schema class instances.

This schema can describe itself human readable and can be given a data structure
to validate. It will run asynchronously over the data structure to check and optimize
it. As a result it will return an promise with the resulting data structure.

If the data isn´t valid it will reject with an Error object which can show the
real problem in detail.


## Type definition

- new class
- extends `Schema` or other schema
- may have some validation properties
- with rules to set them
- and an overwritten `validate` method

## Schema setup

- import schema
- instantiate it
- set validation settings

## Validation

- `load` data
- `validate`
- `describe`

## Accessing values

- `object`
- `get` direct value (on object)
- `toJS` export javascript

## CLI

- convert yaml

## Special

- `clear` data
- multiple loading
- json schema import

## Ideas

- defaults in schema
- default as extra data structure
- source info
- error list
- structure
