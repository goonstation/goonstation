/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Icon,
  Image,
  NoticeBox,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type {
  NanoFabricatorData,
  NanoPartOptionData,
  NanoSelectedRecipeData,
  NanoSelectingPartData,
} from '../type';

const RECIPE_ICON_SIZE = '64px';
const COMPONENT_BUTTON_WIDTH = 15;
const MATERIAL_BUTTON_WIDTH = 15;
const COMPONENT_ICON_SIZE = '32px';

interface RecipeDetailProps {
  partOptions: NanoPartOptionData[];
  selectedRecipe: NanoSelectedRecipeData | null;
  selectingPart: NanoSelectingPartData | null;
}

export const RecipeDetail = (props: RecipeDetailProps) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { partOptions, selectedRecipe, selectingPart } = props;
  const [buildAmount, setBuildAmount] = useState(1);

  useEffect(() => {
    setBuildAmount(1);
  }, [selectedRecipe?.ref]);

  if (!selectedRecipe) {
    return (
      <Section fill title="Recipe details">
        <NoticeBox>Select a blueprint to configure its materials.</NoticeBox>
      </Section>
    );
  }

  const maxBuildAmount = Math.max(selectedRecipe.maxAmount, 1);
  const selectedBuildAmount = Math.min(buildAmount, maxBuildAmount);
  const selectingPartData = selectedRecipe.parts.find(
    (part) => part.ref === selectingPart?.ref,
  );
  const sortedPartOptions = [...partOptions].sort((a, b) =>
    a.name.replace(/^\d+\s+/, '').localeCompare(b.name.replace(/^\d+\s+/, '')),
  );

  return (
    <Section fill scrollable title="Recipe details">
      <Stack vertical>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>
              {selectedRecipe.img && (
                <Image src={selectedRecipe.img} height={RECIPE_ICON_SIZE} />
              )}
            </Stack.Item>
            <Stack.Item grow>
              <Box bold fontSize={1.2}>
                {selectedRecipe.name}
              </Box>
              <Box color="label">{selectedRecipe.description}</Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Section title="Components">
            <Stack vertical>
              {selectedRecipe.parts.map((part) => (
                <Stack.Item key={part.ref}>
                  <Stack align="center">
                    <Stack.Item grow>
                      <Box bold>
                        {!!part.optional && (
                          <Box as="span" mr={0.5}>
                            <Tooltip content="Optional component">
                              <Icon name="asterisk" color="label" />
                            </Tooltip>
                          </Box>
                        )}
                        {part.part_name || part.name}
                      </Box>
                      <Box>
                        {part.amount} x {part.name}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        width={COMPONENT_BUTTON_WIDTH}
                        selected={part.ref === selectingPart?.ref}
                        tooltip={
                          part.assigned
                            ? undefined
                            : part.optional
                              ? 'Add optional component'
                              : undefined
                        }
                        onClick={() => act('select_part', { ref: part.ref })}
                      >
                        {part.assigned ? (
                          <Stack align="center">
                            <Stack.Item minWidth={COMPONENT_ICON_SIZE}>
                              <Stack justify="center">
                                <Stack.Item>
                                  {part.assigned.img && (
                                    <Image src={part.assigned.img} />
                                  )}
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item grow overflow="hidden">
                              <Box
                                nowrap
                                overflow="hidden"
                                style={{ textOverflow: 'ellipsis' }}
                                color={
                                  part.assigned.amount < part.amount
                                    ? 'bad'
                                    : undefined
                                }
                              >
                                {part.assigned.name}
                              </Box>
                              <Box italic>{part.assigned.amount} available</Box>
                            </Stack.Item>
                          </Stack>
                        ) : part.optional ? (
                          <Stack align="center">
                            <Stack.Item minWidth={COMPONENT_ICON_SIZE}>
                              <Stack justify="center">
                                <Stack.Item>
                                  <Icon name="spinner" spin={1} />
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item grow>
                              <Box>Choose component</Box>
                              <Box italic>Optional</Box>
                            </Stack.Item>
                          </Stack>
                        ) : (
                          <Stack align="center">
                            <Stack.Item minWidth={COMPONENT_ICON_SIZE}>
                              <Stack justify="center">
                                <Stack.Item>
                                  <Tooltip
                                    content="Select a component for this required slot"
                                    position="bottom"
                                  >
                                    <Icon name="spinner" spin={1} />
                                  </Tooltip>
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                            <Stack.Item grow>
                              <Box>Choose component</Box>
                              <Box italic>Required</Box>
                            </Stack.Item>
                          </Stack>
                        )}
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              {selectedRecipe.complete && selectedRecipe.maxAmount > 0 ? (
                <Box color="good">
                  Ready to build up to {selectedRecipe.maxAmount}.
                </Box>
              ) : (
                <Box color="label">
                  Assign all required components to build.
                </Box>
              )}
            </Stack.Item>
            <Stack.Item grow>
              <Slider
                value={selectedBuildAmount}
                minValue={1}
                maxValue={maxBuildAmount}
                step={1}
                format={(value) => `${value}x`}
                disabled={
                  !selectedRecipe.complete || selectedRecipe.maxAmount <= 0
                }
                onChange={(_event, value) => setBuildAmount(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="cogs"
                disabled={
                  !selectedRecipe.complete || selectedRecipe.maxAmount <= 0
                }
                onClick={() =>
                  act('build', {
                    amount: selectedBuildAmount,
                  })
                }
              >
                Build
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {selectingPart && (
          <Stack.Item>
            <Dimmer
              position="relative"
              width="100%"
              style={{ display: 'block' }}
            >
              <Stack width="100%" p={0.5}>
                <Stack.Item width="100%">
                  <Section
                    m={0}
                    title={`Choose ${selectingPart.part_name || selectingPart.name}`}
                    buttons={
                      <>
                        <Button
                          icon="eraser"
                          color="bad"
                          disabled={!selectingPartData?.assigned}
                          onClick={() => act('clear_part')}
                        >
                          Clear
                        </Button>
                        <Button icon="times" onClick={() => act('cancel_part')}>
                          Close
                        </Button>
                      </>
                    }
                  >
                    {partOptions.length ? (
                      <Stack wrap="wrap" g={0.5}>
                        {sortedPartOptions.map((option) => (
                          <Stack.Item
                            key={option.ref}
                            width={MATERIAL_BUTTON_WIDTH}
                          >
                            <Button
                              fluid
                              disabled={option.insufficient}
                              onClick={() =>
                                act('choose_part', { ref: option.ref })
                              }
                            >
                              <Stack align="center">
                                <Stack.Item>
                                  {option.img && <Image src={option.img} />}
                                </Stack.Item>
                                <Stack.Item grow overflow="hidden">
                                  <Box
                                    nowrap
                                    overflow="hidden"
                                    style={{ textOverflow: 'ellipsis' }}
                                  >
                                    {option.name}
                                  </Box>
                                  <Box italic>{option.amount} available</Box>
                                </Stack.Item>
                              </Stack>
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    ) : (
                      <NoticeBox>
                        No valid components are available for this slot.
                      </NoticeBox>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            </Dimmer>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
