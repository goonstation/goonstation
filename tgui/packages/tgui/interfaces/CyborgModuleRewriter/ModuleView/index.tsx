/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Section, Stack, Tabs } from '../../../components';
import { EmptyPlaceholder } from '../EmptyPlaceholder';
import { ModuleDetail } from './ModuleDetail';
import { ModulesData } from '../type';

// width hard-coded to allow display of widest current module name
// without resizing when ejected/reset
const ModuleListWidth = 20;

interface ModuleViewProps {
  modules: ModulesData;
  onEjectModule: (itemRef: string) => void;
  onMoveToolDown: (itemRef: string) => void;
  onMoveToolUp: (itemRef: string) => void;
  onRemoveTool: (itemRef: string) => void;
  onResetModule: (moduleId: string) => void;
  onSelectModule: (itemRef: string) => void;
}

export const ModuleView = (props: ModuleViewProps) => {
  const {
    modules: { available = [], selected } = {},
    onEjectModule,
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    onResetModule,
    onSelectModule,
  } = props;
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
      <Stack.Item width={ModuleListWidth}>
        <Section title="Modules" scrollable fill>
          <Tabs vertical>
            {available.map((module) => {
              const { item_ref: itemRef, name } = module;
              const ejectButton = (
                <Button
                  icon="eject"
                  color="transparent"
                  onClick={() => onEjectModule(itemRef)}
                  title={`Eject ${name}`}
                />
              );
              return (
                <Tabs.Tab
                  key={itemRef}
                  onClick={() => onSelectModule(itemRef)}
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
            onMoveToolDown={onMoveToolDown}
            onMoveToolUp={onMoveToolUp}
            onRemoveTool={onRemoveTool}
            onResetModule={onResetModule}
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
