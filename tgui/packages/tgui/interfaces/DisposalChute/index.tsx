/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  LabeledList,
  ProgressBar,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ListSearch } from '../common/ListSearch';
import {
  DisposalChuteConfigLookup,
  DisposalChuteData,
  DisposalChuteState,
} from './type';

const disposalChuteConfigLookup: DisposalChuteConfigLookup = {
  [DisposalChuteState.Off]: {
    pumpColor: 'bad',
    pumpText: 'Inactive',
  },
  [DisposalChuteState.Charging]: {
    pumpColor: 'average',
    pumpText: 'Pressurizing',
  },
  [DisposalChuteState.Charged]: {
    pumpColor: 'good',
    pumpText: 'Ready',
  },
};

export const DisposalChute = () => {
  const { act, data } = useBackend<DisposalChuteData>();
  const {
    name,
    destinations = null,
    destinationTag,
    flush,
    mode,
    pressure,
  } = data;

  const disposalChuteConfig = disposalChuteConfigLookup[mode];
  const { pumpColor, pumpText } = disposalChuteConfig;

  return (
    <Window title={name} width={355} height={destinations ? 350 : 140}>
      <Window.Content
        className="disposal-chute-interface"
        scrollable={!!destinations}
      >
        <Stack vertical>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Current Pressure" />
            </LabeledList>
          </Stack.Item>
          <Stack.Item>
            <ProgressBar
              ranges={{
                good: [1, Infinity],
                average: [0.75, 1],
                bad: [-Infinity, 0.75],
              }}
              value={pressure}
            />
          </Stack.Item>
        </Stack>
        <Divider />
        <LabeledList>
          <LabeledList.Item
            label="Air Pump"
            buttons={
              <Button
                icon="power-off"
                color={mode ? 'green' : 'red'}
                onClick={() => act('togglePump')}
              >
                {mode ? 'Enabled' : 'Disabled'}
              </Button>
            }
          >
            <Box color={pumpColor}>{pumpText}</Box>
          </LabeledList.Item>
          <LabeledList.Item
            label="Chute Handle"
            buttons={
              <Button
                icon={destinations ? 'envelope' : 'trash-alt'}
                color={flush ? '' : 'red'}
                onClick={() => act('toggleHandle')}
              >
                {flush ? 'Flushing' : 'Flush'}
              </Button>
            }
          >
            <Button icon="eject" onClick={() => act('eject')}>
              Eject Contents
            </Button>
          </LabeledList.Item>
        </LabeledList>
        {!!destinations && (
          <>
            <Divider />
            <Stack vertical>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item
                    label="Destination"
                    buttons={
                      <Button icon="search" onClick={() => act('rescanDest')}>
                        Rescan
                      </Button>
                    }
                  >
                    {destinationTag}
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
              <Stack.Item>
                <DestinationSearch
                  destinations={destinations}
                  destinationTag={destinationTag}
                />
              </Stack.Item>
            </Stack>
          </>
        )}
      </Window.Content>
    </Window>
  );
};

interface DestinationSearchProps {
  destinations: string[];
  destinationTag: string;
}

const DestinationSearch = (props: DestinationSearchProps) => {
  const { destinations = [], destinationTag } = props;
  const { act } = useBackend();

  const [searchText, setSearchText] = useState('');
  const handleSelectDestination = (destination: string) =>
    act('select-destination', {
      destination,
    });

  const filteredDestinations = destinations.filter((destination) =>
    destination.includes(searchText),
  );

  return (
    <ListSearch
      autoFocus
      currentSearch={searchText}
      onSearch={setSearchText}
      onSelect={handleSelectDestination}
      options={filteredDestinations}
      selectedOption={destinationTag}
    />
  );
};
