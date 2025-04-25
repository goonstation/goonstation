/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Nuclear Operative Basics',
  theme: 'syndicate',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a Syndicate operative!</h1>
      <img
        src={resource('images/antagTips/nuke-operative-image-2.png')}
        className="center"
      />

      <p>
        1. <em>Your goal</em> is to move the nuke onto the station and activate
        it there.
        <br />
        <span className="small">
          The target location is recorded in the <em>audio log</em> and also
          viewable through the <em>Notes</em> verb.
          <br />
          If you are unsure where the target location is, view the{' '}
          <em>Atrium Station Map</em>, check the <em>map</em> button in the top
          right of the client, or use the <em>camera monitors</em> on the
          bridge.
        </span>
      </p>

      <p className="image-right">
        2. Each operative starts with a <em>requisition token</em>.<br />
        <span className="small">
          Insert it in to a <em>weapons vendor</em> and select a{' '}
          <em>sidearm, loadout and utility</em> option from the list.
          <br />
          <img
            src={resource('images/antagTips/syndicate-weapon.png')}
            className="right"
          />
          It is often worthwhile to plan your loadout purchases with your fellow
          operatives!
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
          say :h I&apos;m about to activate the nuke in security. Stick
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
  ),
};
