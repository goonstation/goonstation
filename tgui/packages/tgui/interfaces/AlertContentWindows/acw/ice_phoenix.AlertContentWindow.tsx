/**
 * @file
 * @copyright 2024
 * @author FlameArrow57
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Space Phoenix Basics',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a Space Phoenix!</h1>
      <p>
        1. You are a spacefaring creature, given the innate ability to fly
        freely in space. Use your Map and Return to Station abilities at the
        bottom right to navigate the station Z level, and toggle returning to
        the station Z level upon exiting the current Z level.
      </p>
      <p>
        2. Your main attack is firing ice feathers. Use this to damage and chill
        attackers.
      </p>
      <p>
        3. The station is harmful to you. If you stay longer than 30 seconds on
        the station in an area that is not permafrosted, you will begin to take
        damage.
      </p>
      <p>
        4. Use your Permafrost ability to make areas of the station habitable to
        you, and less habitable to its residents.
      </p>
      <p>
        5. Your Windchill and Touch of Death abilities have special effects
        against targets who have low body temperature (see their descriptions).
        Use this to your advantage!
      </p>
      <p>6. You naturally regen health in space when out of combat.</p>
      <p>
        7. Entering combat or traveling to the station will make you vulnerable,
        causing you to radiate walkable ice when space traveling.
      </p>

      <p>
        This antag is currently in development and will not be found on the
        wiki.
      </p>
    </div>
  ),
};
