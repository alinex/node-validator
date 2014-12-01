# Domain name validation
# =================================================

# Check the value as valid file or directory entry.
#
# __Sanitize options:__
#
# - `basedir` - (string) relative paths are calculated from this directory
# - `resolve` - (bool) should the given value be resolved to a full path
#
# __Check options:__
#
# - `exists` - (bool) true to check for already existing entry
# - `find` - (bool) find the given file anywhere in the base directory
# - `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:file')
util = require 'util'
fs = require 'alinex-fs'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

module.exports = file =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A valid filesystem entry. '
      text += rules.describe.optional options
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # sanitize


      # get basedir
      # resolve
      # find
      # else exists

      # validate

      # filetype

      check.subcall path, suboptions, value

  async:





  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      allowedKeys: true
      entries:
        type:
          type: 'string'
        title:
          type: 'string'
          optional: true
        description:
          type: 'string'
          optional: true
        optional:
          type: 'boolean'
          optional: true
        default:
          type: 'string'
          optional: true
        basedir:
          type: 'string'
        resolve:
          type: 'boolean'
          default: false
        exists:
          type: 'boolean'
          default: false
        find:
          type: 'boolean'
          default: false
        filetype:
          type: 'string'
          lowerCase: true
          values: [
            'f', 'file'
            'd', 'dir', 'directory'
            'l', 'link'
          ]
          optional: true
    , options

