/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const GangLeaderContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a gang leader!</h1>
      <img
        src={resource('images/antagTips/gangmember-image.png')}
        className="center"
      />

      <p>
        1. Work together with your subordinates to rack up as many points as you
        can!
        <br />
        You can get points by:
      </p>
      <ul>
        <li>
          Claiming popular parts of the station with spray cans. Gang tags that
          see people generate points!
          <br />
        </li>
        <li>
          Collecting weapon drops and crates. Watch the radio to find out about
          tip-offs!
          <br />
        </li>
        <li>
          Cram large quantities of cash into your locker to launder it into
          points!
          <br />
        </li>
        <li>
          Finally, cram guns, drugs & weed into your locker for even more points
          to spend!
          <br />
        </li>
      </ul>

      <p>
        2. <b>Be prepared!</b> You have access to the leader-specific
        &apos;Street Cred&apos;:
      </p>
      <ul>
        <li>
          Street cred is earned the same as points, and spendable in the top
          right of the Locker.
        </li>
        <li>
          Revival syringes let you bring a dead gang member back to life; or let
          gang members bring you back to life!
        </li>
        <li>
          If there&apos;s no corpse to revive, you can buy a new gang member,
          who&apos;ll spawn at your locker in their place!
        </li>
      </ul>

      <p>
        3. Use the prefix :z to speak on your gang&apos;s radio frequency! Pay
        attention to it:
      </p>
      <ul>
        <li>
          Every so often, your gang will PDA message the location of a bag of
          weapons to a civilian! <br />
        </li>
        <li>
          You will only know which civilian recieved the message.{' '}
          <em>Ask them for it! Bribe them! Steal their PDA!</em>
          <br />
        </li>
        <li>
          Weapon crates will occasionally spawn, too. Drag these to your locker
          and open them for guns & ammo! <br />
        </li>
      </ul>

      <p>
        4. Wear your gang outfit proudly, and don&apos;t hide it under suits!
        Gang members in enemy territory will get a debuff if they aren&apos;t
        wearing their gangs&apos; getup.
      </p>

      <p>
        5. Remember, you&apos;re free to harm anyone who isn&apos;t in your
        gang, but they can do the same to you, so don&apos;t pick fights
        willy-nilly!
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Gang">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You've started a Gang!",
  component: GangLeaderContentWindow,
};
