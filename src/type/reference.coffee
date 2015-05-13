# IP Address validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `default` - the value to use if none given
# - `version` - one of 'ipv4' or 'ipv6' and the value will be converted, if possible
# - `format` - compression method to use: 'short', 'long'
# - `allow` - the allowed ip ranges
# - `deny` - the denied ip ranges

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
util = require 'util'
chalk = require 'chalk'
# alinex modules
fs = require 'alinex-fs'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

checkref =
  type: 'object'
  mandatoryKeys: ['REF']
  allowedKeys: ['VAL','FUNC']
  entries:
    REF:
      type: 'array'
      notEmpty: true
      entries:
        type: 'object'
        entries:
          source:
            type: 'string'
            lowerCase: true
            values: ['struct', 'data', 'env', 'file']
          path:
            type: 'string'
    FUNC:
      type: 'function'
      optional: true

# ### get value from path
# - `/xxx.*.yyy` - specify a value in any of the subelements of xxx
# - `/xxx.**.yyy` - specify a value in any of the subelements also multiple levels deep
# - `/xxx.test*.yyy` - specify to search in some subelements
valueAtPath = (data, path, source = []) ->
  switch
    when path[0] is '*'
      list = if Array.isArray data then [0..data.length] else Object.keys data
      for sub in list
        result = valueAtPath data[sub], path[1..], source.concat sub
        return result if result
      return null
    when path[0] is '**'
      list = if Array.isArray data then [0..data.length] else Object.keys data
      for sub in list
        result = valueAtPath data[sub], path[1..], source.concat sub
        return result if result
      for sub in list
        result = valueAtPath data[sub], path, source.concat sub
        return result if result
      return null
    when ~path[0].indexOf '*'
      re = new RegExp "^#{path[0].replace '*', '.*'}$"
      list = if Array.isArray data then [0..data.length] else Object.keys data
      for sub in list
        continue unless sub.match re
        result = valueAtPath data[sub], path[1..], source.concat sub
        return result if result
      return null
    else
      return null unless data[path[0]]?
      work = source.concat path[0]
      return [data[path[0]], work.join '.'] if path.length is 1
      return valueAtPath data[path[0]], path[1..], work


module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A reference to a value. '




      text


  # Synchronous check
  # -------------------------------------------------
  # Only a synchronous check is supported here, also if it comes to file reads.
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "#{check.pathname path} check #{util.inspect value}"
      , chalk.grey util.inspect options
      # make basic check for reference or not
      return value unless typeof value is 'object' and value?.REF?
      # validate reference
      #value = check.subcall path, checkref, value
      # find reference
      result = null
      refname = null
      for ref in value.REF
        # try to get the value
        refname = "#{ref.source}:#{ref.path}"
        debug "#{check.pathname path} find '#{refname}'"
        switch ref.source
          when 'struct'
            absolute = ref.path[0] is '/'
            source = ref.path.split '.'
            if absolute
              source[0] = source[0].replace /^[\/<]*/, ''
            else
              newpath = path[1..] # go one step back to be in parent of reference
              while source[0][0] is '<'
                newpath.shift() if newpath.length
                source[0] = source[0][1..]
              source = newpath.concat source
              refname = "#{ref.source}:/#{source.join '.'}"
              debug "#{check.pathname path} absolute reference '#{refname}'"
            # read value from absolute value
            result = valueAtPath check.value, source
            if result?
              # check for already checked value?????
              unless result[1] in check.checked
                debug "#{check.pathname path} referenced '#{result[1]}' is not checked"
                throw new Error 'EAGAIN'
              # use value
              debug "#{check.pathname path} found '#{util.inspect result[0]}'
              at '#{result[1]}' for '#{refname}'"
              result = result[0]
            else
              debug "#{check.pathname path} reference '#{refname}' not found"
            # `/xxx.yyy` - to specify a value from the structure by absolute path
            # `xxx` - to specify the value sibling value from the given one
            # `<xxx.yyy` - to specify the value based from the parent of the operating object
            # `<<xxx.yyy` - to specify the value based from the grandparent of the operating object

          when 'data'
            source = ref.path.replace(/^[\/<]*/, '').split '.'
            refname = "#{ref.source}:/#{source.join '.'}"
            # read value from absolute value
            result = valueAtPath check.data, source
            if result?
              debug "found '#{util.inspect result[0]}' at '#{result[1]}' for '#{refname}'"
              result = result[0]
            else
              debug "reference '#{refname}' not found"
          when 'env'
            result = process.env[ref.path]
          when 'file'
            result = fs.readFileSync ref.path, 'utf8'
        # run check on retrieved values
        if result? and ref.type?
          result = (new ValidatorCheck refname, ref, result).sync()
        # stop search if value is found
        break if result?
      # use VAL if no ref found
      unless result or !value.VAL?
        debug "#{check.pathname path} use default value"
        result = value.VAL
        refname = 'default reference value'
      unless result
        debug "#{check.pathname path} failed to find reference"
      # run the operation
      if value.FUNC?
        debug "#{check.pathname path} run optimize function"
        result = value.FUNC result, refname
      # return resulting value
      result


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
    , options

