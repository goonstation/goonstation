/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const GangJoinContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a gang member!</h1>
      <img
        src={resource('images/antagTips/gangmember-image.png')}
        className="center"
      />

      <p>
        1. Work together with your gangster buddies to rack up as many points as
        you can!
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
          Collecting weapon drops and crates.
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
        2. Use the prefix :z to speak on your gang&apos;s radio frequency! Pay
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
        3.{' '}
        <em>
          Don&apos;t attack fellow gang members and listen to your leader!
        </em>{' '}
        You can identify them by the G icon. Blue is your leader, red are your
        fellow henchmen.
      </p>

      <p>
        4. Wear your gang outfit proudly! Gang members in enemy territory will
        get a debuff if they aren&apos;t wearing their gangs&apos; getup!
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
  title: "You've joined a Gang!",
  component: GangJoinContentWindow,
};
