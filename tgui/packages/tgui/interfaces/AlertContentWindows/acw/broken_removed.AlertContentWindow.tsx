/**
 * @file
 * @copyright 2025
 * @author TobleroneSwordfish
 * @license MIT
 */

import { AlertContentWindow } from '../types';

const BrokenRemovedContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are no longer broken!</h1>
      <p>
        Your sanity returns, the shifting shapes in your mind resolve.{' '}
        <b>You are no longer an antagonist.</b>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'The madness receeds',
  component: BrokenRemovedContentWindow,
};
