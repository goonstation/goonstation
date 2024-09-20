/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../../../../backend';
import { Button, Section, Stack, Tabs } from '../../../../components';
import { EmptyPlaceholder } from '../../EmptyPlaceholder';
import * as actions from '../../action';
import type { CyborgModuleRewriterData } from '../../type/data';
import { Direction } from '../../type/action';
import { ModuleDetail } from './ModuleDetail';

// width hard-coded to allow display of widest current module name without resizing when ejected/reset
const SIDEBAR_WIDTH = 20;

export const ModuleView = (_props: unknown, context: unknown) => {
  const { act, data } = useBackend<CyborgModuleRewriterData>(context);
  const { modules: { available = [], selected } = {} } = data;
  const handleEjectModule = (itemRef: string) => actions.ejectModule(act, { itemRef });
  const handleMoveToolDown = (itemRef: string) =>
    actions.moveTool(act, {
      dir: Direction.Down,
      itemRef,
    });
  const handleMoveToolUp = (itemRef: string) =>
    actions.moveTool(act, {
      dir: Direction.Up,
      itemRef,
    });
  const handleRemoveTool = (itemRef: string) => actions.removeTool(act, { itemRef });
  const handleResetModule = (moduleId: string) => actions.resetModule(act, { moduleId });
  const handleSelectModule = (itemRef: string) => actions.selectModule(act, { itemRef });
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
                  title={`Eject ${name}`}
                />
              );
              return (
                <Tabs.Tab
                  key={itemRef}
                  onClick={() => handleSelectModule(itemRef)}
                  rightSlot={ejectButton}
                  selected={itemRef === selectedModuleRef}>
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
