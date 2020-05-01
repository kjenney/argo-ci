var express = require("express");
var exphbs  = require("express-handlebars");
var os = require("os");

var port = process.env.PORT || 8080;
var message = process.env.MESSAGE || "Hello August!";

var app = express();

app.engine("handlebars", exphbs());
app.set("view engine", "handlebars");

app.get("/", function(req, res) {
  res.render("home", {
    message: message,
    platform: os.type(),
    release: os.release(),
    hostname: os.hostname()
  });
});

// Set up listener
app.listen(port, function() {
  console.log("Listening on: http://%s:%s", os.hostname(), port);
});
