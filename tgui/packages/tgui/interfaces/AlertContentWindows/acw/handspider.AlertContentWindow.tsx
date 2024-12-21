/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Handspider Expectations',
  content: (
    <div className="traitor-tips">
      <h1 className="center">
        You have reawakened to serve your host changeling!
      </h1>
      <p>
        You must <em>obey</em> their commands!
        <br />
        You are a very small and weak creature that can fit into tight spaces.
        Do not expect to survive for long in direct combat. You are still
        connected to the hivemind.
      </p>
      <p>
        Abilities
        <span className="small indent">
          <em>Gnaw</em> a human take a hunk of flesh and collect a small amount
          of DNA.
          <br />
          <em>Blood Boil</em> to generate intense heat using all of your
          remaining energy and explode, scalding nearby targets. Collecting
          additional DNA will spray hotter blood.
          <br />
          <em>Return to your Master</em> by clicking on them as you stand
          nearby. This will transfer all of your collected DNA points to them.
          <br />
        </span>
      </p>
    </div>
  ),
};
