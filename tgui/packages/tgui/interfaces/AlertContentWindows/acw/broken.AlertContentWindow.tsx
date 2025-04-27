/**
 * @file
 * @copyright 2025
 * @author TobleroneSwordfish
 * @license MIT
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Broken',
  theme: 'syndicate', // TODO: eldritch theme?
  content: (
    <div className="traitor-tips">
      <h1 className="center">
        You have been driven to madness by the immense psychic pressure of the
        unknowable minds drifting far above.
      </h1>
      {/* <img
        src={resource('images/antagTips/traitor-image.png')} // TODO: eldritch image
        className="center"
      /> */}

      <p>
        1. You are now <b>temporarily</b> an antagonist.
      </p>

      <p>
        2. This status will wear off on its own, you can see the duration at the
        top right of your screen.
      </p>

      <p>3. Check the chat window for your goal.</p>

      <p>
        4. All who have fallen to madness share the same goal, but there is no
        guarantee of cooperation.
      </p>

      {/* <p> //TODO: wiki
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Traitor">the wiki</a>
      </p> */}
    </div>
  ),
};
