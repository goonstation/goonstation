/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Wizarding Theory for advanced practitioners',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a wizard!</h1>
      <img src="/wizard-image.png" className="center" />

      <p>
        1. Use the <em>Call Wizards</em> verb in a secure place to retrieve your
        items.
      </p>

      <p>
        2. Your objectives will always be stored in your notes. To access them,
        use the <em>Notes</em> verb.
        <br />
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Wizard">the wiki</a>
      </p>
    </div>
  ),
};
