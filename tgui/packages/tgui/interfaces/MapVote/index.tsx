/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { Box, Button, Dimmer, Image, Section, Stack } from '../../components';
import { MapVoteData } from './type';


export const MapVote = (_props, context) => {
  const { data, act } = useBackend<MapVoteData>(context);
  const { playersVoting, mapList, clientVoteMap } = data;


  return (
    <Window height={270} width={106 * mapList.length + 6}>
      <Window.Content>

        <Stack>
          {mapList.map(map => (
            <MapPanel key={map.name} mapName={map.name} mapThumbnail={map.thumbnail}>
              <Button.Checkbox
                checked={clientVoteMap[map.name]}
                color={clientVoteMap[map.name] ? "green" : "red"}
                onClick={() => act('toggle_vote', { map_name: map.name })}
                mt={1}>
                {clientVoteMap[map.name] ? "Yes" : "No"}
              </Button.Checkbox>
            </MapPanel>
          ))}
        </Stack>

        <Section title="All" mt={1}>
          <Button.Checkbox
            checked
            color="green"
            onClick={() => act('all_yes')}>
            Vote Yes to All
          </Button.Checkbox>
          <Button.Checkbox
            color="red"
            onClick={() => act('all_no')}
            ml={1}>
            Vote No to All
          </Button.Checkbox>
        </Section>

        {!playersVoting && (<Dimmer fontSize={1.5}>Map Vote has ended</Dimmer>)}
      </Window.Content>
    </Window>
  );
};


export const MapPanel = (props) => {
  return (
    <Stack.Item>
      <Section
        title={props.mapName}
        textAlign="center"
        width="100px"
        backgroundColor={props.winner ? "#a17f1a" : null}
      >
        <Box>
          <Image src={props.mapThumbnail} backgroundColor="#0f0f0f" width="75px" />
        </Box>
        { props.children }
      </Section>
    </Stack.Item>
  );
};
