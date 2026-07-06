/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Collapsible, Section, Stack, Table } from 'tgui-core/components';

import { capitalize, spaceUnderscores } from '../stringUtils';
import { DisplayOccupiedProps, ImplantData } from './type';

interface DisplayImplantsProps extends DisplayOccupiedProps {
  implants: ImplantData[] | null;
}

export const DisplayImplants = (props: DisplayImplantsProps) => {
  const { occupied, implants } = props;
  return (
    <Collapsible
      title="Emedded Implants"
      fontSize={1.2}
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
                <Table.Row>
                  <Table.Cell header textAlign="right">
                    Count
                  </Table.Cell>
                  <Table.Cell header>Implant Name</Table.Cell>
                </Table.Row>
                {implants.map((implant_data: ImplantData) => {
                  return (
                    <DisplayImplant
                      key={implant_data['implant_name']}
                      implant_name={implant_data['implant_name']}
                      implant_count={implant_data['implant_count']}
                    />
                  );
                })}
              </Table>
            )}
          </Stack.Item>
        )}
      </Section>
    </Collapsible>
  );
};

export const DisplayImplant = (props: ImplantData) => {
  const { implant_name, implant_count } = props;
  return (
    <Table.Row>
      <Table.Cell textAlign="right">{implant_count}x</Table.Cell>
      <Table.Cell>{capitalize(spaceUnderscores(implant_name))}</Table.Cell>
    </Table.Row>
  );
};
