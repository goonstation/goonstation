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
        1. You are a spacefaring creature, given space traveling abilities found
        at the bottom right. Use your Map ability to navigate the station Z
        level. Use your Return to Station ability to toggle returning to the
        station Z level upon exiting the current Z level.
      </p>
      <p>
        2. Your main attack is firing ice feathers. Use this to damage and chill
        attackers. Those chilled by you have a temperature indicator. Once it
        reaches dark blue, use Wind Chill followed up by Touch of Death to kill
        an isolated target.
      </p>
      <p>
        3. The station is harmful to you. If you stay longer than 30 seconds on
        the station in an area that is not permafrosted, you will begin to take
        damage. You can use your Permafrost ability to make the area more
        habitable to you and less habitable to humans.
      </p>
      <p>
        4. While in space, fires on you are extinguished, and you regen health
        and heal bleed while out of combat.
      </p>
      <p>
        5. Entering combat or traveling to the station will make you vulnerable,
        causing you to radiate walkable ice when space traveling. This ice
        prevents space damage to attackers, so make sure you can handle them if
        you decide to attack.
      </p>
      <p>
        6. Up to 5 dead humans and 5 dead critters brought into your nest, while
        inside, grant you extra out of combat health regeneration. After
        collecting 5 dead humans, you get a 1 time revive.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Space Phoenix">
          the wiki
        </a>
      </p>
    </div>
  ),
};
