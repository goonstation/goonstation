/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback } from 'react';
import { Button, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import * as actions from '../../action';
import { EmptyPlaceholder } from '../../EmptyPlaceholder';
import { Direction } from '../../type/action';
import type { CyborgModuleRewriterData } from '../../type/data';
import { ModuleDetail } from './ModuleDetail';

// width hard-coded to allow display of widest current module name without resizing when ejected/reset
const SIDEBAR_WIDTH = 20;

export const ModuleView = () => {
  const { act, data } = useBackend<CyborgModuleRewriterData>();
  const { modules: { available = [], selected } = {} } = data;
  const handleEjectModule = useCallback(
    (itemRef: string) => actions.ejectModule(act, { itemRef }),
    [act],
  );
  const handleMoveToolDown = useCallback(
    (itemRef: string) =>
      actions.moveTool(act, {
        dir: Direction.Down,
        itemRef,
      }),
    [act],
  );
  const handleMoveToolUp = useCallback(
    (itemRef: string) =>
      actions.moveTool(act, {
        dir: Direction.Up,
        itemRef,
      }),
    [act],
  );
  const handleRemoveTool = useCallback(
    (itemRef: string) => actions.removeTool(act, { itemRef }),
    [act],
  );
  const handleResetModule = useCallback(
    (moduleId: string) => actions.resetModule(act, { moduleId }),
    [act],
  );
  const handleSelectModule = useCallback(
    (itemRef: string) => actions.selectModule(act, { itemRef }),
    [act],
  );
  const { item_ref: selectedModuleRef, tools = [] } = selected || {};

  if (available.length === 0) {
    return (
      <Section fill>
        <EmptyPlaceholder>No modules inserted</EmptyPlaceholder>
      </Section>
    );
  }
  return (
    <Stack fill>
      <Stack.Item width={SIDEBAR_WIDTH}>
        <Section title="Modules" scrollable fill>
          <Tabs vertical>
            {available.map((module) => {
              const { item_ref: itemRef, name } = module;
              const ejectButton = (
                <Button
                  icon="eject"
                  color="transparent"
                  onClick={() => handleEjectModule(itemRef)}
                  tooltip={`Eject ${name}`}
                />
              );
              return (
                <Tabs.Tab
                  key={itemRef}
                  onClick={() => handleSelectModule(itemRef)}
                  rightSlot={ejectButton}
                  selected={itemRef === selectedModuleRef}
                >
                  {name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        {selectedModuleRef ? (
          <ModuleDetail
            onMoveToolDown={handleMoveToolDown}
            onMoveToolUp={handleMoveToolUp}
            onRemoveTool={handleRemoveTool}
            onResetModule={handleResetModule}
            tools={tools}
          />
        ) : (
          <Section fill>
            <EmptyPlaceholder>No module selected</EmptyPlaceholder>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
