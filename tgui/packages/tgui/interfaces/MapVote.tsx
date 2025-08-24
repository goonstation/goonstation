/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { type ReactNode } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Image,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { computeBoxProps } from '../components/Box';
import { Window } from '../layouts';

interface MapVoteMapDetials {
  description: string;
  location: string;
  engine: string;
  mining: string;
  idealPlayers: string;
}

export interface MapVoteMapData {
  name: string;
  thumbnail: string;
  details: MapVoteMapDetials;
}

export interface MapVoteData {
  playersVoting: boolean;
  mapList: Array<MapVoteMapData>;
  clientVoteMap: any;
}

export const MAP_PANEL_WIDTH = 150;
export const SPACE_BETWEEN_PANELS = 6;
export const WINDOW_HOZ_PADDING = 12;
export const PANEL_PER_LINE = 4;

const BASE_HEIGHT = 100;
export const MAP_ROW_HEIGHT = 130;

export const MapVote = () => {
  const { data, act } = useBackend<MapVoteData>();
  const { playersVoting, mapList, clientVoteMap } = data;

  const height =
    BASE_HEIGHT + MAP_ROW_HEIGHT * Math.ceil(mapList.length / PANEL_PER_LINE);
  const width =
    (MAP_PANEL_WIDTH + SPACE_BETWEEN_PANELS) * PANEL_PER_LINE +
    WINDOW_HOZ_PADDING;

  return (
    <Window height={height} width={width}>
      <Window.Content scrollable>
        <Stack wrap justify="space-around">
          {mapList.map((map) => (
            <MapPanel
              key={map.name}
              name={map.name}
              thumbnail={map.thumbnail}
              details={map.details}
              button={
                <Button.Checkbox
                  checked={clientVoteMap[map.name]}
                  color={clientVoteMap[map.name] ? 'green' : 'red'}
                  tooltip="Vote"
                />
              }
              onClick={() => act('toggle_vote', { map_name: map.name })}
              style={{ cursor: 'pointer' }}
              voted={!!clientVoteMap[map.name]}
            />
          ))}
        </Stack>
        <Section
          title="All"
          mt={1}
          buttons={
            <>
              <Button.Checkbox
                checked
                color="green"
                onClick={() => act('all_yes')}
              >
                Vote Yes to All
              </Button.Checkbox>
              <Button.Checkbox color="red" onClick={() => act('all_no')} ml={1}>
                Vote No to All
              </Button.Checkbox>
            </>
          }
        />
        {!playersVoting && <Dimmer fontSize={1.5}>Map Vote has ended</Dimmer>}
      </Window.Content>
    </Window>
  );
};

type MapPanelProps = Pick<MapVoteMapData, 'name' | 'thumbnail' | 'details'> & {
  voted?: boolean;
  won?: boolean;
  button?: ReactNode;
  onClick?: () => void;
  style?: Record<string, string>;
  children?: ReactNode;
};

export const MapPanel = (props: MapPanelProps) => {
  const { name, thumbnail, details, button, children, voted, won, ...rest } =
    props;

  const panel = (
    <Section
      title={
        <Box
          inline
          nowrap
          overflow="hidden"
          style={{ textOverflow: 'ellipsis' }}
          maxWidth={`${MAP_PANEL_WIDTH - 35}px`}
        >
          {name}
        </Box>
      }
      className={`MapPanel ${voted ? 'MapPanel--voted' : ''} ${won ? 'MapPanel--won' : ''}`}
      buttons={button}
      width={`${MAP_PANEL_WIDTH}px`}
      align={button ? null : 'center'}
      mb={1}
      {...computeBoxProps(rest)}
    >
      <Box align="center">
        <Image src={thumbnail} backgroundColor="#0f0f0f" width="75px" />
      </Box>
      {children}
    </Section>
  );

  return (
    <Stack.Item mx={`${SPACE_BETWEEN_PANELS / 2}px`}>
      {details ? (
        <Tooltip content={<MapPanelTooltip name={name} details={details} />}>
          {panel}
        </Tooltip>
      ) : (
        panel
      )}
    </Stack.Item>
  );
};

type MapPanelTooltipProps = Pick<MapVoteMapData, 'name' | 'details'>;

const MapPanelTooltip = (props: MapPanelTooltipProps) => {
  const { name, details } = props;
  return (
    <>
      <strong>{name}</strong>
      <br />
      {details.description}
      <br />
      <strong>Location:</strong> {details.location}
      <br />
      <strong>Engine:</strong> {details.engine}
      <br />
      <strong>Mining:</strong> {details.mining}
      <br />
      <strong>Ideal Players:</strong> {details.idealPlayers}
      <br />
    </>
  );
};
