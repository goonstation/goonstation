/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Collapsible, Section, Stack, Table } from 'tgui-core/components';

import { capitalize, spaceUnderscores } from '../stringUtils';
import { DisplayOccupiedProps, ImplantData } from './type';

type DisplayImplantsProps = DisplayOccupiedProps & {
  implants: ImplantData[] | null;
};

export const DisplayImplants = (props: DisplayImplantsProps) => {
  const { occupied, implants } = props;
  return (
    <Collapsible
      title="Embedded Implants"
      open
      color={!occupied && 'grey'}
      sideIcon="thermometer"
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <Stack.Item width={20}>
            {!implants && 'No Implants Detected.'}
            {!!implants && implants.length === 0 && 'No Implants Detected.'}
            {!!implants && implants.length > 0 && (
              <Table>
                {implants.map((implant_data: ImplantData) => {
                  return <DisplayImplant implant={implant_data} />;
                })}
              </Table>
            )}
          </Stack.Item>
        )}
      </Section>
    </Collapsible>
  );
};

interface DisplayImplantProps {
  implant: ImplantData;
}

export const DisplayImplant = (props: DisplayImplantProps) => {
  const { implant } = props;
  return (
    <Table.Row>
      <Table.Cell textAlign="right">{implant.implant_count}x</Table.Cell>
      <Table.Cell>
        {capitalize(spaceUnderscores(implant.implant_name))}
      </Table.Cell>
    </Table.Row>
  );
};
