/**
 * @file
 * @copyright 2024
 * @author CalliopeSoups
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const SyndicateMonkeyContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a syndicate monkey agent!</h1>
      <img
        src={resource('images/antagTips/monkey-image.png')}
        className="center"
      />

      <p>
        1. The rules on griefing and murdering no longer apply to you. Use your
        abilities as you see fit.
      </p>
      <p> 2. Any escalation rules still apply.</p>
      <p>
        3. You do not speak human, find other ways to communicate or get a
        translator from medbay.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Antagonist">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Syndicate Monkey Tips',
  theme: 'syndicate',
  component: SyndicateMonkeyContentWindow,
};
