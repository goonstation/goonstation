/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const PossessionContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You have possessed a soulsteel item!</h1>

      <p>
        Though limited, you can now move your item around and interact with
        others, but <b>do not randomly attack the crew!</b> You are here to
        spook the crew, not kill them!
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Posession!',
  component: PossessionContentWindow,
};
