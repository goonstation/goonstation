/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const SleeperagentContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a sleeper agent!</h1>
      <img
        src={resource('images/antagTips/traitor-image.png')}
        className="center"
      />

      <p>
        1. You remember your real allegiance. It is time to repay your debts to
        the Syndicate.
      </p>

      <p>
        2. Unfortunately, the Syndicate doesn&apos;t have the resources to equip
        you with an uplink. Good luck!
      </p>

      <p>
        3. There might be more sleeper agents among you. Carefully choose who
        you trust.{' '}
      </p>

      <p>
        4. Your objectives will always be stored in your notes. To access them,
        use the <em>Notes</em> verb.
      </p>

      <p>
        5. You now have access to the listening post through the usage of a hand
        scanning device near the door.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Traitor">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Sleeper Agent Tips',
  theme: 'syndicate',
  component: SleeperagentContentWindow,
};
