/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const SpyThiefContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Spy!</h1>
      <img
        src={resource('images/antagTips/spy-image.png')}
        className="center"
      />

      <p>
        1. <em>Your mission</em> is to complete the objectives assigned to you.
        <br />
        To assist in this task, you may collect wanted items around the station
        and ship them off in exchange for equipment.
      </p>

      <p>
        2. To unlock a <em>PDA</em>:<br />
        <span className="small indent">
          1. Put your PDA in an empty hand and click on it.
          <br />
          2. Under &apos;General Functions&apos;, select &apos;Messenger&apos;.
          <br />
          3. Click &apos;Set Ring Message&apos;.
          <br />
          4. Enter the password.
        </span>
      </p>

      <p>
        3. You have been provided with a special <em>spy camera</em> that
        functions as a secret flash. Don&apos;t lose it!
        <br />
        Use it in hand to change it between photo mode and flash mode.
      </p>

      <p>
        4. Try to collect bounties before the other spies do.{' '}
        <em>Use stealth.</em> Keep your identity as a spy hidden from other
        players and security.
        <br />
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Spy Thief">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Spy Thief Tips',
  component: SpyThiefContentWindow,
};
