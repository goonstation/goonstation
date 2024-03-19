/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ModuleView } from './ModuleView';
import { ejectModule, moveTool, removeTool, resetModule, selectModule } from './action';
import * as styles from './style';
import { Direction } from './type';
import type { CyborgModuleRewriterData } from './type';

export const CyborgModuleRewriter = (_props: unknown, context) => {
  const { act, data } = useBackend<CyborgModuleRewriterData>(context);
  const { modules } = data;

  const handleEjectModule = (itemRef: string) => ejectModule(act, { itemRef });
  const handleMoveToolDown = (itemRef: string) =>
    moveTool(act, {
      dir: Direction.Down,
      itemRef,
    });
  const handleMoveToolUp = (itemRef: string) =>
    moveTool(act, {
      dir: Direction.Up,
      itemRef,
    });
  const handleRemoveTool = (itemRef: string) => removeTool(act, { itemRef });
  const handleResetModule = (moduleId: string) => resetModule(act, { moduleId });
  const handleSelectModule = (itemRef: string) => selectModule(act, { itemRef });

  return (
    <Window width={670} height={640}>
      <Window.Content className={styles.Block}>
        <ModuleView
          modules={modules}
          onEjectModule={handleEjectModule}
          onMoveToolDown={handleMoveToolDown}
          onMoveToolUp={handleMoveToolUp}
          onRemoveTool={handleRemoveTool}
          onResetModule={handleResetModule}
          onSelectModule={handleSelectModule}
        />
      </Window.Content>
    </Window>
  );
};
