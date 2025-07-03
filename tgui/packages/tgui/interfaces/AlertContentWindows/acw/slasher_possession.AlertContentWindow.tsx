/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const SlasherPossessionContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You have been temporarily possessed!</h1>
      <p>
        A being has temporarily taken over your body! However, it is temporary
        and you will regain control of your body shortly.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Possessed by the Slasher!',
  component: SlasherPossessionContentWindow,
};
