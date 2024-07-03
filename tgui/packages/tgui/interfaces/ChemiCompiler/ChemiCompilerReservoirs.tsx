/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';
import { Button, Icon, Section, Stack } from '../../components';

export const ChemiCompilerReservoirs = (_props, context) => {
  const { act, data } = useBackend<ChemiCompilerData>(context);
  const { reservoirs } = data;
  return (
    <Section title="Reservoirs">
      <Stack wrap justify="center">
        {reservoirs.map((reservoir, index) => (
          <Stack.Item key={index} m={0.5}>
            <Button
              key={index}
              onClick={() => act('reservoir', { index })}
              width={8}
              tooltip={reservoir && "Eject"}
              ellipsis>
              <Icon name="eject" />
              {
                reservoir || <>None ({index + 1})</>
              }
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
