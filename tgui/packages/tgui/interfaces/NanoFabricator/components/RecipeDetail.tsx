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
  NanoStorageData,
} from '../type';
import { MaterialStorage } from './MaterialStorage';

const RECIPE_ICON_SIZE = '64px';
const COMPONENT_BUTTON_WIDTH = 15;
const COMPONENT_ICON_SIZE = '32px';

interface RecipeDetailProps {
  partOptions: NanoPartOptionData[];
  storage: NanoStorageData[];
  selectedRecipe: NanoSelectedRecipeData | null;
  selectingPart: NanoSelectingPartData | null;
}

export const RecipeDetail = (props: RecipeDetailProps) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { partOptions, storage, selectedRecipe, selectingPart } = props;
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
                            <Stack.Item grow minWidth="0px" overflow="hidden">
                              <Box
                                width="100%"
                                nowrap
                                overflow="hidden"
                                style={{ textOverflow: 'ellipsis' }}
                              >
                                {part.assigned.name}
                              </Box>
                              <Box
                                italic
                                color={
                                  part.assigned.amount < part.amount
                                    ? 'bad'
                                    : undefined
                                }
                              >
                                {part.assigned.amount} available
                              </Box>
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
        <Stack.Item>
          <MaterialStorage
            partOptions={partOptions}
            selectedPart={selectingPartData}
            selectingPart={selectingPart}
            storage={storage}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
