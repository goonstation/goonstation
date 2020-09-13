/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend, useLocalState } from '../backend';
import { Box, Button, ProgressBar, Search, LabeledList, Divider } from '../components';
import { Window } from '../layouts';

export const DisposalChute = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    name,
    destinations = null,
    destinationTag,
    flush,
    mode,
    pressure,
  } = data;

  const DisposalChuteState = {
    Off: 0,
    Charging: 1,
    Charged: 2,
  };

  const pumpState = (
    (mode===DisposalChuteState.Charged && 'good')
    || (mode===DisposalChuteState.Charging && 'average')
    || 'bad'
  );

  return (
    <Window
      title={name}
      width={355}
      height={destinations ? 350 : 140}>
      <Window.Content scrollable={destinations}>
        <LabeledList>
          <LabeledList.Item label="Current Pressure" />
        </LabeledList>
        <ProgressBar
          mt="0.5em"
          ranges={{
            good: [1, Infinity],
            average: [0.75, 1],
            bad: [-Infinity, 0.75],
          }}
          value={pressure} />
        <Divider />
        <LabeledList>
          <LabeledList.Item
            label="Air Pump"
            buttons={
              <Button
                icon="power-off"
                content={mode ? 'Enabled' : 'Disabled'}
                color={mode ? 'green' : 'red'}
                onClick={() => act('togglePump')} />
            } >
            <Box color={pumpState} >
              {(mode===DisposalChuteState.Charged && 'Ready')
               || (mode===DisposalChuteState.Charging && 'Pressurizing')
               || 'Inactive'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label="Chute Handle"
            buttons={
              <Button
                icon={destinations ? "envelope" : "trash-alt"}
                content={flush ? "Flushing" : "Flush"}
                color={flush ? '' : 'red'}
                onClick={() => act('toggleHandle')} />
            } >
            <Button
              content="Eject Contents"
              icon="eject"
              onClick={() => act('eject')} />
          </LabeledList.Item>
        </LabeledList>
        {destinations && (
          <>
            <Divider />
            <LabeledList>
              <LabeledList.Item
                label="Destination"
                buttons={
                  <Button
                    icon="search"
                    content="Rescan"
                    onClick={() => act('rescanDest')} />
                } >
                {destinationTag}
              </LabeledList.Item>
            </LabeledList>
            <Box mt="0.5em">
              <DestinationSearch
                destinations={destinations}
                destinationTag={destinationTag} />
            </Box>
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const DestinationSearch = (props, context) => {
  const {
    destinations = [],
    destinationTag = null,
  } = props;
  const { act } = useBackend(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const handleSelectDestination = destination => act('select-destination', {
    destination,
  });
  const filteredDestinations = (
    destinations.filter(destination => destination.includes(searchText))
  );
  return (
    <Search
      autoFocus
      currentSearch={searchText}
      onSearch={setSearchText}
      onSelect={handleSelectDestination}
      options={filteredDestinations}
      selectedOption={destinationTag}
    />
  );
};
