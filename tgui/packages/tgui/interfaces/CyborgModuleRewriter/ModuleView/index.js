/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Flex, Section, Tabs, Button } from '../../../components';
import EmptyPlaceholder from '../EmptyPlaceholder';
import Module from './Module';

// width hard-coded to allow display of widest current module name
// without resizing when ejected/reset
const ModuleListWidth = 18;

const ModuleView = props => {
  const {
    modules: {
      available = [],
      selected,
    } = {},
    onEjectModule,
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    onResetModule,
    onSelectModule,
  } = props;
  const {
    ref: selectedModuleRef,
    tools = [],
  } = selected || {};

  const handleMoveToolDown = toolRef => onMoveToolDown({
    moduleRef: selectedModuleRef,
    toolRef,
  });
  const handleMoveToolUp = toolRef => onMoveToolUp({
    moduleRef: selectedModuleRef,
    toolRef,
  });
  const handleRemoveTool = toolRef => onRemoveTool({
    moduleRef: selectedModuleRef,
    toolRef,
  });
  const handleResetModule = moduleId => onResetModule({
    moduleId,
    moduleRef: selectedModuleRef,
  });

  return (
    available.length > 0
      ? (
        <Flex>
          <Flex.Item width={ModuleListWidth} mr={1}>
            <Section title="Modules" fitted>
              <Tabs vertical>
                {
                  available.map(module => {
                    const {
                      ref: moduleRef,
                      name,
                    } = module;
                    const ejectButton = (
                      <Button
                        icon="eject"
                        color="transparent"
                        onClick={() => onEjectModule(moduleRef)}
                        title={`Eject ${name}`}
                      />
                    );
                    return (
                      <Tabs.Tab
                        key={moduleRef}
                        onClick={() => onSelectModule(moduleRef)}
                        rightSlot={ejectButton}
                        selected={moduleRef === selectedModuleRef}>
                        {name}
                      </Tabs.Tab>
                    );
                  })
                }
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            {
              selectedModuleRef
                ? (
                  <Module
                    onMoveToolDown={handleMoveToolDown}
                    onMoveToolUp={handleMoveToolUp}
                    onRemoveTool={handleRemoveTool}
                    onResetModule={handleResetModule}
                    tools={tools}
                  />
                )
                : (
                  <Section>
                    <EmptyPlaceholder>No module selected</EmptyPlaceholder>
                  </Section>
                )
            }
          </Flex.Item>
        </Flex>
      )
      : (
        <Section>
          <EmptyPlaceholder>No modules inserted</EmptyPlaceholder>
        </Section>
      )
  );
};

export default ModuleView;
