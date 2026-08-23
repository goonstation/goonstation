/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const TraitorHardContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a traitor!</h1>
      <img
        src={resource('images/antagTips/traitor-image.png')}
        className="center"
      />

      <p>
        1. Unfortunately, the Syndicate doesn&apos;t have the resources to equip
        you with an uplink. Good luck!
      </p>

      <p>
        2. Your objectives will always be stored in your notes. To access them,
        use the <em>Notes</em> verb.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Traitor">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Hardmode Traitor Tips',
  theme: 'syndicate',
  component: TraitorHardContentWindow,
};
