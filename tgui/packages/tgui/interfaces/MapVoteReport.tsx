/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Box, Stack } from '../components';
import { MapPanel } from './MapVote';
import { MapVoteMapData } from './MapVote';

interface MapVoteReportMapData extends MapVoteMapData {
  count: number,
  voters?: Array<string>
}

export interface MapVoteReportData {
  mapList: Array<MapVoteReportMapData>,
  winner: string,
  isDetailed: boolean
}

const MAP_PANEL_WIDTH = 180;
const SPACE_BETWEEN_PANELS = 5;
const WINDOW_HOZ_PADDING = 12;
const PANEL_PER_LINE = 4;

const BASE_HEIGHT = 70;
const MAP_ROW_HEIGHT = 130;
const VOTERS_HEIGHT = 80;

export const MapVoteReport = (_props, context) => {
  const { data } = useBackend<MapVoteReportData>(context);
  const { mapList, winner, isDetailed } = data;

  const height = BASE_HEIGHT
    + MAP_ROW_HEIGHT * (!isDetailed ? Math.ceil(mapList.length / 4) : 1)
    + (!isDetailed ? 0 : VOTERS_HEIGHT);
  const width = (MAP_PANEL_WIDTH + SPACE_BETWEEN_PANELS) * (!isDetailed ? PANEL_PER_LINE : mapList.length)
    + WINDOW_HOZ_PADDING;

  return (
    <Window height={height} width={width}>
      <Window.Content>
        <Stack
          wrap={!isDetailed}
          justify={!isDetailed ? "space-around" : null}>
          {mapList.map(map => {
            return (
              <MapPanel
                key={map.name}
                mapName={map.name}
                mapThumbnail={map.thumbnail}
                backgroundColor={map.name === winner ? "#a17f1a" : null}
                mb={1}
                details={map.details}>
                <VoteCountLabel voteCount={map.count} />
                {isDetailed && <Voters voters={map.voters} />}
              </MapPanel>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const VoteCountLabel = props => {
  return (
    <Box size={1.5} bold>
      {props.voteCount || 0} vote{props.voteCount > 1 && "s"}
    </Box>
  );
};

const Voters = props => {
  return (
    <Box
      scrollable
      height={`${VOTERS_HEIGHT}px`}
      overflow="auto"
      align="left">
      {props.voters && props.voters.join(<br />)}
    </Box>
  );
};
