/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { Box, Stack } from '../../components';
// import { MapPanel } from '../MapVote';
import { MapVoteReportData } from './type';

export const MapVoteReport = (_props, context) => {
  const { data } = useBackend<MapVoteReportData>(context);
  const { mapList, winner } = data;

  return (
    <Window height={185} width={(126 * mapList.length) + 6}>
      <Window.Content>
        <Stack>
          {/* {mapList.map(map => {
            return (
              <MapPanel key={map.name} mapName={map.name} mapThumbnail={map.thumbnail} winner={map.name === winner}>
                <VoteCountLabel voteCount={map.count} />
                {map.voters && <Voters voters={map.voters} />}
              </MapPanel>
            );
          })} */}
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
      maxHeight={6}
      style={{
        'word-break': 'break-word',
        'overflow': 'hidden',
      }}
      align="left"
      fontSize={0.8}>
      {props.voters.join(', ')}
    </Box>
  );
};
