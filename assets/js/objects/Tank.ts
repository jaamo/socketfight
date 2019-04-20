import Phaser from 'phaser';

export default class SocketFight extends Phaser.GameObjects.Sprite {
  constructor(game, x, y, texture) {
    super(game, x, y, texture);
    //this.addChild(game.add.sprite(0, 0, 'someSprite'));
    //game.stage.addChild(this);
  }

  //update() {
  //move/rotate sprite
  //}
}
