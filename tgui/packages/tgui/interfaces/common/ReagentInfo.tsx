/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { Box, ColorBox, Flex, Icon, NoticeBox, Section, Tooltip, Stack, ProgressBar } from '../../components';
import { freezeTemperature } from './temperatureUtils';
import { BoxProps } from '../../components/Box';
import { BooleanLike } from 'common/react';
import { InfernoNode } from 'inferno';
import { Color } from '../../../common/color';

interface ReagentContainer {
  name?: string;
  id?: string;
  maxVolume: number;
  totalVolume: number;
  finalColor: string;
  temperature?: number;
  contents?: Reagent[];
  fake?: BooleanLike;
}

interface Reagent {
  name: string;
  id: string;
  volume: number;
  colorR: number;
  colorG: number;
  colorB: number;
}

export const NoContainer: ReagentContainer = {
  name: "No Beaker Inserted",
  id: "inserted",
  maxVolume: 100,
  totalVolume: 0,
  finalColor: "#000000",
  temperature: freezeTemperature,
  fake: true,
};

interface ReagentInfoProps extends BoxProps {
  container: ReagentContainer;
}

interface ReagentGraphProps extends ReagentInfoProps {}

export const ReagentGraph = (props: ReagentGraphProps) => {
  const {
    className = '',
    container,
    height,
    ...rest
  } = props;
  const { maxVolume, totalVolume, finalColor } = container;
  const contents = container.contents || [];
  rest.height = height || "50px";

  return (
    <Box {...rest}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Flex height="100%">
            {contents.map(reagent => (
              <Flex.Item grow={reagent.volume/maxVolume} key={reagent.id}>
                <Tooltip content={`${reagent.name} (${reagent.volume}u)`} position="bottom">
                  <Box
                    px={0}
                    my={0}
                    height="100%"
                    backgroundColor={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
                  />
                </Tooltip>
              </Flex.Item>
            ))}
            <Flex.Item grow={((maxVolume - totalVolume)/maxVolume)}>
              <Tooltip content={`Nothing (${maxVolume - totalVolume}u)`} position="bottom">
                <NoticeBox
                  px={0}
                  my={0}
                  height="100%"
                  backgroundColor="rgba(0, 0, 0, 0)" // invisible noticebox kind of nice
                />
              </Tooltip>
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item>
          <Tooltip
            content={
              <Box>
                <ColorBox color={finalColor} /> Current Mixture Color
              </Box> as unknown as string // Elements/InfernoNodes work in Tooltip.content anyways.
            }
            position="bottom">
            <Box height="14px" // same height as a Divider
              backgroundColor={contents.length ? finalColor : "rgba(0, 0, 0, 0.1)"}
              textAlign="center">
              {container.fake || (
                <Box
                  as="span"
                  backgroundColor="rgba(0, 0, 0, 0.5)"
                  px={1}>
                  {`${totalVolume}/${maxVolume}`}
                </Box>
              )}
            </Box>
          </Tooltip>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

interface ReagentListProps extends ReagentInfoProps {
  renderButtons(reagent: Reagent): InfernoNode;
}

export const ReagentList = (props: ReagentListProps) => {
  const {
    className = '',
    container,
    renderButtons,
    height,
    ...rest
  } = props;
  const contents = container.contents || [];
  rest.height = height || 6;

  return (
    <Section scrollable>
      <Box {...rest}>
        {contents.length ? contents.map(reagent => (
          <Flex key={reagent.id} mb={0.5} align="center">
            <Flex.Item grow>
              <Icon
                pr={0.9}
                name="circle"
                style={{
                  "text-shadow": "0 0 3px #000;",
                }}
                color={`rgb(${reagent.colorR}, ${reagent.colorG}, ${reagent.colorB})`}
              />
              {`( ${reagent.volume}u ) ${reagent.name}`}
            </Flex.Item>
            {renderButtons && (
              <Flex.Item nowrap>
                {renderButtons(reagent)}
              </Flex.Item>
            )}
          </Flex>
        )) : (
          <Box color="label">
            <Icon
              pr={0.9}
              name="circle-o"
              style={{
                "text-shadow": "0 0 3px #000;",
              }}
            />
            Empty
          </Box>)}
      </Box>
    </Section>
  );
};

const reagentCheck = (a: Reagent, b: Reagent): boolean => {
  if (a.volume !== b.volume
      || a.name !== b.name
      || a.id !== b.id
      || a.colorR !== b.colorR
      || a.colorG !== b.colorG
      || a.colorB !== b.colorB) return true; // a property used by ReagentGraph/List has changed, update
  return false;
};

const containerCheck = (a: ReagentContainer, b: ReagentContainer): boolean => {
  if (a === b) return false; // same object or both null, no update
  if (a === null || b === null) return true; // only one object is null, update
  if (a.totalVolume !== b.totalVolume
      || a.finalColor !== b.finalColor
      || a.maxVolume !== b.maxVolume) return true; // a property used by ReagentGraph/List has changed, update
  if (a.contents?.length !== b.contents?.length) return true; // different number of reagents, update
  for (const i in a) {
    if (reagentCheck(a[i], b[i])) return true; // one of the reagents has changed, update
  }
  return false;
};

// modified version of the shallowDiffers function from common/react.ts
const reagentInfoDiffers = (a: ReagentInfoProps, b:ReagentInfoProps) => {
  let i;
  for (i in a) {
    if (i === "container") continue;
    if (!(i in b)) {
      return true;
    }
  }
  for (i in b) {
    if (i === "container") continue;
    if (a[i] !== b[i]) {
      return true;
    }
  }
  return containerCheck(a.container, b.container);
};

ReagentGraph.defaultHooks = {
  onComponentShouldUpdate: (lastProps: ReagentInfoProps, nextProps: ReagentInfoProps) => {
    return reagentInfoDiffers(lastProps, nextProps);
  },
};

ReagentList.defaultHooks = {
  onComponentShouldUpdate: (lastProps: ReagentInfoProps, nextProps: ReagentInfoProps) => {
    return reagentInfoDiffers(lastProps, nextProps);
  },
};

export const ReagentBar = (props: ReagentInfoProps) => {
  const {
    className = '',
    container,
    ...rest
  } = props;
  const { maxVolume, totalVolume, finalColor } = container;
  const color : Color = Color.fromHex(finalColor);
  const lightness = (color['r'] + color['r'] + color['r'])/3;
  return (
    <Stack align="center" pb={1}>
      <Stack.Item>
        <Box
          textAlign="right"
          width="3em"
        >
          {`${totalVolume}u`}
        </Box>
      </Stack.Item>
      <Stack.Item grow>
        <ProgressBar
          value={totalVolume}
          minValue={0}
          maxValue={maxVolume}
          color={finalColor}
          textColor={lightness > 255/2 ? "#000000" : "#FFFFFF"}
          {...rest}
        />
      </Stack.Item>
      <Stack.Item>
        <Box
          textAlign="left"
          width="3em"
        >
          {`${maxVolume}u`}
        </Box>
      </Stack.Item>
    </Stack>
  );
};
