/**
 * @file
 * @copyright 2024
 * @author FlameArrow57
 * @license ISC
 */
import { Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Space Phoenix Basics',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a Space Phoenix!</h1>
      <Image
        src={resource('images/antagTips/flockmind.gif')}
        className="center"
        width="64"
        height="64"
      />
      <p>1. ...</p>
      <p>2. ...</p>
      <p>3. ...</p>
      <p>4. ...</p>
      <p>5. ...</p>
      <p>6. ...</p>

      <p>
        For more information, please consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Flockmind">the wiki</a>
      </p>
    </div>
  ),
};
