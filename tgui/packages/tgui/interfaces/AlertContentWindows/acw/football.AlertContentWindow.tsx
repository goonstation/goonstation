/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const FootballContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are a SAFL player!</h1>

      <p>
        <strong>
          The year is 2053 and it&apos;s time for some Space American Football
          League-style football!
        </strong>
      </p>

      <p>
        You have 15 minutes to score more points than the other team.
        <ul>
          <li>
            <strong>
              Carrying the ball into the endzone like a winner gives you six big
              ol&apos; points.
            </strong>
          </li>
          <li>
            <strong>Get dat fukken ball!</strong> The current ball carrier has a
            big number over their head.
          </li>
          <li>
            <strong>Don&apos;t have the ball?</strong> Use your charge (top
            left) to steamroll the idiot who has the ball!
          </li>
          <li>
            You can throw the ball to your teammates! Remember: There&apos;s no
            I in team.
          </li>
          <li>
            If you&apos;re a coward, you can also throw the ball into the
            endzone to score a single, sad point.
          </li>
          <li>
            <strong>Dead?</strong> Every 15 seconds, a new wave of players will
            respawn.
          </li>
        </ul>
      </p>

      <p>
        In the SAFL, there are no penalties, no out-of-bounds, no time-outs, and
        no rules*. Get out there and win!
      </p>
      <p style={{ fontSize: '70%' }}>
        * No <em>football</em> rules. You still have to follow the server rules.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Go for the endzone!',
  component: FootballContentWindow,
};
