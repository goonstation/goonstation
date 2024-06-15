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
import { MAP_PANEL_WIDTH, MAP_ROW_HEIGHT, PANEL_PER_LINE, SPACE_BETWEEN_PANELS, WINDOW_HOZ_PADDING } from './MapVote';
import { BooleanLike } from 'common/react';

interface MapVoteReportMapData extends MapVoteMapData {
  count: number,
  voters?: Array<string>
}

export interface MapVoteReportData {
  mapList: Array<MapVoteReportMapData>,
  winner: string,
  isDetailed: BooleanLike
}

const BASE_HEIGHT = 70;
const VOTERS_HEIGHT = 80;

export const MapVoteReport = (_props, context) => {
  const { data } = useBackend<MapVoteReportData>(context);
  const { mapList, winner, isDetailed } = data;

  const height = BASE_HEIGHT
    + MAP_ROW_HEIGHT * (!isDetailed ? Math.ceil(mapList.length / PANEL_PER_LINE) : 1)
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
                details={map.details}>
                <VoteCountLabel voteCount={map.count} />
                {!!isDetailed && <Voters voters={map.voters} />}
              </MapPanel>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface VoteCountLabelProps {
  voteCount: number;
}

const VoteCountLabel = (props: VoteCountLabelProps) => {
  return (
    <Box size={1.5} bold>
      {props.voteCount || 0} vote{props.voteCount > 1 && "s"}
    </Box>
  );
};

interface VotersProps {
  voters: Array<string>
}

const Voters = (props: VotersProps) => {
  return (
    <Box
      scrollable
      height={`${VOTERS_HEIGHT}px`}
      overflow="auto"
      align="left">
      {props.voters && props.voters.map(voter => (<>{voter}<br /></>))}
    </Box>
  );
};
