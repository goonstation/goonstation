/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: "You've been converted to the Revolution!",
  theme: 'syndicate',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are now a revolutionary!</h1>
      <p>
        1. Work together with your comrades to kill the heads of staff. They
        are:
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
        2. <em>Don&apos;t attack fellow freedom fighters!</em> You can identify
        them by the R icon. Blue is a leader, red is a converted crew member.{' '}
        <em>Adminhelp</em> if one of the revolutionaries violates this.
      </p>

      <p>
        3. Avoid civilian casualties; the revolution requires manpower. Get your
        leaders to convert them instead.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Rev">the wiki</a>
      </p>
    </div>
  ),
};
