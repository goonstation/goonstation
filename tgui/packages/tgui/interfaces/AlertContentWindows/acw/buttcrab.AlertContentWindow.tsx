/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Buttcrab Expectations',
  content: (
    <div className="traitor-tips">
      <h1 className="center">
        You have reawakened to serve your host changeling!
      </h1>
      <p>
        You must <em>obey</em> their commands!
        <br />
        You are a very small, very smelly, and weak creature. You are still
        connected to the hivemind.
      </p>
      <p>
        Abilities
        <span className="small indent">
          <em>Fart</em> out a cloud of toxic gas.
          <br />
          <em>Fartonium sting</em> a human to force them to fart.
          <br />
          <em>Anti-fart sting</em> a human to prevent them from farting.
          <br />
        </span>
      </p>
    </div>
  ),
};
