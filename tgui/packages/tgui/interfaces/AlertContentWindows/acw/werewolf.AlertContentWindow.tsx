/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const WerewolfContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a werewolf!</h1>

      <p>
        1. You can shapeshift at will with the <em>Transform</em> ability, but
        keep out of sight of the crew when you change forms! Your objectives
        will always be stored in your notes. To access them, use the{' '}
        <em>Notes</em> verb.
      </p>

      <p>
        2. <em>Beware!</em> Werewolves can&apos;t wear jumpsuits, exosuits or
        shoes. Furthermore, the wolf-like form is completely useless for
        stealth.
      </p>

      <p>
        3. Use the <em>DISARM</em> intent on somebody for a guaranteed (but
        brief) knockdown, or slash at them with the <em>HARM</em> intent to wear
        down their health and capacity to fight back.
      </p>

      <p>
        4. Once you&apos;ve incapacitated the victim, use the{' '}
        <em>Maul Victim</em> ability to feast on them. This will also heal a
        considerable amount of brute and burn damage in case you&apos;re
        injured.
      </p>

      <p>
        5. Certain leftover organs can be <em>consumed</em> to restore a minor
        amount of health.
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Werewolf">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Werewolf Basics',
  component: WerewolfContentWindow,
};
