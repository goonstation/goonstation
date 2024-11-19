/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: "You've been polymorphed!",
  content: (
    <div className="traitor-tips">
      <h1 className="center">You have been polymorphed!</h1>

      <p>
        A wizard has polymorphed you into another form! The spell will wear off
        in <b>eight minutes</b> and return your previous body.
      </p>

      <p>
        You are reduced in your capacity but you can still fight the wizard!
        However, <b>you should not randomly attack the crew</b> unless you were
        somehow already an antagonist. If the crew thinks you&apos;re a regular
        critter, talk to them first!
      </p>
    </div>
  ),
};
