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
import { CyborgModuleRewriterData, Direction } from './type';

export const CyborgModuleRewriter = (_props, context) => {
  const { act, data } = useBackend<CyborgModuleRewriterData>(context);
  const { modules } = data;

  const handleEjectModule = (moduleRef: string) => ejectModule(act, { moduleRef });
  const handleMoveToolDown = (moduleRef: string, toolRef: string) => moveTool(act, {
    dir: Direction.Down,
    moduleRef,
    toolRef,
  });
  const handleMoveToolUp = (moduleRef: string, toolRef: string) => moveTool(act, {
    dir: Direction.Up,
    moduleRef,
    toolRef,
  });
  const handleRemoveTool = (moduleRef: string, toolRef: string) => removeTool(act, {
    moduleRef,
    toolRef,
  });
  const handleResetModule = (moduleRef: string, moduleId: string) => resetModule(act, {
    moduleId,
    moduleRef,
  });
  const handleSelectModule = (moduleRef: string) => selectModule(act, { moduleRef });

  return (
    <Window
      width={670}
      height={640}
    >
      <Window.Content className={styles.Block} scrollable>
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
