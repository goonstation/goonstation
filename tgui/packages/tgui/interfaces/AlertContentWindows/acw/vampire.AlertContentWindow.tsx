/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Vampire Tips',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a vampire!</h1>
      <img
        src={resource('images/antagTips/vampire-image.png')}
        className="center"
      />

      <p>
        1. To drink blood, use the <em>Bite Victim</em> ability. Remove their
        headgear first.
        <br />
        You must remain still while draining blood.
      </p>

      <p>
        2. <em>Danger!</em> If you walk in space, starlight will burn you to a
        crisp.
        <br />
        The chaplain is your nemesis. Avoid him and the chapel.
      </p>

      <p className="cf image-right">
        3. New <em>powers</em> unlock when you collect a certain amount of blood
        (as indicated below). Every time you use a power that isn&apos;t free,
        it depletes part of your blood reserve.
        <br />
        <span className="small">
          <br />
          <br />
          <span style={{ float: 'left', width: '50%' }}>
            40 - <em>Bat Form</em>, consume stamina to morph into a bat.
            <br />
            40 - <em>Enthrall / Thrall Speak</em>, revive a dead human as an
            enthralled servant.
            <br />
            300 - <em>Coffin Escape / Mark Coffin</em>, escape to a coffin to
            regenerate.
            <br />
            300 - <em>Vampiric Vision</em>, thermals.
            <br />
            600 - <em>Frost Bats</em>, defensive spell.
            <br />
            600 - <em>Chiropteran Screech</em>, stun people, break glass.
            <br />
            900 - <em>Diseased Touch</em>, give someone grave fever.
            <br />
            900 - <em>Bat Form</em> cloaks in dark areas.
            <br />
          </span>
          <span style={{ float: 'left', width: '50%' }}>
            1400 - <em>Chiropteran Screech</em>, breaks nearby radios.
            <br />
            1800 - <em>Full power</em>, no harm from chapel.
            <br />
          </span>
        </span>
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Vampire">the wiki</a>
      </p>
    </div>
  ),
};
