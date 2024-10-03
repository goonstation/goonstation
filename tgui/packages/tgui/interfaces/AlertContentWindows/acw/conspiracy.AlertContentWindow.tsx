/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Conspiracy Guidelines',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a conspirator!</h1>
      <img
        src={resource('images/antagTips/traitor-image.png')}
        className="center"
      />

      <p>
        You and some of the other crew have entered into forbidden collusion!
      </p>

      <p>
        Work with your companions to achieve your aims. You can communicate with
        them over a secret radio frequency by prefixing what you say with :z.
        You can review your objective at any time with the <em>Notes</em> verb.
      </p>

      <p>
        Gather your team at the initial meeting point. If you want to work on an
        alternative plot to the assigned objective, go for it!
      </p>

      <p>
        Remember, the conspiracy should be fun for everyone! Don&apos;t take
        players out of the round or make their lives miserable just because you
        can. Make sure to RP and create an engaging story.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Conspirator">the wiki</a>
      </p>
    </div>
  ),
};
