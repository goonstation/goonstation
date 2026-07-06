/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import {
  Collapsible,
  ColorBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { DisplayOccupiedProps } from './type';

interface DisplayMiscellaneousDetailsProps extends DisplayOccupiedProps {
  age: number;
  blood_type: string;
  blood_color_value: string;
  blood_color_name: string;
}

export const DisplayMiscellaneousDetails = (
  props: DisplayMiscellaneousDetailsProps,
) => {
  const { occupied, age, blood_type, blood_color_value, blood_color_name } =
    props;

  return (
    <Collapsible
      open
      sideIcon="question"
      fontSize={1.2}
      title="Miscellaneous Information"
      color={!occupied && 'grey'}
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <Stack>
            <Stack.Item width={20}>
              <Table>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Age:
                  </Table.Cell>
                  <Table.Cell>{age}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Blood Type:
                  </Table.Cell>
                  <Table.Cell>{blood_type}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Blood Color:
                  </Table.Cell>
                  <Table.Cell>
                    <ColorBox color={blood_color_value} content=" " />{' '}
                    <span>{blood_color_name}</span>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Stack.Item>
          </Stack>
        )}
      </Section>
    </Collapsible>
  );
};
