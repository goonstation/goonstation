/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

export const acw: AlertContentWindow = {
  title: 'Arcfiend Tips!',
  content: (
    <div className="traitor-tips">
      <h1 className="center">You are an Arcfiend!</h1>
      <p>1. Absorb energy from machinery, humans, and robots</p>
      <p>2. Use energy to cast abilities</p>
      Abilities:
      <ul>
        <li>Sap Power - Drain power from a target person or machine</li>
        <li>
          Discharge - Run a powerful current through a target in melee range
          damaging mobs and depowering doors
        </li>
        <li>
          Flash - Release a sudden burst of power around yourself disorienting
          nearby foes
        </li>
        <li>
          Arc Flash - Unleash a ranged bolt of electricity that chains to nearby
          targets with reduced damage
        </li>
        <li>
          Polarize - Unleash a wave of charged particles polarizing nearby mobs
          giving them magnetic auras
        </li>
        <li>
          Ride The Lightning - Expend energy to travel through electrical cables
        </li>
        <li>
          Jamming Field - Radiate electromagnetic waves disrupting nearby
          electrical signals such as radio communications for 30 seconds
        </li>
        <li>
          Jolt - Charge up and release a series of powerful jolts into your
          target, burning and eventually stopping their heart
        </li>
        <li>
          (Passive) Energy Storage - Store up to 2500 energy to use with your
          abilities
        </li>
        <li>
          (Passive) SMES Human - Immunity to most electric based attacks,
          identical to the gene
        </li>
      </ul>
      <p>
        For more information, consult{' '}
        <a href="https://wiki.ss13.co/index.php?search=Arcfiend">the wiki</a>
      </p>
    </div>
  ),
};
