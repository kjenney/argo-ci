var assert = require("assert");
var http = require("http");
const JSDOM = require("jsdom").JSDOM;

var port = 8080;
var message = "Hello World Testing!";
process.env.PORT = port;
process.env.MESSAGE = message;

var server = require("../server.js");

describe("home", function() {
  it("should return 200", function(done) {
    http.get("http://localhost:" + port, function(res) {
      assert.equal(200, res.statusCode);
      done();
    });
  });

  it("should say " + message, function(done) {
    JSDOM.fromURL("http://localhost:" + port, {}).then(dom => {
      assert.equal(message, dom.window.document.querySelector("h1").textContent);
      done();
    });
  });
});
