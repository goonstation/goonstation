/**
 * @file
 * @copyright 2024
 * @author CalliopeSoups
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const DemonDollContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Demon Doll!</h1>
      <p>1. Run faster and heal within the dark!</p>
      <p>3. Torment the living using your abilities!</p>
      Important Abilities:
      <ul>
        <li>
          Bouncy Song: a projectile shot that doesn`&apos;`t do much damage. It
          will bounce off a wall once while in the light and more in the dark,
          with bonus bounces if you hit and break a light. Hit a shot after one
          bounce to knock victims over, hit one after two to lay a random trap!
        </li>
        <li>
          Gravity Song: a toggle-able ability that, while active, will toss a
          random thing you`&apos;`re juggling at a nearby human about every
          three seconds.
        </li>
        <li>
          Ouija Song: You cannot speak, instead you can use this ability to
          communicate by picking random words. This ability also comes with an
          option to call your wraith, which will ping them with your location.
        </li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Trickster">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  component: DemonDollContentWindow,
};
