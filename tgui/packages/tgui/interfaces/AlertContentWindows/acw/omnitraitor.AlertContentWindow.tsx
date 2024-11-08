/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Omni-Traitor Tips',
  theme: 'syndicate',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are an omnitraitor!</h1>

      <p>
        1. You are pretty much every antagonist type rolled into one! Go nuts!
      </p>

      <p>
        2. Your objectives will always be stored in your notes. To access them,
        use the <em>Notes</em> verb.
      </p>
    </div>
  ),
};
