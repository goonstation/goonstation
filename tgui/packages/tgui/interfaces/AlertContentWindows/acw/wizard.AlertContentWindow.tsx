/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Wizarding Facts for beginning magical entities',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a Wizard!</h1>
      <img
        src={resource('images/antagTips/wizard-image.png')}
        className="center"
      />

      <p>
        1. As a wizard, you use a <em>variety of spells</em> to accomplish your
        objective.
      </p>

      <p>
        2. You start with clairvoyance, phase shift and magic missile for free.
        <br />
        <em>To learn new spells, use the spellbook on your belt.</em>
      </p>

      <p>
        3. For detailed information about each spell,
        <br />
        click the <em>question mark</em> in your spellbook.
        <img
          src={resource('images/antagTips/grimoire.png')}
          className="right"
        />
      </p>

      <p>
        4. To teleport back to the wizard shuttle,
        <br />
        use the <em>teleportation scroll</em> you start with in your pocket.
        <img
          src={resource('images/antagTips/teleportscroll.png')}
          className="right"
        />
      </p>

      <p>
        5. For beginner info and general tips,
        <br />
        examine the <em>Wizadry 101</em> paper you start with in your pocket.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Wizard">the wiki</a>
      </p>
    </div>
  ),
};
