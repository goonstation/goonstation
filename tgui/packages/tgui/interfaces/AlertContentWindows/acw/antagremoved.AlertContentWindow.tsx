/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const AntagRemovalContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">You are no longer an antagonist!</h1>

      <p>
        An admin has <em>revoked</em> your antagonist status! If this is an
        unexpected development, please inquire about it in <em>adminhelp</em>.
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'Antagonist Status Removed!',
  component: AntagRemovalContentWindow,
};
