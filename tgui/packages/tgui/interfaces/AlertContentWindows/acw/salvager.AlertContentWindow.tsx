/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  content: (
    <div className="traitor-tips">
      <h1 className="center">
        You are a <s>pirate</s> salvager!
      </h1>
      <img
        src={resource('images/antagTips/unknown-traitor-image.png')}
        className="center"
      />

      <p>
        1. You are an antagonist. Work with your fellow salvagers to do what you
        will to the station.
      </p>

      <p>2. Use your salvage reclaimer to disassemble walls and doors.</p>

      <p>
        3. Use your omnitool and deconstructor to convert equipment to frames
        for easy transportation.
      </p>

      <p>
        4. Sell your spoils to the M4GP13 Salvage and Barter System for
        additional gear. Check with the system to see if there are any special
        requests.
      </p>

      <p>
        5. Use your PDA to scan items to get an idea how much things are worth.
      </p>

      <p>
        6. The Salvager Pods are specially equipped to return back to the Magpie
        when using the &quot;Return to Magpie&quot; function. Handheld
        teleporters are also available to return.
      </p>

      <p>
        7. Your objectives will always be stored in your notes. To access them,
        use the <em>Notes</em> verb.
      </p>
    </div>
  ),
};
