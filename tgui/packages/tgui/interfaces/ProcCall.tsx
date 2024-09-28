/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { Box, Button, Flex, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { DataInputOptions } from './common/DataInput';

interface ProcCallData {
  name;
  options;
}

export const ProcCall = () => {
  const { act, data } = useBackend<ProcCallData>();
  const { name, options } = data;

  return (
    <Window title="Proc Call" width={700} height={600}>
      <Window.Content scrollable>
        <Section title={name}>
          <Flex direction="row">
            <Flex.Item ml={1}>
              <DataInputOptions options={options} />
            </Flex.Item>
          </Flex>
          <Box m={1}>
            <Button fluid onClick={() => act('activate')}>
              Confirm Event
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
