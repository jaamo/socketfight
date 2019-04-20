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
import SocketFight from "./SocketFight.ts";
const config = {
  type: Phaser.AUTO,
  width: 1080,
  height: 720,
  physics: {
    default: "arcade",
    arcade: {
      gravity: { y: 200 }
    }
  },
  scene: SocketFight
};
//const socketFight = new SocketFight(config);
const game = new Phaser.Game(config);
