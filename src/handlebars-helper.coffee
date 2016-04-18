# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
moment = require 'moment'
math = require 'mathjs'


# Handlebars Helper
# -------------------------------------------------

# ### Get arguments
# - name - name of the function
# - args - the normal parameters
# - hash - named parameters
# - fn - content function in block helpers
# - inverse - else part of block helpers
# - data - current context
argParse = (args) ->
  args = [].slice.call(args)
  options = args[args.length-1]
  options.args = args[0..-2]
  options.data = options.data.root
  options

helper =

  is: ->
    {args, fn, inverse, data} = argParse arguments
    if args.length is 2
      [left, right] = args
      operator = '=='
    else
      [left, operator, right] = args
    # use count of entries for array
    if typeof left is 'object'
      left = Object.keys left
      left = left.length if typeof left is 'object'
    # call comparison
    result = switch operator
      when '>' then left > right
      when '<' then left < right
      when '>=' then left >= right
      when '<=' then left <= right
      when '==' then left is right
      when 'not' then left isnt right
      when '!=' then left isnt right
      when 'in'
        right = right.split /\s*,\s*/ unless Array.isArray right
        ~right.indexOf left
      else left
    # execute content or else part
    if result then fn data else inverse data


  # ### dateFormat
  #
  # format an ISO date using Moment.js - http://momentjs.com/
  #
  #     date = new Date()
  #     {{dateFormat date "MMMM YYYY"}}
  #     # January 2016
  #     {{dateFormat date "LL"}}
  #     # January 18, 2016
  #     {{#dateFormat "LL"}}2016-01-18{{/dateFormat}}
  #     # January 18, 2016
  dateFormat: ->
    {args, fn} = argParse arguments
    if fn
      date = fn this
      [format] = args
    else
      [date, format] = args
    # format date
    moment(new Date date).format format ? 'MMM Do, YYYY'

  # ### dateAdd
  #
  # Add interval to date.
  #
  #     date = new Date()
  #     {{dateAdd date 1 "month"}}
  #     {{#dateAdd 1 "month"}}2016-01-18{{/dateAdd}}
  dateAdd: ->
    {args, fn} = argParse arguments
    if fn
      date = fn this
      [count, interval] = args
    else
      [date, count, interval] = args
    # calculate date
    moment new Date date
    .add count, interval
    .toDate()

  unitFormat: ->
    {args} = argParse arguments
    num = args.shift()
    from = args.shift() if args.length and typeof num is 'number'
    to = args.shift() if args.length and typeof args[0] is 'string'
    precision = args.shift() if args.length
    # format value
    num = "#{num}#{from}" if from
    value = math.unit num
    value = value.to to if to
    value.format precision ? 3


# Register Helper Methods
# ----------------------------------------------------------------
exports.registerHelpers = (handlebars) ->
  # register helper
  for key, fn of helper
    handlebars.registerHelper key, fn
