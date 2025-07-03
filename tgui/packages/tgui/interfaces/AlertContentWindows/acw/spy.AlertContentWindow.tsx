/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const SpyContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Spy!</h1>
      <img
        src={resource('images/antagTips/spy-image.png')}
        className="center"
      />

      <p>
        1. <em>Your mission</em> is to identify and kill the other spies on the
        station.
        <br />
        You must be the only spy to escape on the shuttle.
      </p>

      <p>
        2. You have 4 implants to <em>mindhack other players</em> in the starter
        kit in your backpack, along with other gear. Use them to carry out your
        purpose.
      </p>

      <p>
        3. <em>Use stealth.</em> Keep your identity as a spy hidden from other
        players and security.
        <br />
        Get help from your mindhacks for the most dangerous tasks.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'How to Spy 101',
  component: SpyContentWindow,
};
