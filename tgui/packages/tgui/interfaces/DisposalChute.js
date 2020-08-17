/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, NoticeBox, ProgressBar, Search } from '../components';
import { Window } from '../layouts';

const DisposalChuteState = {
  Off: 0,
  Charging: 1,
  Charged: 2,
};

export const DisposalChute = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    name,
    destinations = null,
    destinationTag,
  } = data;

  return (
    <Window
      resizable
      title={name}
      width={360}
      height={destinations ? 350 : 220}>
      <Window.Content scrollable={destinations}>
        <PumpStatus />
        <PumpControl />
        <EjectButton />
        <Divider />
        <PressureStatus />
        <Divider />
        <ToggleHandle />
        {destinations && (
          <>
            <Box mb="0.5em">
              <strong>Current Destination: {destinationTag}</strong>
            </Box>
            <Box mb="0.5em">
              <Button
                icon="search"
                content="Rescan Destinations"
                onClick={() => act('rescanDest')}
              />
            </Box>
            <DestinationSearch destinations={destinations} destinationTag={destinationTag} />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const PumpStatus = (props, context) => {
  const { data } = useBackend(context);
  const { mode } = data;

  return (
    <NoticeBox
      info={mode===DisposalChuteState.Off}
      danger={mode===DisposalChuteState.Charging}
      success={mode===DisposalChuteState.Charged}
      textAlign="center"
    >
      Pump Status: {mode===DisposalChuteState.Charged ? 'Ready' : (mode===DisposalChuteState.Charging ? 'Pressurizing' : 'Inactive')}
    </NoticeBox>
  );
};

const PumpControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mode,
  } = data;
  return (
    <Box mb="0.5em">
      <strong>Air Pump </strong>
      <Button
        icon="power-off"
        content={mode ? 'Enabled' : 'Disabled'}
        onClick={() => act('togglePump')}
      />
    </Box>
  );
};

const EjectButton = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Box mb="0.5em">
      <Button
        content="Eject Contents"
        icon="eject"
        onClick={() => act('eject')} />
   </Box>
  );
};

const ranges = {
  good: [1, Infinity],
  average: [0.75, 1],
  bad: [-Infinity, 0.75],
};

const PressureStatus = (props, context) => {
  const { data } = useBackend(context);
  const { pressure } = data;
  return (
    <>
      <Box mb="0.5em">
        <strong>Current Pressure</strong>
      </Box>
      <ProgressBar
        ranges={ranges}
        value={pressure} />
    </>
  );
};

const ToggleHandle = (props, context) => {
  const { act, data } = useBackend(context);
  const { destinations, flush } = data;
  return (
    <Box mb="0.5em">
      <strong>Disposal Handle </strong>
      <Button
        icon={destinations ? "envelope" : "trash-alt"}
        content={flush ? "Engaged" : "Disengaged"}
        onClick={() => act('toggleHandle')}
      />
     </Box>
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
  const filteredDestinations = destinations.filter(destination => destination.includes(searchText));
  return (
    <Search
      currentSearch={searchText}
      onSearch={setSearchText}
      onSelect={handleSelectDestination}
      options={filteredDestinations}
      selectedOption={destinationTag}
    />
  );
};
