# Validator for simple types
# =================================================

debug = require('debug')('validator:type')

# Send value and return it
# -------------------------------------------------
# This helps supporting both return values and callbacks at the same time.
done = (err, value, cb = ->) ->
  cb err, value
  err ? value

# Boolean value
# -------------------------------------------------
exports.boolean =
  check: (name, value, options, cb) ->
    debug "Check '#{value}' for #{name}", options
    switch typeof value
      when 'boolean'
        return done null, value, cb
      when 'string'
        switch value.toLowerCase()
          when 'true', '1', 'on', 'yes'
            return done null, true, cb
          when 'false', '0', 'off', 'no'
            return done null, false, cb
      when 'number'
        switch value
          when 1
            return done null, true, cb
          when 0
            return done null, false, cb
    done new Error("The value '#{value}' is no boolean for #{name}."), null, cb
  describe: (options) ->
    "The value has to be a boolean. The value will be true for 1, 'true', 'on',
    'yes' and it will be considered as false for 0, 'false', 'off', 'no', '.
    Other values are not allowed."
