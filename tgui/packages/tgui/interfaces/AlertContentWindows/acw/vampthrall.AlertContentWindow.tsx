/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: "You've become the brainwashed thrall of a Vampire!",
  content: (
    <div className="traitor-tips">
      <h1 className="center">You have been revived as a thrall!</h1>
      <p>
        You feel an <em>unwavering loyalty</em> to your new master! (As such,{' '}
        <em>do not reveal their identity</em> or otherwise act against their
        best interests.)
      </p>
      <p>
        You <em>MUST</em> stay close to your master! Your new unlife is fragile
        and straying too far from their power will result in your swift demise.
      </p>
      <p>
        You will slowly lose blood points over time. Your max health will
        decrease as blood points are lost. You can regain blood points by
        drinking the blood of humans or taking an additional donation from your
        master.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Thrall">the wiki</a>
      </p>
    </div>
  ),
};
