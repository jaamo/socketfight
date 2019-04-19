import Phaser from 'phaser';
import {Socket} from 'phoenix';

/**
 * Root class for SocketFight game component.
 */
export default class SocketFight {
  /**
   * Configure and create the game.
   */
  constructor() {
    // Configurations.
    const config = {
      type: Phaser.AUTO,
      width: 1080,
      height: 720,
      physics: {
        default: 'arcade',
        arcade: {
          gravity: {y: 200},
        },
      },
      scene: {
        preload: this.preload,
        create: this.create,
      },
    };

    // Init game.
    this.game = new Phaser.Game(config);

    // Init inputs.
    document.addEventListener('keyup', e => this.onKeyPress(e));

    // Init socket.
    this.socket = new Socket('/socket', {params: {token: window.userToken}});
    this.socket.connect();
    this.channel = this.socket.channel('game:default', {});
    this.channel
      .join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp);
      })
      .receive('error', resp => {
        alert(
          'Server connection failed. Nothing will work. Rather than debugging please go out and do something meaningful.',
        );
        console.log('Unable to join', resp);
      });
    this.channel.on('new_msg', this.receiver);
  }

  /**
   * Define assets to be preloaded.
   */
  preload() {
    this.load.setBaseURL('/');
    this.load.image('map', 'images/map.jpg');
    this.load.image('tank', 'images/tank.png');
  }

  /**
   * Game initializer function called when all assets are loaded.
   */
  create() {
    this.add.image(540, 360, 'map');
    this.add.image(540, 360, 'tank');
  }

  /**
   * Receive data from backend.
   */
  receiver(payload) {
    console.log(payload);
  }

  /**
   * Handle keypress.
   */
  onKeyPress(e) {
    console.log(e.keyCode);
    switch (e.keyCode) {
      // w, up
      case 87:
        this.channel.push('event', {action: 'up'});
        break;
    }
  }
}
