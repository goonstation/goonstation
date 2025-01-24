/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Battle Royale Tips!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">Its a Battle Royale!</h1>

      <p>
        1. <em>Your goal</em> is to defeat all other battlers and be the last
        one standing!
      </p>
      <p>
        2. If it is the start of the round you are on the{' '}
        <em>BATTLE SHUTTLE</em>! Jump out of the <em>BATTLE SHUTTLE</em> to land
        somewhere on the station!
      </p>
      <p>
        3. Useful things have been placed around the station. Rummage around in
        lockers and chests to see what you can find!
      </p>
      <p>
        4. Deadly <em>Battle Storms</em> occasionally ravage the station. Get to
        the listed areas or perish in the fire!
      </p>
      <p>
        5. Supply drops regularly occur in random areas. Find the airdropped
        lootcrates for random items with special stats to help you win.
      </p>
      <p>
        6. Stay on the station or take constant battle damage for cowardice!
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Battler">the wiki</a>
      </p>
    </div>
  ),
};
