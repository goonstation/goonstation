/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Window } from '../../layouts';
import * as styles from './style';
import { ModuleView } from './views/ModuleView';

export const CyborgModuleRewriter = () => {
  return (
    <Window width={670} height={640}>
      <Window.Content className={styles.Block}>
        <ModuleView />
      </Window.Content>
    </Window>
  );
};
