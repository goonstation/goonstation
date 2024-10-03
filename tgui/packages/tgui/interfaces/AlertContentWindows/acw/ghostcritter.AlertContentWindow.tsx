/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Ghost Critter Expectations',
  content: (
    <div className="ghostcritter">
      <h1 className="center">You have been revived as a ghost critter!</h1>
      <img src={resource('images/ghostcritter.png')} className="center" />

      <p>
        You&apos;ve miraculously found another chance at life. What do you do?
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
    </div>
  ),
};
