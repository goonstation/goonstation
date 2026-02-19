/**
 * @file
 * @copyright 2025
 * @author TobleroneSwordfish
 * @license MIT
 */
import { AlertContentWindow } from '../types';

const BrokenContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">
        You have been driven to madness by the immense psychic pressure of the
        unknowable minds drifting far above.
      </h1>

      <p>
        1. You are now <b>temporarily</b> an antagonist.
      </p>

      <p>
        2. You <b>must</b> attempt to pursue your shared goal in some way. You
        are <b>not</b> required to co-operate with anyone else, however.
      </p>

      <p>3. Check the chat window for your goal.</p>

      <p>
        4. This status will wear off on its own, you can see the duration at the
        top right of your screen.
      </p>

      <p>
        5. Any antagonistic actions you take <b>must</b> be in pursuit of your
        objective.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/Broken">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Broken',
  theme: 'syndicate', // TODO: eldritch theme?
  component: BrokenContentWindow,
};
