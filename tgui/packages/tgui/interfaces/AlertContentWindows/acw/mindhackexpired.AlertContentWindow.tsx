/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const MindhackExpiredContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are no longer mindhacked!</h1>
      <p>
        Your mind is your own again! You <em>no longer</em> feel the need to
        obey your former mindhacker&apos;s orders.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Mindhack Implant Expired!',
  component: MindhackExpiredContentWindow,
};
