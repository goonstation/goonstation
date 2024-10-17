/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: "You've been mindhacked!",
  content: (
    <div className="traitor-tips">
      <h1 className="center">You have been mindhacked!</h1>
      <p>
        You feel an <em>unwavering loyalty</em> to your mindhacker! You feel you
        must <em>obey</em> their every order! <em>Do not tell anyone</em> about
        this unless they tell you to!
      </p>
    </div>
  ),
};
