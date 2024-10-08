/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Box } from '../components';
import { Window } from '../layouts';
import { MapPanel } from './MapVote';
import { MapVoteMapData } from './MapVote';
import {
  MAP_PANEL_WIDTH,
  MAP_ROW_HEIGHT,
  PANEL_PER_LINE,
  SPACE_BETWEEN_PANELS,
  WINDOW_HOZ_PADDING,
} from './MapVote';

interface MapVoteReportMapData extends MapVoteMapData {
  count: number;
  voters?: Array<string>;
}

export interface MapVoteReportData {
  mapList: Array<MapVoteReportMapData>;
  winner: string;
  isDetailed: BooleanLike;
}

const BASE_HEIGHT = 70;
const VOTERS_HEIGHT = 80;

export const MapVoteReport = () => {
  const { data } = useBackend<MapVoteReportData>();
  const { mapList, winner, isDetailed } = data;

  const height =
    BASE_HEIGHT +
    MAP_ROW_HEIGHT *
      (!isDetailed ? Math.ceil(mapList.length / PANEL_PER_LINE) : 1) +
    (!isDetailed ? 0 : VOTERS_HEIGHT);
  const width =
    (MAP_PANEL_WIDTH + SPACE_BETWEEN_PANELS) *
      (!isDetailed ? PANEL_PER_LINE : mapList.length) +
    WINDOW_HOZ_PADDING;

  return (
    <Window height={height} width={width}>
      <Window.Content>
        <Stack
          wrap={!isDetailed}
          justify={!isDetailed ? 'space-around' : undefined}
        >
          {mapList.map((map) => {
            return (
              <MapPanel
                key={map.name}
                name={map.name}
                details={map.details}
                thumbnail={map.thumbnail}
                won={map.name === winner}
              >
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

type VoteCountLabelProps = {
  voteCount: number;
};

const VoteCountLabel = (props: VoteCountLabelProps) => {
  const { voteCount } = props;
  return (
    <Box size={1.5} bold>
      {voteCount || 0} vote{voteCount > 1 && 's'}
    </Box>
  );
};

type VotersProps = Pick<MapVoteReportMapData, 'voters'>;

const Voters = (props: VotersProps) => {
  const { voters } = props;
  return (
    <Box scrollable height={`${VOTERS_HEIGHT}px`} overflow="auto" align="left">
      {voters &&
        voters.map((voter) => (
          <>
            {voter}
            <br />
          </>
        ))}
    </Box>
  );
};
