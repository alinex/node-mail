chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

config = require 'alinex-config'
stubTransport = require 'nodemailer-stub-transport'
handlebars = require 'handlebars'

mail = require '../../src/index'

fs = require 'fs'
svg = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
<path d="M50,3l12,36h38l-30,22l11,36l-31-21l-31,21l11-36l-30-22h38z"
fill="#FF0" stroke="#FC0" stroke-width="2"/>
</svg>"""

describe.only "SVG", ->

  it "should convert to png", (cb) ->
    @timeout 20000
    # convert to javascript
    webshot = require 'webshot'
    webshot svg,
      siteType: 'html'
      streamType: 'png'
      creenSize:
        width: 800
        height: 600
      renderDelay: 100
    , (err, stream) ->
      buffer = ''
      return cb err if err
      stream.on 'data', (data) -> buffer += data.toString 'binary'
      stream.on 'end', ->
        image = new Buffer(buffer, 'binary').toString 'base64'
        console.log """<p><img src="data:application/octet-stream;base64,#{image}"></p>"""
        fs.writeFileSync "example.html", """<html><body><p><img src="data:application/octet-stream;base64,#{image}"></p></body></html>"""
        cb null
