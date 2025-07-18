/**
 * @file
 * @copyright 2025
 * @author FlameArrow57
 * @license ISC
 */
import { Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const MindeaterContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Mindeater!</h1>
      <Image
        src={resource('images/antagTips/intruder.gif')}
        className="center"
        width="64"
        height="64"
      />
      <p>
        1. You start off intangible and can choose to become tangible once at a
        location you pick. You get 3 lives, and will revert to an intangible
        state upon death.
      </p>
      <p>
        2. Your goal is to gain Intellect from crew members! Use your ability
        Brain Drain to do so, which will award you with Intellect. Stealth and
        your Disguise ability will help you.
      </p>
      <p>
        3. You cloak while in darkness. Being in light for too long, attacking,
        or using most abilities will reveal you. A visibility indicator next to
        you shows if you are visible or not.
      </p>
      <p>
        4. Your basic attack is a ranged attack that drains chemicals from those
        hit, replacing them with toxins.
      </p>
      <p>
        5. Start attacks by sneakily using Brain Drain on crew members. Stay in
        range while they become aware of you, and finish off the attack by using
        Pierce the Veil on the target.
      </p>
      <p>
        6. You can speak over Intruder chat with the radio hotkey, or prefixing
        your message with <em>:int</em>.
      </p>
      <p>This is a work in progress antag and will not be found on the wiki.</p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'MindeaterBasics',
  component: MindeaterContentWindow,
};
