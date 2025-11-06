/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const DerevContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are no longer a revolutionary!</h1>
      <p>
        1. You remembered your real allegiance and devotion to Nanotrasen!
        Protect the heads of staff and assist loyal crew members in putting down
        the revolution.
      </p>

      <p>
        2.{' '}
        <em>Don&apos;t help the revolutionary cause or any of its members!</em>{' '}
        They are now your enemies.
      </p>

      <p>
        3. Kill the leaders of the revolution. Converted crew members can be
        brainwashed by using a counter-revolutionary implant, electropack,
        electric chair or beating them in the head.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You've been freed from your brainwashing!",
  component: DerevContentWindow,
};
