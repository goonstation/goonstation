/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const GhostcritterContentWindow = () => {
  return (
    <div className="ghostcritter">
      <h1 className="center">You have been revived as a ghost critter!</h1>
      <img src={resource('images/ghostcritter.png')} className="center" />

      <p>
        You&apos;ve miraculously found another chance at life as an *annoying*
        insect.
      </p>

      <p>
        You should treat this as a new life. This means you shouldn&apos;t hold
        grudges from your previous one.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Ghost Critter Antagonist Tips!',
  component: GhostcritterContentWindow,
};
