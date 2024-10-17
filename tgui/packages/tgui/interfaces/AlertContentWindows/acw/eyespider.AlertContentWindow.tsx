/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Eyespider Expectations',
  content: (
    <div className="traitor-tips">
      <h1 className="center">
        You have reawakened to serve your host changeling!
      </h1>
      <p>
        You must <em>obey</em> their commands!
        <br />
        You are a very small and weak creature that can fit into tight spaces,
        and see through walls. You cannot fight, and should run from combat. You
        are still connected to the hivemind.
      </p>
      <p>
        Abilities
        <span className="small indent">
          <em>Passive X-Ray Vision</em> allows you to see through walls and hunt
          down targets for the collective.
          <br />
          <em>Blood Boil</em> to generate intense heat using all of your
          remaining energy and explode, scalding nearby targets. <br />
          <em>Shed Tears</em> to drop enough fluid to form a slick puddle,
          slipping people that cross over it. <br />
          <em>Mark</em> a potential target to be always know where they are,
          although you can only mark one individual at a time and marks expire
          after some time. <br />
          <em>Your master can return you</em> by grabbing you. This will remove
          your mark from your target and restore their eyes if they&apos;re
          missing any. <br />
        </span>
      </p>
    </div>
  ),
};
