/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  content: (
    <div className="traitor-tips">
      <h1 className="center">You become a Trickster!</h1>
      <p>1. Spread mischief and distrust among the crew</p>
      <p>2. Possess someone and become them for a short time</p>
      Abilities:
      <ul>
        <li>
          Choose haunt appearance: Allows you to copy the appearance of anyone,
          living or dead, and manifest as them when you haunt
        </li>
        <li>Mass whisper: Send a message to everyone around you.</li>
        <li>
          Creeping dread: Inflict a human with a status that will grow worse and
          worse while they remain in unlit places.
        </li>
        <li>
          Hallucinate: Cause some poor soul to incur terrifying visions for
          awhile!
        </li>
        <li>Fake sound: Generate a sound of your choice at a location.</li>
        <li>
          Lay rune trap: Manifest to place down a trap that&apos;ll trip anyone
          who passes it! The trap will be revealed if there is enough light
          around it.
        </li>
        <li>
          Summon poltergeist: Draw from your realm to summon a helper spirit who
          will harass the crew.
        </li>
        <li>
          Possess: Earn possession points by manifesting in view of people, then
          once you have enough, take possession of someone for a short time.
        </li>
        <li>
          Make poltergeist: Requests ghosts of players to join as poltergeists
          to torment the living.
        </li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Trickster">the wiki</a>
      </p>
    </div>
  ),
};
