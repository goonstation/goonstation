/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const GenericAntagContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are an antagonist!</h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />

      <p>
        1. The rules on griefing and murdering no longer apply to you. Use your
        abilities as you see fit.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Antagonist">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Antagonist Tips',
  theme: 'syndicate',
  component: GenericAntagContentWindow,
};
