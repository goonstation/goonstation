/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Image, Section, Stack } from '../components';

export interface MapVoteMapData {
  name: string,
  thumbnail: string,
}

export interface MapVoteData {
  playersVoting: boolean,
  mapList: Array<MapVoteMapData>,
  clientVoteMap: any,
}

export const MapVote = (_props, context) => {
  const { data, act } = useBackend<MapVoteData>(context);
  const { playersVoting, mapList, clientVoteMap } = data;

  return (
    <Window height={220} width={(126 * mapList.length) + 6}>
      <Window.Content>
        <Stack>
          {mapList.map(map => (
            <MapPanel
              key={map.name}
              mapName={map.name}
              mapThumbnail={map.thumbnail}
              button={
                <Button.Checkbox
                  checked={clientVoteMap[map.name]}
                  color={clientVoteMap[map.name] ? "green" : "red"}
                  tooltip="Vote" />
              }
              onClick={() => act('toggle_vote', { map_name: map.name })}
              style={{cursor: "pointer"}}
              backgroundColor={clientVoteMap[map.name] ? "darkgreen" : null}
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
                onClick={() => act('all_yes')}>
                Vote Yes to All
              </Button.Checkbox>
              <Button.Checkbox
                color="red"
                onClick={() => act('all_no')}
                ml={1}>
                Vote No to All
              </Button.Checkbox>
            </>
          } />
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
        backgroundColor={props.backgroundColor}
        buttons={props.button}
        width="120px"
        align={props.button ? null : "center"}
        onClick={props.onClick}
        style={props.style}
      >
        <Box align="center">
          <Image src={props.mapThumbnail} backgroundColor="#0f0f0f" width="75px" />
        </Box>
        {props.children}
      </Section>
    </Stack.Item>
  );
};
