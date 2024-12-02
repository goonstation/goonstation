/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'How to steal Spacemas',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a grinch!</h1>
      <p>
        1. Use your powers to <em>ruin Spacemas</em> for everyone!
      </p>

      <p className="cf image-right">
        2. Most of your abilities reduce Spacemas cheer directly or indirectly.
        <br />
        <span className="small">
          <br />
          <br />
          <span style={{ float: 'left', width: '50%' }}>
            <em>Vandalize</em>, destroy Spacemas decoration, write rude
            graffiti.
            <br />
            <em>Poison food</em>, taint foods or drinks with deadly poison.
            <br />
          </span>
          <span style={{ float: 'left', width: '50%' }}>
            <em>Murder</em>, induces instant cardiac arrest.
            <br />
            <em>Activate cloak</em>, cloak for a limited amount of time.
            <br />
          </span>
        </span>
      </p>

      <p>
        3. Santa Claus is your nemesis. Do everything in your power to{' '}
        <em>kill him</em>.
      </p>

      <p>
        4. Work together with other grinches if there are any.{' '}
        <em>Do not attack them</em>, you&apos;re on the same team!
      </p>

      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Grinch">the wiki</a>
      </p>
    </div>
  ),
};
