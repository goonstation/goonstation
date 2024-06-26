/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { Box, ColorBox, Flex, Icon, NoticeBox, ProgressBar, Section, Stack, Tooltip } from '../../components';
import { freezeTemperature } from './temperatureUtils';
import { BoxProps } from '../../components/Box';
import { BooleanLike } from 'common/react';
import { InfernoNode } from 'inferno';

export enum MatterState {
  Solid = 1,
  Liquid = 2,
  Gas = 3,
}

export const MatterStateIconMap = {
  [MatterState.Solid]: {
    icon: 'square',
    pr: 0.5,
  },
  [MatterState.Liquid]: {
    icon: 'tint',
    pr: 0.9,
  },
  [MatterState.Gas]: {
    icon: 'wind',
    pr: 0.5,
  },
};

export interface ReagentContainer {
  name?: string;
  id?: string;
  maxVolume: number;
  totalVolume: number;
  finalColor: string;
  temperature?: number;
  contents?: Reagent[];
  fake?: BooleanLike;
}

export interface Reagent {
  name: string;
  id: string;
  volume: number;
  colorR: number;
  colorG: number;
  colorB: number;
  state?: MatterState;
}

export const NoContainer: ReagentContainer = {
  name: "No Beaker Inserted",
  contents: [],
  id: "inserted",
  maxVolume: 100,
  totalVolume: 0,
  finalColor: "#000000",
  temperature: freezeTemperature,
  fake: true,
};

interface ReagentInfoProps extends BoxProps {
  /**
   * The reagent container object to use. The ui_describe_reagents proc can generate an object like this.
   */
  container: ReagentContainer | null;
  /**
   * Optional sort function for the reagents.
   */
  sort?: (a: Reagent, b: Reagent) => number;
}

interface ReagentGraphProps extends ReagentInfoProps {}

export const ReagentGraph = (props: ReagentGraphProps) => {
  const {
    className: _className,
    height,
    sort,
    ...rest
  } = props;
  const container = props.container ?? NoContainer;
  const { contents = [], maxVolume, totalVolume, finalColor } = container;
  const maybeSortedContents = sort ? [...contents].sort(sort): contents;
  rest.height = height || "50px";

  return (
    <Box {...rest}>
      <Flex height="100%" direction="column">
        <Flex.Item grow>
          <Flex height="100%">
            {maybeSortedContents.map(reagent => (
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
              <Tooltip content={`Nothing${container.fake ? "" : ` (${maxVolume - totalVolume}u)`}`} position="bottom">
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
              backgroundColor={maybeSortedContents.length ? finalColor : "rgba(0, 0, 0, 0.1)"}
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
  /**
   * Allows you to render elements (such as buttons) for each reagent in the list.
   */
  renderButtons?(reagent: Reagent): InfernoNode;
  /**
   * If you are using the renderButtons property, and you want the buttons to change based on certain dependency
   * value(s), pass the value(s) to this property (in an array if there are multiple dependency values).
   */
  renderButtonsDeps?: string | number | boolean | (string | number | boolean)[];
  /**
   * Whether or not to show the matter state of the elements in the list.
   */
  showState?: BooleanLike;
}

export const ReagentList = (props: ReagentListProps) => {
  const {
    className = '',
    renderButtons,
    sort,
    showState,
    height,
    ...rest
  } = props;
  const container = props.container ?? NoContainer;
  const { contents = [] } = container;
  const maybeSortedContents = sort ? [...contents].sort(sort): contents;
  rest.height = height || 6;

  return (
    <Section scrollable={height !== "auto"}>
      <Box {...rest}>
        {maybeSortedContents.length ? contents.map(reagent => (
          <Flex key={reagent.id} mb={0.2} align="center">
            <Flex.Item grow>
              <Icon
                pr={showState && reagent.state ? MatterStateIconMap[reagent.state].pr : 0.9}
                name={showState && reagent.state ? MatterStateIconMap[reagent.state].icon : "circle"}
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
  if (a === b) return false;
  // eslint-disable-next-line sonarjs/prefer-single-boolean-return
  if (!a
      || !b
      || a.volume !== b.volume
      || a.name !== b.name
      || a.id !== b.id
      || a.colorR !== b.colorR
      || a.colorG !== b.colorG
      || a.colorB !== b.colorB) return true; // a property used by ReagentGraph/List has changed, update
  return false;
};

const containerCheck = (a: ReagentContainer | null, b: ReagentContainer| null): boolean => {
  if (a === b) return false; // same object or both null, no update
  if (a === null || b === null) return true; // only one object is null, update
  if (a.totalVolume !== b.totalVolume
      || a.finalColor !== b.finalColor
      || a.maxVolume !== b.maxVolume) return true; // a property used by ReagentGraph/List has changed, update
  if (a.contents?.length !== b.contents?.length) return true; // different number of reagents, update
  if (a.contents && b.contents) {
    for (let i = 0; i < a.contents.length; i++) {
      if (reagentCheck(a.contents[i], b.contents[i])) return true; // one of the reagents has changed, update
    }
  }
  return false;
};

// modified versions of the shallowDiffers function from common/react.ts
ReagentGraph.defaultHooks = {
  onComponentShouldUpdate: (a: ReagentGraphProps, b: ReagentGraphProps) => {
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
  },
};

ReagentList.defaultHooks = {
  onComponentShouldUpdate: (a: ReagentListProps, b: ReagentListProps) => {
    let i;
    for (i in a) {
      if (i === "container" || i === "renderButtons") continue;
      if (!(i in b)) {
        return true;
      }
    }
    for (i in b) {
      if (i === "container" || i === "renderButtons") continue;
      if (i === "renderButtonsDeps" && typeof a.renderButtonsDeps === 'object' && typeof b.renderButtonsDeps === 'object') {
        // The renderButtonsDeps is an array in the previous and next props, so perform a shallow difference check
        const aDeps = a.renderButtonsDeps;
        const bDeps = b.renderButtonsDeps;
        if (aDeps.length !== bDeps.length) {
          return true;
        }
        let j;
        for (j in aDeps) {
          if (aDeps[j] !== bDeps[j]) {
            return true;
          }
        }
        // There is no difference between the deps
        continue;
      }
      if (a[i] !== b[i]) {
        return true;
      }
    }
    return containerCheck(a.container, b.container);
  },
};

export const ReagentBar = (props: ReagentInfoProps) => {
  const {
    className = '',
    container,
    ...rest
  } = props;
  if (!container) {
    return null;
  }
  const { maxVolume, totalVolume, finalColor } = container;
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
