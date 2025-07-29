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
        2. You cloak while in darkness when in your true form. Being in light
        for too long, or using most abilities, will reveal you. A visibility
        indicator next to you shows if you are visible or not.
      </p>
      <p>
        3. To start an attack, disguise with your Disguise ability. Use Brain
        Drain to start draining the brain of a person, which will award you with
        Intellect. If they try to run, use Paralyze to pull them towards you.
        When you reach 100 Intellect on them, use Pierce the Veil to send them
        to your realm.
      </p>
      <p>
        4. Brain Drain will cause brain damage, other types of damage, and drain
        chemicals from targets which replaces them with toxin.
      </p>
      <p>
        5. Stuns and flashes will disorient and stagger you. While in critter
        form, you take increased damage and are hurt by mousetraps.
      </p>
      <p>
        6. You can speak over Intruder chat with the radio hotkey, or prefixing
        your message with <em>:int</em>.
      </p>
      <p>7. Your goal is to just cause chaos. Have fun!</p>
      <p>This is a work in progress antag and will not be found on the wiki.</p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'MindeaterBasics',
  component: MindeaterContentWindow,
};
