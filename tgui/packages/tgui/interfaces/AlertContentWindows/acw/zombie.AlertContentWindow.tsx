/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Zombie Basics',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You have been revived as a Zombie!</h1>
      <p>
        You are now a zombie, this means that you should kill the living, and
        not harm your fellow zombie brethren.
      </p>
      <p>
        <em>If you are an infectious zombie</em>: Kill and infect people with
        your &quot;Zombify&quot; ability. It will add more friends to your hoard
        of undead!{' '}
      </p>
      <p>
        1. Simply attacking humans, normally will infect them if you land enough
        hits in a short enough time. Using the ability on the living infects
        them immediately, but it still takes a while for the infection to
        completely turn them into a zombie.
      </p>
      <p>
        2. Scratching/biting/&quot;Zombifying&quot; a dead human will instantly
        convert them to a new friend!
      </p>
      <p>
        You may be a mutated zombie and have unique powers! Check your DNA
        powers bar to see if you have any active genes!
      </p>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Zombie">the wiki</a>
      </p>
    </div>
  ),
};
