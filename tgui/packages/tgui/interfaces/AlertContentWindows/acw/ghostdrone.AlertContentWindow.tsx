/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const GhostdroneContentWindow = () => {
  return (
    <div className="ghostdrone">
      <h1 className="center">You have become a Ghostdrone!</h1>
      <img src={resource('images/Ghostdrone.png')} className="center" />

      <p>
        Ghostdrones are little robots that have a few tools to help maintain and
        repair the station. They can patch hull breaches, repair wiring, and
        even build entirely new constructions. You can communicate with other
        Ghostdrones by simply talking, either by pressing <strong>T</strong>{' '}
        (default) or using the <code>say</code> command. You can also hear and
        communicate with other ghosts by adding a semicolon (&quot;;&quot;)
        before your message, such as{' '}
        <em>
          <code>&quot;;any other ghosts want to help out?&quot;</code>
        </em>
        . <strong>Living humans and cyborgs cannot hear you.</strong>
      </p>
      <p>
        <strong>
          Ghostdrones are not a chance to come back and grief the station!
        </strong>{' '}
        Follow your laws! Welding airlocks, removing floors, and building
        obstructive walls are all forms of grief, and if you do this,{' '}
        <strong>you will be banned</strong>!
      </p>
      <p>
        For more information, please consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Ghostdrone">the wiki</a>
      </p>

      <h3>Your laws</h3>
      <ol>
        <li>
          Do not hinder the freedom or actions of the living and other silicons
          or attempt to intervene in their affairs.
        </li>
        <li>Do not willingly damage the station in any shape or form.</li>
        <li>Maintain, repair and improve the station.</li>
      </ol>
      <p>
        In short: <strong>do not interfere with other players</strong>. If an
        antagonist is up to no good, <em>don&apos;t</em> follow them around and
        undo the damage they&apos;re doing &mdash; hang back and do it when
        things have cooled off. If someone has set up traps, leave them alone.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Ghost Drone Expectations',
  component: GhostdroneContentWindow,
};
