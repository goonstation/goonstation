/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const ChangelingContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a changeling!</h1>
      <img
        src={resource('images/antagTips/changeling-image.png')}
        className="center"
      />

      <p>
        1. <em>Your goal</em> is to absorb the DNA of a certain amount of crew
        members. Use the <em>Notes</em> verb to view the exact amount.
      </p>

      <p>
        2. Changeling aliens have a number of <em>powers</em> to take down their
        victims and protect themselves.
        <br />
        Using some of the powers requires you to expend some <em>DNA points</em>
        .<br />
        To acquire more, you will have to absorb new victims. Any living victim
        that you absorb will be forced into your <em>hivemind</em>. You can
        telepathically speak to your hivemind using the <em>:hive</em> speech
        prefix.
        <span className="small indent">
          <em>Absorb DNA</em>, to steal the DNA of your victims. They must be
          grabbed firmly.
          <br />
          <em>Toxic Spit</em>, a homing projectile that instantly melts the
          victim&apos;s headgear.
          <br />
          <em>Hallucinogenic Sting</em>, a stealthy sting that makes people
          trip.
          <br />
          On the non-RP servers, <em>Neurotoxic Sting</em>, stealthily KOs your
          victims in about 30 seconds. Also causes severe brain damage.
          <br />
          On the RP servers, <em>Capulettium Sting</em>, which doesn&apos;t
          cause brain damage, but will make your victim appear dead while
          they&apos;re unconscious.
          <br />
          <em>DNA Sting</em>, forces somebody to assume the appearance and name
          of one of your victims.
          <br />
          <em>Lesser Form</em>, instantly transforms you into a monkey. Only
          some abilities are available while in this form. Use the command again
          to revert to a human body.
          <br />
          <em>Regenerative Stasis</em>, you will appear dead, and slowly return
          to full health. You won&apos;t be able to move while in stasis.
          <br />
          <em>Speed Regenerate</em>, heals you on the move and regrows limbs.
          Very obvious, will expose your alien nature to anyone nearby.
          <br />
          <em>Transform</em>, lets you transform into one of the identities you
          have absorbed.
          <br />
          <em>Mimic Voice</em>, to speak in the voice of other crew members.
          <br />
          <em>Handspider</em>, to transfer a consciousness from your hivemind
          into a weak scouting critter.
          <br />
          <em>Eyespider</em>, to transfer a consciousness from your hivemind
          into a weaker critter able to see everything.
          <br />
          <em>Morph Arm</em>, to temporarily replace one of your human arms with
          a stronger form.
          <br />
          <em>Horror Form</em>, you turn into a shambling abomination with a
          special set of abilities. See the{' '}
          <a href="https://wiki.ss13.co/Changeling#Shambling_Abomination">
            the wiki
          </a>
          .<br />
        </span>
        Changelings <em>don&apos;t need to breathe</em>, so they can enter space
        without a spacesuit or internals.
      </p>

      <p className="image-right">
        3. <em>To absorb a human&apos;s DNA:</em>
        <br />{' '}
        <img
          src={resource('images/antagTips/changeling-absorb-HUD.png')}
          className="right"
        />
        <span className="small indent">
          1. Set your intent to GRAB.
          <br />
          2. Click on your victim until you hold them in a grab.
          <br />
          3. Click on the grab button until it reads <b>KILL</b>.{' '}
          <em>Headgear will stop you, so make sure your victim has none.</em>
          <br />
          4. Now you can use the Absorb DNA command.
        </span>
      </p>

      <p className="small">
        If you are interrupted while absorbing a body, the process can be
        restarted once you return to safety.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Changeling">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Changeling Tips',
  component: ChangelingContentWindow,
};
