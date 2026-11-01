/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const MindhackOverrideContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">Your loyalties have changed!</h1>
      <p>
        Your mindhack implant has been <em>overridden</em> by a new one,
        cancelling out your former allegiances!{' '}
        <em>Obey your new mindhacker</em> instead!
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Mindhack Master Changed!',
  component: MindhackOverrideContentWindow,
};
