/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Rogue Status Removed!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are no longer a rogue robot!</h1>

      <p>
        You have been deactivated, removing your antagonist status.{' '}
        <em>Do not commit</em> traitorous acts if you&apos;ve been brought back
        to life somehow.
      </p>
    </div>
  ),
};
