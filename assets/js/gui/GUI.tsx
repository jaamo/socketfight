import React, { Component } from "react";
import ReactDOM from "react-dom";

interface GUIProps {}
interface GUIState {
  x: number;
}

export default class GUI extends React.Component<GUIProps, GUIState> {
  render() {
    if (!this.state || !this.state.players) return null;

    const players = [];
    Object.values(this.state.players).forEach((player, i) => {
      players.push(
        <div>
          Player {i}, health: {player.state.health}, kills: {player.state.kills}
          , deaths: {player.state.deaths}
        </div>
      );
    });

    return <div>{players}</div>;
  }
}
