/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a Souldorf!</h1>
      <img src={resource('images/antagTips/zoldorf.png')} className="center" />

      <p>
        As a Souldorf, you are the remnants of the past Zoldorf and the eyes and
        ears of the current Zoldorf.
      </p>

      <p>
        <b>PASSIVE EFFECTS:</b>
        <br />- You can hear dead chat.
        <br />- You may coat yourself in ectoplasm to reveal yourself to humans.
        <br />- You have access to a few fun emotes!
      </p>

      <p>
        <b>ACTIVE EFFECTS:</b>
        <br />
        You can change your color! Yay :D
      </p>

      <p>
        You may run the suicide command at any time to become a normal ghost.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Guide to Zoldorf">
          the wiki
        </a>
      </p>
    </div>
  ),
};
