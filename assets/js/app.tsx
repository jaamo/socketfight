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
import SocketFight from "./scene/SocketFight.ts";
import GUI from "./gui/GUI.tsx";

window.gui = ReactDOM.render(<GUI />, document.getElementById("container"));
// component.setState({ players: [{ state: { health: 100 } }] });

// setTimeout(function() {
//   component.setState({ x: "StackOverFlow" });
// }, 1000);

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
