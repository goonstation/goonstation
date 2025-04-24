/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Leaving the Hivemind',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are no longer a member of the hivemind!</h1>
      <p>
        Through death, rebirth or the will of your former master, you are free
        of the changeling hivemind.
      </p>
    </div>
  ),
};
