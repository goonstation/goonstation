/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { Box, Stack } from '../../components';
import { MapPanel } from '../MapVote';
import { MapVoteReportData } from './type';

export const MapVoteReport = (_props, context) => {
  const { data } = useBackend<MapVoteReportData>(context);
  const { mapList } = data;

  return (
    <Window height={185} width={106 * mapList.length + 6}>
      <Window.Content>
        <Stack>
          {mapList.map(map => {
            return (
              <MapPanel key={map.name} mapName={map.name} mapThumbnail={map.thumbnail}>
                <VoteCountLabel voteCount={map.count} voters={map.voters} />
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
    <Box
      as="span"
      size={1.5}
      bold
      style={props.tooltipped && { "border-bottom": "1px dotted" }}>
      {props.voteCount || 0} vote{props.voteCount > 1 && "s"}
      {props.voters && (
        <Box
          scrollable
          maxHeight={6}
          style={{
            'word-break': 'break-word',
            'overflow': 'hidden',
          }}
          align="left"
          fontSize={0.8}
          bold={false}>
          {props.voters.join(', ')}
        </Box>
      )}
    </Box>
  );
};
