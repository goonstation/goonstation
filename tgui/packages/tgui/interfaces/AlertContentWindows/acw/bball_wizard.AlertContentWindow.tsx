/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { AlertContentWindow } from '../types';

const BasketballContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Basketball Wizard!</h1>

      <p>1. Pick your jams from the disguised baller uplink in your pocket.</p>

      <p>
        2. You cannot cast jams without sufficient bball power, make sure
        you&apos;re wearing your jersey and dribbling at least one basketball.
      </p>

      <p>3. BASKETBALL.</p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'BASKETBALL',
  component: BasketballContentWindow,
};
