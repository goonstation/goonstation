/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const FlockmindContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a Flockmind!</h1>
      <Image
        src={resource('images/antagTips/flockmind.gif')}
        className="center"
        width="64"
        height="64"
      />
      <p>
        1. Command the army of Flockdrones that make up your collective
        consciousness.
      </p>
      <p>2. Click drag yourself onto any Flockdrone to take control of it.</p>
      <p>
        3. You can speak freely to other sentient aspects of the flock, however{' '}
        <em>your communication may be partially overheard by silicons.</em>
      </p>
      <p>
        4. Gain <em>compute</em> power by replicating drones, constructing
        collectors, and converting human computers.
      </p>
      <p>
        5. Partition your consciousness to summon <em>Flocktraces</em> to assist
        you, each requiring 100 compute.
      </p>
      <p>
        6. <em>Your ultimate goal</em> is to reach <em>500</em> total compute
        and construct the <em>relay</em> to transmit your consciousness.
      </p>

      <p>
        For more information, please consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Flockmind">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Flockmind Basics',
  theme: 'flock',
  component: FlockmindContentWindow,
};
