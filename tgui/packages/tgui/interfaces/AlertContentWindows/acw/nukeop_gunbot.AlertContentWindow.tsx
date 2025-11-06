/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const NukeGunbotContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a loyal Syndicate gunbot!</h1>
      <img
        src={resource('images/antagTips/nukeop-gunbot.png')}
        className="center"
      />

      <p className="image-right">
        1. As a gunbot, you have two primary weapons and a radio available to
        you.
        <br />
        <span className="small">
          First, you have a semi-automatic <em>rifle</em>. It is capable of
          doing 45 damage per shot, and can fire 5 times prior to a 20 second
          reloading period.
          <br />
          Secondly, you also have a riot-suppression <em>shotgun</em>, firing up
          to 6 rubber slugs before a 30 second reloading time.
          <br />
          Finally, you have a radio tuned to the <em>Syndicate Frequency</em>,
          talk and listen to your fellow operatives with a message prefix of{' '}
          <em>:z</em>.
        </span>
      </p>

      <p>
        2. <em>Your goal</em> is to assist the Nuclear Operative team in moving
        and planting a nuclear device on-station.
        <br />
        <span className="small">
          The target location is recorded in the <em>audio log</em> and also
          viewable through the <em>Notes</em> verb.
          <br /> If you are unsure where the target location is, check the{' '}
          <em>map</em> button in the top right of the client, or use the{' '}
          <em>camera monitors</em> on the bridge.
        </span>
      </p>

      <p>
        3. Optionally, the captain&apos;s <em>authentication disk</em> can be
        used to shorten the countdown. The Syndicate commander spawns with a
        special version of the pinpointer that tracks the disk instead of the
        nuclear bomb.
      </p>

      <p>
        4. Teamplay is key! <em>Discuss the mission</em> with your comrades and
        come up with a solid plan <em>before</em> anybody heads out. Use your
        headset to stay in touch:
        <br />
        <br />
        <span className="small">
          say :z I&apos;m about to activate the nuke in security. Stick
          together, boys!
        </span>
      </p>

      <p>
        5. To exit the Syndicate Battlecruiser Cairngorm, take a pod from the
        podbay and open a wormhole leading to the station. Be aware that Pods{' '}
        <em>cannot warp back</em> to the Cairngorm.
        <br />
        <span className="small">
          Alternatively, stand on the <em>teleporter pad</em> and use your{' '}
          <em>teleporter remote</em>. This will take you to the listening post.
          You return to the shuttle in the same way. The station is to the{' '}
          <em>north-west</em> of the listening post.
        </span>
      </p>

      <p className="image-right">
        6. To trigger the nuke:
        <br />
        <img src={resource('images/antagTips/nuke-2.png')} className="right" />
        <span className="small indent">
          1. Load the nuke into one of your pods and drop it off near the
          station.
          <br />
          2. Move the nuke to the designated area.
          <br />
          3. Click on the nuke with an empty hand to activate it. That will
          prompt a station-wide red alert, stating your exact location.
          <br />
          4. Insert the authentication disk if you have it.
          <br />
          5. Defend the nuke until the countdown reaches zero. It&apos;s all or
          nothing!
          <br />
          6. Gloat over the radio and vanish in a cloud of radioactive fire!
          <br />
        </span>
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Nuclear Operative">
          the wiki
        </a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Nuclear Gun-Bot Basics',
  theme: 'syndicate',
  component: NukeGunbotContentWindow,
};
