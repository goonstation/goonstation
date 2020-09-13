/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Window } from '../layouts';
import ModuleView from './CyborgModuleRewriter/ModuleView';
import { BlockCn } from './CyborgModuleRewriter/style';

export const CyborgModuleRewriter = (props, context) => {
  const { act, data } = useBackend(context);
  const { modules } = data;

  const handleEjectModule = moduleRef => act('module-eject', { moduleRef });
  const handleMoveToolDown = ({ moduleRef, toolRef }) => act('tool-move', {
    dir: 'down',
    moduleRef,
    toolRef,
  });
  const handleMoveToolUp = ({ moduleRef, toolRef }) => act('tool-move', {
    dir: 'up',
    moduleRef,
    toolRef,
  });
  const handleRemoveTool = ({ moduleRef, toolRef }) => act('tool-remove', {
    moduleRef,
    toolRef,
  });
  const handleResetModule = ({ moduleId, moduleRef }) => act('module-reset', {
    moduleId,
    moduleRef,
  });
  const handleSelectModule = moduleRef => act('module-select', { moduleRef });

  return (
    <Window
      width={670}
      height={640}
      resizable>
      <Window.Content className={BlockCn} scrollable>
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
