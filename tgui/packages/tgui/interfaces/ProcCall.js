/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { DataInputOptions } from './common/DataInput';
import { Window } from '../layouts';

export const ProcCall = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    options,
  } = data;


  return (
    <Window
      title="Proc Call"
      width={700}
      height={600}>
      <Window.Content scrollable>
        <Section title={name}>
          <Flex direction="row">
            <Flex.Item ml={1}>
              <DataInputOptions
                options={options}
              />
            </Flex.Item>
          </Flex>
          <Box m={1}>
            <Button
              fluid
              onClick={() => act("activate")}
            >
              Confirm Event
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
