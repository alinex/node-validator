require('alinex-error').install()
chai = require 'chai'
expect = chai.expect

async = require 'alinex-async'
path = require 'path'

test = require '../test'
reference = require '../../lib/reference'

describe "References", ->

  describe "detect", ->

    it "should know that there are no references", ->
      values = [
        'one'
        1
        [1,2,3]
        { one: 1 }
        new Error '????'
        undefined
        null
      ]
      for value in values
        result = reference.exists value
        expect(result, value).to.be.false

    it "should find references", ->
      values = [
        '<<<name>>>'
        'My name is <<<name>>>'
        '<<<firstname>>> <<<lastname>>>'
      ]
      for value in values
        result = reference.exists value
        expect(result, value).to.be.true

  describe "simple", ->

    it "should keep values without references", (cb) ->
      values = [
        'one'
        1
        [1,2,3]
        { one: 1 }
        new Error '????'
        undefined
        null
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal value
          cb()
      , cb

    it "should replace references with default value", (cb) ->
      values =
        '<<<notthere | name>>>': 'name' # whole reference
        'My name is <<<notthere | alex>>>': 'My name is alex' # reference in string
        '<<<notthere | firstname>>> <<<notthere | lastname>>>': 'firstname lastname' #concatenate
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

    it "should use alternatives", (cb) ->
      process.env.TESTVALIDATOR = 123
      values =
        '<<<env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://NOTEXISTING | 456>>>': '456'
        '<<<env://NOTEXISTING | env://TESTVALIDATOR | 456>>>': process.env.TESTVALIDATOR
        '<<<env://TESTVALIDATOR | env://NOTEXISTING | 456>>>': process.env.TESTVALIDATOR
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

    it "should fail for empty reference", (cb) ->
      value = '<<<>>>'
      reference.replace value, (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.not.exist
        cb()

  describe "environment", ->

    it "should find environment value", (cb) ->
      process.env.TESTVALIDATOR = 123
      value = '<<<env://TESTVALIDATOR>>>'
      reference.replace value, (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.equal process.env.TESTVALIDATOR
        cb()

    it "should fail for environment", (cb) ->
      value = '<<<env://TESTNOTEXISTING>>>'
      reference.replace value, (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.not.exist
        cb()

  describe "structure", ->

    soccer =
      europe:
        germany:
          stuttgart: 'VFB Stuttgart'
          munich: 'FC Bayern'
        spain:
          madrid: 'Real Madrid'
      southamerica:
        brazil:
          saopaulo: 'FC Sao Paulo'

    it "should find absolute path", (cb) ->
      data =
        absolute: 123
      value = '<<<struct:///absolute>>>'
      reference.replace value,
        data: data
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, value).to.equal data.absolute
        cb()

    it "should fail with absolute path", (cb) ->
      struct =
        absolute: 123
      values = [
        '<<<struct:///notfound>>>'
        '<<<struct:///notfound/value>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          data: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

    it "should find relative path", (cb) ->
      values =
        '<<<struct://stuttgart>>>': soccer.europe.germany.stuttgart
        '<<<struct://munich>>>': soccer.europe.germany.munich
        '<<<struct://spain>>>': soccer.europe.spain
        '<<<struct://spain/madrid>>>': soccer.europe.spain.madrid
        '<<<struct://southamerica/brazil/saopaulo>>>': soccer.southamerica.brazil.saopaulo
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: soccer
          path: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should fail with relative path", (cb) ->
      values = [
        '<<<struct:///berlin>>>'
        '<<<struct:///america/newyork>>>'
        '<<<struct:///southamerica/chile>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          data: soccer
          path: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

    it "should find backreferenced path", (cb) ->
      values =
        '<<<struct://../germany/stuttgart>>>': soccer.europe.germany.stuttgart
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: soccer
          path: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should fail with backreferenced path", (cb) ->
      values = [
        '<<<struct:///../stuttgart>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          data: soccer
          path: ['europe','germany']
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

    it "should find context path", (cb) ->
      struct =
        absolute: 123
      values = [
        '<<<context:///absolute>>>'
        '<<<context://absolute>>>'
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value,
          spec:
            context: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal struct.absolute
          cb()
      , cb

  describe "file", ->
    @timeout 5000

    it "should find file value", (cb) ->
      values = [
        "<<<file://#{path.dirname __dirname}/data/textfile>>>"
        "<<<file://test/data/textfile>>>"
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal '123'
          cb()
      , cb

    it "should fail on file", (cb) ->
      values = [
        "<<<file://#{path.dirname __dirname}/data/notfound>>>"
        "<<<file://textfile>>>"
      ]
      async.eachSeries values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

  describe "web", ->
    @timeout 10000

    it "should find http/https value", (cb) ->
      values =
        '<<<https://raw.githubusercontent.com/alinex/node-validator/master/test/data/textfile>>>': '123'
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

    it "should fail on web resource", (cb) ->
      values = [
        "<<<http://www.this-server-did-not-exist-here.org>>>"
        "<<<http://www.heise.de/page-did-not-exist-here>>>"
      ]
      async.each values, (value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.not.exist
          cb()
      , cb

  describe "command", ->

    it "should execute commands", (cb) ->
      values =
        '<<<cmd://uname>>>': 'Linux\n'
        '<<<cmd://cat test/data/textfile>>>': '123'
        '<<<cmd://cat test/data/poem| head -1>>>': 'William B Yeats (1865-1939)\n'
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value, (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

  describe "checks", ->

    it "should check against integer", (cb) ->
      struct =
        number: 123
        string: '123'
      values =
        '<<<struct:///number#{type:"integer"}>>>': 123
        '<<<struct:///number#{type:"integer"}>>>': 123
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: struct
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.equal check
          cb()
      , cb

  describe "split", ->

    it "should split into lines and characters", (cb) ->
      text = ''
      text += "#{i*10123456789}\n" for i in [1..9]
      reference.replace "<<<struct:///text#%\n#>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.length, 'rows').to.equal 11
        expect(result[0], 'row 0').to.not.exist
        expect(result[1].length, 'columns').to.equal 12
        cb()

    it "should split into lines and columns tab separated", (cb) ->
      text = ''
      text += "#{i*1}\t#{i*2}\t#{i*3}\t#{i*4}\n" for i in [1..9]
      reference.replace "<<<struct:///text#%\n//\t#>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.length, 'rows').to.equal 11
        expect(result[0], 'row 0').to.not.exist
        expect(result[1].length, 'columns').to.equal 5
        cb()

    it "should split csv", (cb) ->
      text = ''
      text += "#{i*1}; #{i*2}; #{i*3}; #{i*4}\n" for i in [1..9]
      reference.replace "<<<struct:///text#%\n//;\\s*>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.length, 'rows').to.equal 11
        expect(result[0], 'row 0').to.not.exist
        expect(result[1].length, 'columns').to.equal 5
        cb()

  describe "match", ->

    it "should find words", (cb) ->
      reference.replace "<<<struct:///text#/\\w+/>>>",
        data:
          text: 'This is a normal text with 8 words.'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.length, 'words').to.equal 8
        cb()

  describe "parser", ->

    it "should analyze js", (cb) ->
      reference.replace "<<<struct:///text#$js>>>",
        data:
          text: '{one: 1, two: 2}'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.one, 'one').to.equal 1
        expect(result.two, 'two').to.equal 2
        cb()

    it "should analyze json", (cb) ->
      reference.replace "<<<struct:///text#$json>>>",
        data:
          text: '{"one": 1, "two": 2}'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.one, 'one').to.equal 1
        expect(result.two, 'two').to.equal 2
        cb()

    it "should analyze yaml", (cb) ->
      reference.replace "<<<struct:///text#$yaml>>>",
        data:
          text: 'one: 1\ntwo: 2'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.one, 'one').to.equal 1
        expect(result.two, 'two').to.equal 2
        cb()

    it "should analyze xml", (cb) ->
      reference.replace "<<<struct:///text#$xml>>>",
        data:
          text: '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<data><one>1</one><two>2</two></data>'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.exist
        expect(result.data.one, 'one').to.deep.equal ['1']
        expect(result.data.two, 'two').to.deep.equal ['2']
        cb()

  describe "ranges", ->

    text = ''
    text += "#{i*10123456789}\n" for i in [1..9]

    it "should get specific line", (cb) ->
      reference.replace "<<<struct:///text#3>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal '30370370367'
        cb()

    it "should get line range", (cb) ->
      reference.replace "<<<struct:///text#3-5>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal ['30370370367','40493827156','50617283945']
        cb()

    it "should get line list", (cb) ->
      reference.replace "<<<struct:///text#3,5>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal ['30370370367','50617283945']
        cb()

    it "should get line range + list", (cb) ->
      reference.replace "<<<struct:///text#3-5,8>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal [
          '30370370367','40493827156','50617283945'
          '80987654312']
        cb()

    it "should get specific column", (cb) ->
      reference.replace "<<<struct:///text#3[3]>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal '3'
        cb()

    it "should get specific column range", (cb) ->
      reference.replace "<<<struct:///text#3[3-5]>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal ['3', '7', '0']
        cb()

    it "should get specific column list", (cb) ->
      reference.replace "<<<struct:///text#3[3,5]>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal ['3', '0']
        cb()

    it "should allow alltogether", (cb) ->
      reference.replace "<<<struct:///text#3-5[3],8[5-6,9]>>>",
        data:
          text: text
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.deep.equal [
          [ '3' ], [ '4' ], [ '6' ]
          [ '7', '6', '3' ]
        ]
        cb()

  describe "objects", ->

    soccer =
      clubs:
        europe:
          germany:
            stuttgart: 'VFB Stuttgart'
            munich: 'FC Bayern'
            hamburg: 'Hamburger SV'
          spain:
            madrid: 'Real Madrid'
            barcelona: 'FC Barcelona'
        southamerica:
          brazil:
            saopaulo: 'FC Sao Paulo'

    it "should access element per path", (cb) ->
      values =
        '<<<struct://clubs#europe/germany/stuttgart>>>': 'VFB Stuttgart'
        '<<<struct://clubs#southamerica/brazil>>>': {saopaulo: 'FC Sao Paulo'}
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: soccer
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should be undefined if not existing", (cb) ->
      values = [
        '<<<struct://clubs#europe/germany/berlin>>>'
        '<<<struct://clubs#asia>>>'
        '<<<struct://clubs#asia/china/peking>>>'
      ]
      async.each values, (value, cb) ->
        reference.replace value,
          data: soccer
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, 'result').to.not.exist
          cb()
      , cb

    it "should find using asterisk", (cb) ->
      values =
        '<<<struct://clubs#europe/*/stuttgart>>>': 'VFB Stuttgart'
        '<<<struct://clubs#**/stuttgart>>>': 'VFB Stuttgart'
        '<<<struct://clubs#*/brazil>>>': {saopaulo: 'FC Sao Paulo'}
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: soccer
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should find using regular expressions", (cb) ->
      values =
        '<<<struct://clubs#europe/germany/\\w*m\\w*>>>': ['FC Bayern', 'Hamburger SV']
        '<<<struct://clubs#europe/germany/.*[ic].*>>>': 'FC Bayern'
      async.forEachOfSeries values, (check, value, cb) ->
        reference.replace value,
          data: soccer
        , (err, result) ->
          expect(err, 'error').to.not.exist
          expect(result, value).to.deep.equal check
          cb()
      , cb

    it "should auto parse and access element", (cb) ->
      reference.replace "<<<struct:///text#one>>>",
        data:
          text: '{one: 1, two: 2}'
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal 1
        cb()

  describe "join", ->

    it "should join array together", (cb) ->
      reference.replace "<<<struct:///text#$join>>>",
        data:
          text: [1, 2, 3, 4]
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal '1, 2, 3, 4'
        cb()

    it "should join multilevel array together", (cb) ->
      reference.replace "<<<struct:///text#$join  and //, #{}>>>",
        data:
          text: [
            [1, 2, 3, 4]
            [8, 9]
          ]
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal '1, 2, 3, 4 and 8, 9'
        cb()

    it "should join multilevel with same phrase together", (cb) ->
      reference.replace "<<<struct:///text#$join , #{}>>>",
        data:
          text: [
            [1, 2, 3, 4]
            [8, 9]
          ]
      , (err, result) ->
        expect(err, 'error').to.not.exist
        expect(result, 'result').to.equal '1, 2, 3, 4, 8, 9'
        cb()

  describe "integration", ->

    it "should call references in values", (cb) ->
      test.equal
        type: 'string'
      , [
        ['<<<notthere | name>>>', 'name']
      ], cb

    it "should call references in sub values", (cb) ->
      test.equal
        type: 'object'
      , [
        [{name:'<<<notthere | name>>>'}, {name:'name'}]
      ], cb

    it "should call struct references in sub values", (cb) ->
      test.equal
        type: 'object'
      , [
        [{min: 5, max:'<<<struct://min>>>'}, {min:5,max:5}]
      ], cb

    it "should call references in options", (cb) ->
      struc =
        type: 'object'
        keys:
          min:
            type: 'integer'
          max:
            type: 'integer'
            min: '<<<struct://min>>>'
      test.same struc, [
        min: 5
        max: 7
      ,
        min: 5
        max: 5
      ], ->
        test.fail struc, [
          min: 5
          max: 4
        ], cb

    it "should call references in options with short syntax", (cb) ->
      struc =
        type: 'object'
        keys:
          min:
            type: 'integer'
          max:
            type: 'integer'
            min: '<<<min>>>'
      test.same struc, [
        min: 5
        max: 7
      ,
        min: 5
        max: 5
      ], ->
        test.fail struc, [
          min: 5
          max: 4
        ], cb

  describe "multiref", ->

    it "should call struct -> env", (cb) ->
      process.env.MIN = 5
      struc =
        type: 'object'
        keys:
          minmax:
            type: 'string'
          max:
            type: 'integer'
            min: '<<<minmax>>>'
      test.same struc, [
        minmax: '<<<env://MIN>>>'
        max: 7
      ], ->
        test.fail struc, [
          minmax: '<<<env://MIN>>>'
          max: 4
        ], cb

    it "should call struct -> struct (checked)", (cb) ->
      test.equal
        type: 'object'
      , [
        [
          one: 5
          two: '<<<one>>>'
          three: '<<<two>>>'
        ,
          one: 5
          two: 5
          three: 5
        ]
      ], cb

    it "should call struct -> struct (unchecked)", (cb) ->
      test.equal
        type: 'object'
      , [
        [
          three: '<<<two>>>'
          two: '<<<one>>>'
          one: 5
        ,
          three: 5
          two: 5
          one: 5
        ]
      ], cb

    it "should fail on circular reference", (cb) ->
      @timeout 20000
      domain = require('domain').create()
      domain.on 'error', -> cb()
      domain.enter()
      try
        test.fail
          type: 'object'
        , [
            three: '<<<two>>>'
            two: '<<<one>>>'
            one: '<<<three>>>'
        ], cb
      catch err
        expect(err).to.exist
        cb()
      domain.exit()

    it "should use reference after value is checked", (cb) ->
      test.equal
        type: 'object'
        keys:
          one:
            type: 'integer'
            round: true
      , [
        [
          three: '<<<two>>>'
          two: '<<<one>>>'
          one: 5.6
        ,
          three: 6
          two: 6
          one: 6
        ]
      ], cb

