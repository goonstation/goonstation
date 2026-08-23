/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const VampireContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">
        You are a <em>vampire</em>!
      </h1>
      <img
        src={resource('images/antagTips/vampire-image.png')}
        className="center"
      />

      <ol>
        <li>
          You are empowered by the blood of humans!
          <ul>
            <li>
              Drink blood with <em>Bite Victim</em>. Remove headgear first.
            </li>
            <li>
              Use <em>Blood Steal</em> to slowly drink blood from range.
            </li>
            <li>You must remain still while draining blood.</li>
          </ul>
        </li>
        <li>
          <em>Danger!</em> Your undead form has natural weaknesses.
          <ul>
            <li>Direct starlight will burn you to a crisp.</li>
            <li>Avoid the chaplain and the chapel.</li>
          </ul>
        </li>
        <li>
          New <em>powers</em> unlock at certain amounts of total blood gained.
          <br />
          The list of powers is below. Some powers deplete your reserve.
        </li>
      </ol>

      <div
        className="small"
        style={{ columnCount: 2, columnGap: '10px', columnWidth: '50%' }}
      >
        0 - <em>Cancel Stuns</em>, recover from stuns but take damage.
        <br />0 - <em>Glare</em>, an instant, short-lasting stun.
        <br />0 - <em>Hypnotize</em>, knock out a target after focusing for a
        few seconds.
        <br />0 - <em>Illusory Shroud</em>, prevents you from being seen
        directly in dim lighting.
        <br />5 - <em>Bat Form</em>, consume stamina to morph into a bat.
        <br />
        150 - <em>Enthrall</em>, revive a dead human as an enthralled servant.
        Telepathically speak to your thralls using the&nbsp;
        <em>:thrall</em> speech prefix.
        <br />
        150 - <em>Spirit Bats</em>, minor defensive spell.
        <br />
        300 - <em>Coffin Escape / Mark Coffin</em>, escape to a coffin to
        regenerate.
        <br />
        300 - <em>Vampiric Vision</em>, thermal sight.
        <br />
        600 - <em>Frost Bats</em>, upgraded defensive spell.
        <br />
        600 - <em>Chiropteran Screech</em>, stun people, break glass.
        <br />
        900 - <em>Diseased Touch</em>, give someone grave fever.
        <br />
        900 - <em>Bat Form</em> cloaks in dark areas.
        <br />
        1400 - <em>Chiropteran Screech</em> breaks nearby radios.
        <br />
        1800 - <em>Full power</em>, no harm from chapel.
        <br />
      </div>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Vampire">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Vampire Tips',
  component: VampireContentWindow,
};
