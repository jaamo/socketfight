import Phaser from "phaser";
import { Socket } from "phoenix";
import Tank from "./objects/Tank.ts";

/**
 * Root class for SocketFight game component.
 */
export default class SocketFight extends Phaser.Scene {
  /**
   * Configure and create the game.
   */
  constructor(config) {
    super(config);

    // List of tanks.
    this.players = {};

    // Key states. Used to prevent repeating key events when
    // a button is hold down.
    this.state = { forward: false };

    // Map keys to events.
    this.keyMap = {
      "87": "forward",
      "65": "left",
      "68": "right",
      "83": "brake",
      "75": "shoot"
    };

    // Init inputs.
    document.addEventListener("keydown", e => this.onKeyDown(e));
    document.addEventListener("keyup", e => this.onKeyUp(e));

    // Init socket.
    this.socket = new Socket("/socket", {
      params: { token: window.userToken }
    });
    this.socket.connect();
    this.channel = this.socket.channel("game:default", {});
    this.channel
      .join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp);
      })
      .receive("error", resp => {
        alert(
          "Server connection failed. Nothing will work. Rather than debugging please go out and do something meaningful."
        );
        console.log("Unable to join", resp);
      });
  }

  /**
   * Define assets to be preloaded.
   */
  preload() {
    this.load.setBaseURL("/");
    this.load.image("map", "images/map.jpg");
    this.load.image("tank", "images/tank.png");
  }

  /**
   * Game initializer function called when all assets are loaded.
   */
  create() {
    // Add map.
    this.add.image(540, 360, "map");

    // Start listening socket messages.
    this.channel.on("player:update", payload => this.receiver(payload));
    this.channel.on("player:join", payload => this.joinGameHandler(payload));
  }

  joinGameHandler(payload) {
    console.log(payload);
    const obstacles = this.add.graphics();
    if (payload.obstacles) {
      for (const obstacle of payload.obstacles) {
        obstacles.lineStyle(2, 0xff0000, 1.0);
        obstacles.beginPath();
        obstacles.moveTo(obstacle.a.x, obstacle.a.y);
        obstacles.lineTo(obstacle.b.x, obstacle.b.y);
        obstacles.closePath();
        obstacles.strokePath();
      }
    }
  }

  update() {}

  /**
   * Receive data from backend. Create new tanks, remove tanks and update tanks.
   */
  receiver(payload) {
    //console.log(payload);
    if (!payload.players) {
      return;
    }

    Object.values(payload.players).forEach(player => {
      // Player exists, update
      if (typeof this.players[player.id] != "undefined") {
        // Handle movement.
        this.players[player.id].setPosition(player.state.x, player.state.y);
        this.players[player.id].setRotation(player.state.rotation);

        // Handle shooting.
        if (player.state.shot) {
          console.log("SHOT!", player);
          const obstacles = this.add.graphics();
          obstacles.lineStyle(2, 0x000000, 1.0);
          obstacles.beginPath();
          obstacles.moveTo(player.state.x, player.state.y);
          obstacles.lineTo(
            player.state.shootTargetX,
            player.state.shootTargetY
          );
          obstacles.closePath();
          obstacles.strokePath();
          setTimeout(() => {
            obstacles.destroy();
          }, 100);
        }
      }
      // Player does not exist, create new.
      else {
        console.log("New tank: " + player.id);
        const tank = new Tank(this, player.state.x, player.state.y, "tank");
        tank.setRotation(player.state.rotation);
        this.players[player.id] = tank;
        this.add.existing(tank);
      }
    });
  }

  /**
   * Handle key down.
   */
  onKeyDown(e) {
    console.log(e.keyCode);
    if (typeof this.keyMap[e.keyCode] != "undefined") {
      const action = this.keyMap[e.keyCode];
      if (!this.state[action]) {
        this.state[action] = true;
        this.channel.push("event", { action: action, state: true });
      }
    }
  }

  /**
   * Handle key up
   */
  onKeyUp(e) {
    if (typeof this.keyMap[e.keyCode] != "undefined") {
      const action = this.keyMap[e.keyCode];
      if (this.state[action]) {
        this.state[action] = false;
        this.channel.push("event", { action: action, state: false });
      }
    }
  }
}
