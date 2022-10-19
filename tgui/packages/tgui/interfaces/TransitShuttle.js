import { useBackend } from '../backend';
import { Box, Section, Divider, Button, Table, BlockQuote } from '../components';
import { Window } from '../layouts';
import { ReagentBlocks } from './EspressoMachine';

export const TransitShuttle = (props, context) => {
  const { act, data } = useBackend(context);
  const Destinations = data.Destinations || [];
  const currentlocation = data.currentlocation || [];

  const {
    shuttlename,
    moving,
    locked,
  } = data;
  return (
    <Window height="520" width="300" title={shuttlename} >
      <BlockQuote>the {shuttlename} is currently at {currentlocation.name}
      </BlockQuote>
      <Section fill scrollable height="100%">
        {Destinations.map(Destination => {
          return (
            <>
              <Table direction="row" align="center" key={Destination.type}>
                <Table.Row>
                  <Table.Cell>
                    <Button
                      content={Destination.name}
                      disabled={locked || moving || (currentlocation.type === Destination.type)}
                      onClick={() => act('callto', {
                        dest: Destination.type })}
                    />
                  </Table.Cell>
                </Table.Row>
              </Table>
              <Divider />
            </>
          );
        })}
      </Section>
    </Window>
  );
};
