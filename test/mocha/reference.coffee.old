require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

describe "References", ->

  ###########################################################################################

  describe "simple ENV checks", ->

    simple = null
    beforeEach ->
      simple =
        type: 'reference'
    it "should keep normal values", ->
      test.same simple, 'one'
      test.same simple, 1
      test.same simple, [1,2,3]
      test.same simple, { one: 1 }
      test.same simple, (new Error '????')
      test.same simple, undefined
      test.same simple, null
    it "should get ENV reference", ->
      process.env.TESTVALIDATOR = 123
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR'
        ]
      , '123'
    it "should get STRUCT reference", ->
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR'
        ]
      , '123'
    it "should run checks", ->
      process.env.TESTVALIDATOR = 123
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR'
          type: 'integer'
        ]
      , 123
    it "should work on missing reference", ->
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR2'
        ]
      , undefined
    it "should return default value", ->
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR2'
        ]
        VAL: 0
      , 0
    it "should run operations", ->
      process.env.TESTVALIDATOR = 123
      test.equal simple,
        REF: [
          source: 'env'
          path: 'TESTVALIDATOR'
          type: 'integer'
        ]
        FUNC: (v) -> ++v
      , 124

  ###########################################################################################

  describe "sync STRUCT checks", ->

    it "should get absolute path", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref: 1
    it "should get absolute path from deep", ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '/data'
            ]
      ,
        data: 1
        sub:
          ref: 1
    it "should get relative path", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'data'
          ]
      ,
        data: 1
        ref: 1
    it "should get relative path with parent", ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '<data'
            ]
      ,
        data: 1
        sub:
          ref: 1
    it "should get relative path with grandparent", ->
      test.deep
        type: 'object'
      ,
        data: 1
        group:
          sub:
            ref:
              REF: [
                source: 'struct'
                path: '<<data'
              ]
      ,
        data: 1
        group:
          sub:
            ref: 1
    it "should get sub element", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.sub.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using asterisk", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using double asterisk", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: '**.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using like syntax", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.s*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1

    it "should get ref->ref->value", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/data'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
    it "should get ref->ref->value (need for second loop)", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
    it "should fail on circular reference", ->
      test.fail
        type: 'object'
      ,
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]

  ###########################################################################################

  describe "async STRUCT checks", ->
    it "should get absolute path", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref: 1
      , done
    it "should get absolute path from deep", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '/data'
            ]
      ,
        data: 1
        sub:
          ref: 1
      , done
    it "should get relative path", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'data'
          ]
      ,
        data: 1
        ref: 1
      , done
    it "should get relative path with parent", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '<data'
            ]
      ,
        data: 1
        sub:
          ref: 1
      , done
    it "should get relative path with grandparent", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        group:
          sub:
            ref:
              REF: [
                source: 'struct'
                path: '<<data'
              ]
      ,
        data: 1
        group:
          sub:
            ref: 1
      , done
    it "should get sub element", (done) ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.sub.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
      , done
    it "should get sub element using asterisk", (done) ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
      , done
    it "should get sub element using double asterisk", (done) ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: '**.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
      , done
    it "should get sub element using like syntax", (done) ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.s*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
      , done
    it "should get ref->ref->value", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/data'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
      , done
    it "should get ref->ref->value (need for second loop)", (done) ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
      , done
    it "should fail on circular reference", (done) ->
      test.fail
        type: 'object'
      ,
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]
      , done


  ###########################################################################################

  describe.only "DATA checks", ->

    it "should get absolute path", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref: 1
    it "should get absolute path from deep", ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '/data'
            ]
      ,
        data: 1
        sub:
          ref: 1
    it "should get relative path", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'data'
          ]
      ,
        data: 1
        ref: 1
    it "should get relative path with parent", ->
      test.deep
        type: 'object'
      ,
        data: 1
        sub:
          ref:
            REF: [
              source: 'struct'
              path: '<data'
            ]
      ,
        data: 1
        sub:
          ref: 1
    it "should get relative path with grandparent", ->
      test.deep
        type: 'object'
      ,
        data: 1
        group:
          sub:
            ref:
              REF: [
                source: 'struct'
                path: '<<data'
              ]
      ,
        data: 1
        group:
          sub:
            ref: 1
    it "should get sub element", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.sub.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using asterisk", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using double asterisk", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: '**.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1
    it "should get sub element using like syntax", ->
      test.deep
        type: 'object'
      ,
        group:
          sub:
            data: 1
        ref:
          REF: [
            source: 'struct'
            path: 'group.s*.data'
          ]
      ,
        group:
          sub:
            data: 1
        ref: 1

    it "should get ref->ref->value", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/data'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
    it "should get ref->ref->value (need for second loop)", ->
      test.deep
        type: 'object'
      ,
        data: 1
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/data'
          ]
      ,
        data: 1
        ref1: 1
        ref2: 1
    it "should fail on circular reference", ->
      test.fail
        type: 'object'
      ,
        ref1:
          REF: [
            source: 'struct'
            path: '/ref2'
          ]
        ref2:
          REF: [
            source: 'struct'
            path: '/ref1'
          ]

    #######################################################################################


  describe "description", ->

    it "should give simple description", ->
      test.desc
        type: 'reference'
    it "should give complete description", ->
      test.desc
        title: 'test'
        description: 'Some test rules'
        type: 'reference'

  describe "selfcheck", ->

    it "should validate simple options", ->
      test.selfcheck
        type: 'reference'
    it "should validate complete options", ->
      test.selfcheck
        title: 'test'
        description: 'Some test rules'
        type: 'reference'
