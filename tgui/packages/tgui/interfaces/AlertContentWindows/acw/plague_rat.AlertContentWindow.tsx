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
      <h1 className="center">You are a plague rat!</h1>
      <p>1. Spread disease using your abilities</p>
      <p>2. Survive and reproduce!</p>
      Abilities:
      <ul>
        <li>
          Eat a lot of filth such as gibs, vomit and other delicious morsels to
          grow!
        </li>
        <li>
          Bite people to give them the plague. You&apos;ll need less bites to
          plague them as you grow bigger.
        </li>
      </ul>
      <h3>Medium size rat</h3>
      <ul>
        <li>
          Make a rat den that will spawn small aggressive mice, and heal you
          when close-by.
        </li>
      </ul>
      <h3>Adult rat</h3>
      <ul>
        <li>
          Summon another plague rat! You need to be in your rat den to do this.
        </li>
        <li>Slam into an unfortunate human and stun you both.</li>
      </ul>
    </div>
  ),
};
