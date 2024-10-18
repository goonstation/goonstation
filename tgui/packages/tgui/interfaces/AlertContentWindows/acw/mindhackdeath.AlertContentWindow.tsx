/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Mindhack Status Removed!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are no longer mindhacked!</h1>
      <p>
        Since you have died, you are no longer mindhacked or a vampire thrall!{' '}
        <em>Do not obey</em> your former mindhacker or vampire&apos;s orders
        even if you&apos;ve been brought back to life somehow.
      </p>
    </div>
  ),
};
