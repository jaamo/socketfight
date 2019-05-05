import React, { Component } from "react";
import ReactDOM from "react-dom";

// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
//import initSocket from './socket.ts';

// Import main game class.
import SocketFight from "./SocketFight.ts";

class Hello extends React.Component {
  render() {
    if (!this.state) return null;
    return <div>Hello {this.state.name}</div>;
  }
}

// var Hello = React.createClass({
//   render: function() {
//     if (!this.state) return null;
//     return <div>Hello {this.state.name}</div>;
//   }
// });

var component = ReactDOM.render(
  <Hello />,
  document.getElementById("container")
);
component.setState({ name: "World" });

setTimeout(function() {
  component.setState({ name: "StackOverFlow" });
}, 1000);

// Configure Phaser game engine.
const config = {
  type: Phaser.AUTO,
  width: 1080,
  height: 720,
  parent: "game",
  physics: {
    default: "arcade",
    arcade: {
      gravity: { y: 200 }
    }
  },
  scene: SocketFight
};
const game = new Phaser.Game(config);
