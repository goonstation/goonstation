/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const KudzuAlertWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a member of the Kudzu hivemind!</h1>
      <img src={resource('images/antagTips/kudzuman.png')} className="center" />

      <h2 className="center">
        <em>Kudzupeople are Antagonists!</em>
      </h2>
      <p>
        1. Your new goal is very straightforward, protect and grow the kudzu so
        that all may enjoy, or be consumed by, your beauty!
      </p>
      <p>
        2. <em>You must stay on kudzu tiles to survive!</em> You have a pool of
        nutrients that are essential to life as a plant-man. Staying on kudzu
        tiles refills it, you rapidly lose them if not connected. When you run
        out, you&apos;ll take high damage and be stunned.
      </p>

      <p>3. You have several organic, plant-based abilities now.</p>
      <ul>
        <li>
          Guide Growth - Mark a tile with non-invasive kudzu flowers to prevent
          more kudzu from growing on that tile.
        </li>
        <li>
          Stealth - Secrete some of your nutrients points over time in order to
          blend into the background. Making you pretty hard to see while on top
          of kudzu.
        </li>
        <li>
          Heal Other - Target a human or kudzu person to heal them. If they are
          a kudzu person then you also transfer some of your nutrients to them.
        </li>
      </ul>

      <p>
        3. <em>Don&apos;t attack fellow kudzu people!</em>Since other kudzu
        people are technically part of yourself and the kudzu you should not
        harm them/you. You can telepathically speak to other kudzu people using
        the <em>:kuzdu</em> speech prefix.
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Kudzu">the wiki</a>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: "You've been absorbed into the Kudzu!",
  component: KudzuAlertWindow,
};
