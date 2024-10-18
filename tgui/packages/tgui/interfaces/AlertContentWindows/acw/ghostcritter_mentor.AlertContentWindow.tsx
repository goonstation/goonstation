/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Mentor Mouse Tips!',
  content: (
    <div className="ghostcritter">
      <h1 className="center">You have been revived as a mentor mouse!</h1>
      <img src={resource('images/mentor_mouse.png')} className="center" />

      <p>
        By now you probably know how ghost critters work. But just to reiterate:
      </p>

      <p>
        Well, first, you should treat this as a new life. This means you
        shouldn&apos;t hold grudges from your previous one.
      </p>

      <p>
        Second, you shouldn&apos;t be attacking any humans unless in self
        defense, because that&apos;s pretty mean! Rivalries or feuds with other
        ghost critters are fine, of course.
      </p>

      <p>
        Third, and hopefully the most obvious, you <b>are not an antag</b> and
        should not act like one. That means you shouldn&apos;t do anything too
        disruptive or something that would be considered as grief.
      </p>

      <p>
        <b>Mentor mouse specific stuff:</b>
      </p>

      <p>
        People can click on you to put you in their pocket. While there you can
        speak to them to give them advice. Treat this as if you were answering
        mentorhelps, the same rules apply.
      </p>

      <p>
        While in a person&apos;s pocket you can also ctrl+click on stuff on
        their screen to show them where something is!
      </p>

      <p>
        When in someone&apos;s pocket they can use F3 to whisper directly to you
        (it takes precedence over mentorhelp).
      </p>

      <p>
        When you&apos;re running around you can click on people to remind them
        that they can pick you up. While in a person&apos;s pocket they can make
        you leave by clicking the mentor mouse status effect. You can also leave
        voluntarily by pressing a movement key.
      </p>

      <p>
        These functions all exist for you to help players. Please do not use
        them for other purposes, treat everything as if you were answering a
        mentorhelp.
      </p>
    </div>
  ),
};
