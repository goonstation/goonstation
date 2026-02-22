/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { capitalize } from '../../../common/string';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Allowed, ChemRequestReceiverData, RequestData } from './type';

interface ChemRequestProps extends RequestData {
  interactable: Allowed;
}

const ChemRequest = (props: ChemRequestProps) => {
  const { act } = useBackend();
  const {
    name,
    id,
    reagent_name,
    reagent_color,
    volume,
    notes,
    area,
    state,
    interactable,
    age,
  } = props;
  const color_string = reagent_color
    ? 'rgba(' +
      reagent_color[0] +
      ',' +
      reagent_color[1] +
      ', ' +
      reagent_color[2] +
      ', 1)'
    : undefined;
  const resolvedReagentName = reagent_name
    ? capitalize(reagent_name)
    : '(Unknown)';
  return (
    <Section>
      <Flex direction="column" height={10}>
        <Flex.Item grow={1}>
          <Stack vertical>
            <Stack.Item>{name} requested</Stack.Item>
            <Stack.Item align="center">
              <Box width={16} textAlign="center">
                <Icon
                  color={color_string}
                  name={'circle'}
                  pt={1}
                  style={{
                    textShadow: '0 0 3px #000',
                  }}
                  mr={1}
                />
                {`${resolvedReagentName} (${volume}u)`}
              </Box>
            </Stack.Item>
            <Stack.Item>
              from {area} {age} ago. <br /> {notes && `Notes: ${notes}`}
            </Stack.Item>
          </Stack>
        </Flex.Item>
        <Flex.Item>
          <Box>
            {state === 'pending' && (
              <>
                <Button
                  disabled={!interactable}
                  align="center"
                  width="49.5%"
                  color="red"
                  icon="ban"
                  onClick={() => {
                    act('deny', { id: id });
                  }}
                >
                  Deny
                </Button>
                <Button
                  disabled={!interactable}
                  align="center"
                  width="49.5%"
                  icon="check"
                  onClick={() => {
                    act('fulfil', { id: id });
                  }}
                >
                  Mark as fulfilled
                </Button>
              </>
            )}
            {state !== 'pending' && (
              <Box
                align="center"
                backgroundColor={state === 'denied' ? 'red' : 'green'}
              >
                {capitalize(state)}
              </Box>
            )}
          </Box>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const ChemRequestReceiver = () => {
  const { data } = useBackend<ChemRequestReceiverData>();
  const [tabIndex, setTabIndex] = useState(1);
  const { requests, allowed } = data;
  let request_index = 0;
  return (
    <Window title="Chemical requests" width={600} height={600}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            Pending
          </Tabs.Tab>
          <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
            History
          </Tabs.Tab>
        </Tabs>
        <Stack wrap="wrap">
          {requests.map((request) => {
            if (
              (request.state === 'pending' && tabIndex === 1) ||
              (request.state !== 'pending' && tabIndex === 2)
            ) {
              return (
                <Stack.Item
                  py={1}
                  width={23}
                  key={request.id}
                  ml={request_index++ === 0 ? 1 : undefined}
                >
                  <ChemRequest interactable={allowed} {...request} />
                </Stack.Item>
              );
            }
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
