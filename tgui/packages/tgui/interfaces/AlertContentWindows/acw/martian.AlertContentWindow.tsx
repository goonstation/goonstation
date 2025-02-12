/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Being a Martian 101!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are a martian infiltrator!</h1>

      <p>
        1. <em>Your goal</em> is to establish a forward base with your{' '}
        <em>fellow infiltrators</em>, and to build a <em>portal generator</em>{' '}
        to start the invasion.
      </p>

      <p>
        2. By <em>speaking normally</em> your thoughts will carry to all other
        martians through the collective psionic link you all share. Humans{' '}
        <em>will not understand you</em>, and you{' '}
        <em>cannot understand them</em>.
      </p>

      <p>
        3. All of your structures will at some point require <em>biomatter</em>{' '}
        to function.
        <br />
        This is obtained via the <em>biomass pool</em>. Compatible objects must
        be dipped into it to be converted into biomatter.
        <br />
        The list of compatible objects includes human bodies (alive or dead),
        monkeys (which are not as good as humans), and other things. If
        it&apos;s meat, it&apos;s a meal.
      </p>

      <p>
        4. Use the <em>seed grower</em> to grow more seeds after you have
        sufficient biomass.
        <br />
        It will describe what is available, what function it performs, and how
        much it costs to produce. Produced seeds&nbsp;
        <em>must be used in-hand</em> (or in-tentacle) to be activated, and then
        placed on an empty floor tile to begin growing.
      </p>

      <p>
        5. This is all heavily a work in progress, so no other documentation
        exists while things are in rapid fluctation.
        <br />
        Good luck, and remember that mentorhelp and adminhelp still exist!
      </p>
    </div>
  ),
};
