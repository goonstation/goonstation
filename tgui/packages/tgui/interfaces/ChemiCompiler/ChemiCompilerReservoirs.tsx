/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';

export const ChemiCompilerReservoirs = () => {
  const { act, data } = useBackend<ChemiCompilerData>();
  const { reservoirs } = data;
  return (
    <Section title="Reservoirs">
      <Stack wrap justify="center">
        {reservoirs.map((reservoir, index) => (
          <Stack.Item key={index} m={0.2}>
            <Button
              key={index}
              onClick={() => act('reservoir', { index })}
              width={8}
              icon="eject"
              tooltip={reservoir && 'Eject'}
              ellipsis
            >
              {reservoir || `None (${index + 1})`}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
