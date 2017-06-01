# Architecture

Heavily based on joi API...


http://2ality.com/i/index2.html private properties


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
