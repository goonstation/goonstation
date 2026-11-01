/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const RevheadContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a leader of the revolution!</h1>
      <p>
        1. Your goal is to kill all heads of staff on the station. They are:
      </p>
      <ul>
        <li>
          Captain, Head of Personnel, Head of Security,
          <br />
        </li>
        <li>
          Chief Engineer, Research Director, Medical Director
          <br />
        </li>
      </ul>
      <p>
        2. Avoid civilian casualties and convert other players to
        revolutionaries instead by using any flash on them. Heads of staff,
        synthetics and security personnel cannot be converted.
      </p>
      <p>
        A revolutionary uplink has been disguised as your PDA (or your headset
        if you lack a PDA). Check the &quot;notes&quot; verb in the Commands tab
        to see the uplink code then change your PDA&apos;s ring message to it.
      </p>
      <p>
        3. You cannot abandon your mission! Do not, under any circumstances,
        leave the station Z-Level. If you do, you will be treated as dead!
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Rev">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Revolutionary Head Goals',
  theme: 'syndicate',
  component: RevheadContentWindow,
};
