/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const PodwarsContentWindow = () => {
  return (
    <div className="traitor-tips pod-wars-tips">
      <h1 className="center">You are a pod pilot!</h1>
      <div className="image-bar">
        <img
          src={resource('images/antagTips/pw-sy.png')}
          style={{ width: '128px', height: '200%' }}
        />
        <img
          src={resource('images/antagTips/pw-system.png')}
          style={{ width: '96px', height: '300%' }}
        />
        <img
          src={resource('images/antagTips/pw-nt.png')}
          style={{ width: '128px', height: '200%;' }}
        />
      </div>
      <h2>How to Play (The Basics)</h2>
      <p>
        1. Work together with your team to fight the enemy, capture strategic
        locations, and destroy the enemy ship!
      </p>
      <ul>
        <li>
          Teams <b>gain/lose points</b> with kills and by destroying the
          &quot;Critical Systems&quot; on their base ships and captuing Control
          Points. Each team starts with 100 points. If any team hits either 200
          points or 0 points, the round will end. If you lose all four of your
          Critical Systems, your team instantly loses. Alternatively it will end
          after about 90 minutes...
        </li>
        <li>
          <b>Mine</b> the asteroid field! Each team starts with some{' '}
          <b>auto pod fabricators</b> that can make small dinghy pods for free.
          But you&apos;ll need to explore the map or use the mining magnet get
          materials to make better pods!
        </li>
        <li>
          At <b>~15 minutes</b> in, an <b>Ion Storm</b> hits and: (A) lowers the
          shields on each teams&apos; critical systems, and (B) lets teams
          capture the three control points on Fortuna, UVB-67, and the NSV
          Reliant.
        </li>
        <li>
          Holding a <b>control point</b> activates the Warp Beacons so that your
          team can use pods to warp to it. If a point is held for a consecutive
          5, 10, and &gt;15 minutes <b>rewards you with crates of items</b> at
          the control point computer and{' '}
          <b>subtracts some points from the enemy team</b>.
        </li>
      </ul>
      <p>
        2. <b>Follow orders from your commander!</b> Your commander should be
        easily recognizable by their special equipment, and even more easily
        recogniable by their star antag icon at the top-right of their sprite!
        Commanders are worth more points to kill, but they are also able to
        capture control points at twice the speed!
      </p>

      <p>
        3. <b>Death isn&apos;t the end!</b> Both teams have extra heavy duty
        cloning pods that quickly clone dead players back into fresh bodies and
        fits them with standard equipment.{' '}
        <b>If you want to die for good and spectate</b>, you&apos;ll have to set
        DNR. Use the set-dnr command before you die and you&apos;ll be removed
        from your team and die so you can spectate!
      </p>

      <p>
        4. Use the <b>private channel(:g)</b> to communicate with your team! Use
        the public channel(;) to talk with everyone.
      </p>

      <hr />
      <hr />
      <br />
      <h2>Miscellaneous Tips</h2>
      <p>A couple unassorted tips to help you out:</p>
      <ul>
        <li>
          <b>Lock your pods!</b> There&apos;s a new pod lock that works based on
          ID type, Syndicate or NT. Use them!
        </li>
        <li>
          The NanoTrasen Base Ship is called the <b>NSV Pytheas</b>. The
          Syndicate Base Ship is called the <b>Lodbrok</b>.
        </li>
        <li>
          Use the <b>scanners on any pod</b> to locate warp beacons of useful
          locations like both base ships and all control points.(if your team
          has captured a control point, you will see that beacon name on your
          list of warp targets)
        </li>
        <li>
          There are some new items (deployable barricades, medicated bandages,
          gun power cells, etc) that can be made from pod manufacturers or wall
          dispensers.
        </li>
        <li>
          Commanders have their star antag overlay visible to all players. So
          you always know who is your commander and the enemy commander.
        </li>
        <li>
          You can&apos;t{' '}
          <b>
            capture control points or destroy enemy critical systems until 15
            minutes
          </b>{' '}
          in when the Ion Storm hits, so it&apos;s more profitable to mine and
          explore the asteroid field for the first few minutes.
        </li>
        <li>
          Each Base Ship has a <b>map of the asteroid field</b> on a wall near
          their pod manufacturing area.
        </li>
        <li>
          Your <b>PDA has a GPS program</b> so if you get lost in space without
          a pod. You can tell your friends to come pick you up.
        </li>
        <li>
          Pod Fabricators can build almost any type of pod weapon, provided you
          have the right materials for it.
        </li>
        <li>
          There&apos;s a derelict station on the southwest side of the map with
          a mineral magnet that can be set up to get more minerals.
        </li>
        <li>
          Both Base Ships have a <b>medical chem dispenser</b> that can fill
          beakes with a bunch of pre-programmed medical chems, Fortuna has one
          with a wider selection.
        </li>
        <li>
          If you capture a control point from an enemy team that has already
          earned a crate tier II or above, then you&apos;ll get a tier I crate
          immediately.
        </li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Pod wars">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Fight for your team!',
  component: PodwarsContentWindow,
};
