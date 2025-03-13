/**
 * @file
 * @copyright 2024
 * @author cringe (https://github.com/Laboredih123)
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import {
  Box,
  Button,
  Flex,
  Image,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Icon } from '../../components';
import { Window } from '../../layouts';
import { ProductList } from '../common/ProductList';
import { ByondDir, HandPipeDispenserData, PipeData, Tab } from './type';

const RESOURCE_ICON_NAME = 'boxes-stacked';

export const HandPipeDispenser = () => {
  const { act, data } = useBackend<HandPipeDispenserData>();
  const {
    atmospipes,
    atmosmachines,
    destroying,
    selectedimage,
    selectedcost,
    resources,
    selecteddesc,
  } = data;
  const [tab, setTab] = useSharedState('tab', Tab.AtmosPipes);
  return (
    <Window width={450} height={350}>
      <Flex height="100%">
        <Flex.Item fill>
          <Section
            fill
            title={
              <>
                Resources: {resources} <Icon name={RESOURCE_ICON_NAME} />
              </>
            }
          >
            {/* Stack hell zone aka the preview with buttons */}
            <Stack vertical>
              <Box position="absolute" right="7px">
                {selectedcost} <Icon name={RESOURCE_ICON_NAME} />
              </Box>
              <Stack.Item>
                <Box textAlign="center">
                  <Button
                    icon="arrow-up"
                    onClick={() => act('changedir', { newdir: ByondDir.North })}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Flex align="center" justify="space-around">
                  <Flex.Item>
                    <Button
                      icon="arrow-left"
                      onClick={() =>
                        act('changedir', { newdir: ByondDir.West })
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Box
                      style={{
                        border: '1px solid grey',
                      }}
                    >
                      <Image
                        style={{ width: 64, height: 64 }}
                        src={`data:image/png;base64,${selectedimage}`}
                      />
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="arrow-right"
                      onClick={() =>
                        act('changedir', { newdir: ByondDir.East })
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Stack.Item>
              <Stack.Item>
                <Box textAlign="center">
                  <Button
                    icon="arrow-down"
                    onClick={() => act('changedir', { newdir: ByondDir.South })}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                {destroying ? (
                  <Button
                    textAlign="center"
                    fluid
                    color="red"
                    icon="xmark"
                    onClick={() => act('toggle-destroying')}
                  >
                    Removing
                  </Button>
                ) : (
                  <Button
                    textAlign="center"
                    fluid
                    color="green"
                    icon="plus"
                    onClick={() => act('toggle-destroying')}
                  >
                    Placing
                  </Button>
                )}
              </Stack.Item>
              <Stack.Item width="13em">
                <Box
                  style={{
                    border: '1px solid grey',
                    padding: '2px',
                  }}
                >
                  {selecteddesc}
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Flex.Item>
        <Flex.Item position="relative" ml={1} grow fill>
          <Window.Content scrollable>
            <Section>
              <Tabs fluid>
                <Tabs.Tab
                  selected={tab === Tab.AtmosPipes}
                  onClick={() => setTab(Tab.AtmosPipes)}
                >
                  Pipes
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tab === Tab.AtmosMachines}
                  onClick={() => setTab(Tab.AtmosMachines)}
                >
                  Machines
                </Tabs.Tab>
              </Tabs>
              {tab === Tab.AtmosPipes && (
                <Section fitted>
                  <ProductList showImage showOutput>
                    {atmospipes.map((atmospipe: PipeData) => {
                      return (
                        <ProductList.Item
                          key={atmospipe.name}
                          image={atmospipe.image}
                          outputSlot={
                            <ProductList.OutputButton
                              icon={RESOURCE_ICON_NAME}
                              onClick={() =>
                                act('select', {
                                  name: atmospipe.name,
                                })
                              }
                              tooltip="Select"
                            >
                              {atmospipe.cost}
                            </ProductList.OutputButton>
                          }
                        >
                          {atmospipe.name}
                        </ProductList.Item>
                      );
                    })}
                  </ProductList>
                </Section>
              )}
              {tab === Tab.AtmosMachines && (
                <Section fitted>
                  <ProductList showImage showOutput>
                    {atmosmachines.map((atmosmachine: PipeData) => {
                      return (
                        <ProductList.Item
                          key={atmosmachine.name}
                          image={atmosmachine.image}
                          outputSlot={
                            <ProductList.OutputButton
                              icon={RESOURCE_ICON_NAME}
                              onClick={() =>
                                act('select', {
                                  name: atmosmachine.name,
                                })
                              }
                              tooltip="Select"
                            >
                              {atmosmachine.cost}
                            </ProductList.OutputButton>
                          }
                        >
                          {atmosmachine.name}
                        </ProductList.Item>
                      );
                    })}
                  </ProductList>
                </Section>
              )}
            </Section>
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};
