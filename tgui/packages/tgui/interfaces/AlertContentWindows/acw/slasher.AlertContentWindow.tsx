/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const SlasherContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are the Slasher!</h1>

      <p>
        1. You are an incorporeal being that drifted to the station!
        <br />
        You have no objective, but to kill.
      </p>

      <p>
        2. You can summon your special Machete with the &quot;Summon
        Machete&quot; ability in the top left corner. Don&apos;t worry, it
        can&apos;t be stolen!.
        <br />
        Additionally, its damage increases by 2.5 for every soul you steal using
        the &quot;Soul Steal&quot; ability!
      </p>

      <p>
        3. For more information on your abilities, hit the button in the bottom
        right corner, then click on any of your abilities.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=The Slasher">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You've been made a Slasher!",
  component: SlasherContentWindow,
};
