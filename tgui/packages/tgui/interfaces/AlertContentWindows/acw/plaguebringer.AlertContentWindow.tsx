/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const PlaguebringerContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You become a Plaguebringer!</h1>
      <p>1. Spread disease using your abilities</p>
      <p>2. Beware the humble janitor</p>
      Abilities:
      <ul>
        <li>
          Curses: Applies debilitating status effects to crewmates that they can
          remove with holy water or bible beatings. Apply 4 basic curses to
          apply your final, deadly curse and reap the human&apos;s soul!
        </li>
        <li>
          Summon plague rat: Summons a highly invasive plagued rat that will try
          to reproduce throughout the station and spread disease.
        </li>
        <li>Defile: Poison a container or food item with nasty chemicals.</li>
        <li>
          Summon rot hulk: Accumulate all the filth in the area into a rot hulk,
          or a giant rot hulk if the area is dirty enough.
        </li>
        <li>Speak to summons: Send a message to all your plague rats.</li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Plaguebringer">
          the wiki
        </a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  component: PlaguebringerContentWindow,
};
