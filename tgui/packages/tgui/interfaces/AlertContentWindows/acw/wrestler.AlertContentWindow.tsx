/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'How to be a Champion!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a wrestler!</h1>

      <p>
        1. You have access to a couple of wrestling moves:
        <span className="small">
          <br />
          <br />
          <em>Kick</em> people away from you. [1]
          <br />
          <em>Strike</em> to briefly stuns a nearby person. [1]
          <br />
          <em>Drop</em> onto a prone opponent. [1]
          <br />
          <em>Throw</em> somebody across the room.
          <br />
          <em>Slam</em> somebody into the floor.
          <br />
          Use the <em>*flip emote</em> to jump onto tables.
          <br />
          Grab people firmly and <em>*flip</em> to deal extra damage.
          <br />
          Climb onto chairs and <em>*flip</em> to jump into people.
          <br />
          <em>Punching</em> somebody also has a chance of sending them flying.
          <br />
        </span>
      </p>

      <p>
        2. All moves <em>marked with [1]</em> require manual target selection if
        there&apos;s more than one person adjacent to you.
      </p>

      <p>
        3. Also keep in mind that <em>Slam and Throw</em> actions require a
        tight grip on someone, and that <em>Drop</em> can only target prone
        opponents.
      </p>

      <p>
        4. You can reduce the cooldown of the moves with coffee, sugar, meth or
        other stimulants in your bloodstream.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Wrestler">the wiki</a>
      </p>
    </div>
  ),
};
