/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  content: (
    <div className="traitor-tips">
      <h1 className="center">You become a Harbinger of the Void!</h1>
      <p>1. Spawn your portal and take over the station with your horde</p>
      <p>2. Manifest physically as a revenant and crush the mortal weaklings</p>
      Abilities:
      <ul>
        <li>
          Create summoning portal: Creates a portal from which creatures of your
          choice will pour out. You get increased point generation near the
          portal.
        </li>
        <li>
          Raise skeleton: Turn a dead being&apos;s skeleton against the crew, or
          manifest a skeleton in a locker.
        </li>
        <li>
          Revenant: Attain full power and transform a corpse into a vessel of
          destruction! This drains your power quite quickly, so beware!
        </li>
        <li>
          Summon void creature: Request ghosts of players to summon a creature
          from the void to help you. The summoned player can pick between a
          skeleton general that buffs your creatures, a void hound to hunt
          sneakily, and a tentacled fiend that can displace people.
        </li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Harbinger">the wiki</a>
      </p>
    </div>
  ),
};
