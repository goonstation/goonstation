/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const FlocktraceContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Flocktrace!</h1>
      <Image
        src={resource('images/antagTips/flocktrace.gif')}
        className="center"
        width="64"
        height="64"
      />
      <p>
        1. Assist your <em>Flockmind</em> in converting the station and
        constructing the <em>relay</em>.
      </p>
      <p>2. Click drag yourself onto any Flockdrone to take control of it.</p>
      <p>
        3. You can speak freely to other sentient aspects of the flock, however{' '}
        <em>your communication may be partially overheard by silicons.</em>
      </p>

      <p>
        For more information, please consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Flocktrace">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Flocktrace tips',
  theme: 'flock',
  component: FlocktraceContentWindow,
};
