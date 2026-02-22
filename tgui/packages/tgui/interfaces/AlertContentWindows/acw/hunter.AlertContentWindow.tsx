/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const HunterContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a hunter!</h1>

      <p>
        1. Use the <em>Order Hunting Gear</em> ability in a secure place to
        retrieve your items. Your objectives will always be stored in your
        notes. To access them, use the <em>Notes</em> verb.
      </p>

      <p>
        2. You are a hunter of dangerous game. Use your gear to hunt down the
        crew:
        <span className="small">
          <br />
          <br />
          <em>Mask</em> with built-in thermal vision and voice changer.
          <br />
          <em>Cloaking Device</em>, makes you invisible.
          <br />
          <em>Laser Rifle</em>, self-charging.
          <br />
          <em>Spear</em>, can be thrown for an instant stun.
          <br />
          <em>Rubberized Shoes</em>, preventing you from slipping on blood and
          gibs.
          <br />
        </span>
      </p>

      <p>
        3. Take skulls with the <em>Take Trophy</em> command to impress your
        hunter comrades! The ability works on corpses as well as severed heads.
        Store the trophies in your belt, backpack or backpack box.
      </p>

      <p>
        4. Skulls of worthy foes are more valuable; examine them to see exactly
        how much they&apos;re worth. You can view your overall progress with the{' '}
        <em>Check Trophy Value</em> command.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Predator">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Basic Prey Hunting',
  component: HunterContentWindow,
};
