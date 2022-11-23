import { useBackend } from '../backend';
import { Box, Section, Divider, Button, Table, BlockQuote } from '../components';
import { Window } from '../layouts';

export const TransitShuttle = (props, context) => {
  const { act, data } = useBackend(context);
  const destinations = data.destinations || [];
  const currentlocation = data.currentlocation || [];
  const endlocation = data.endlocation || [];

  const {
    shuttlename,
    moving,
    locked,
  } = data;

  let traveltext = `the ${shuttlename} is currently at ${currentlocation.name}`;
  if (moving && endlocation) {
    traveltext += ` moving to ${endlocation.name}`;
  }

  return (
    <Window height="520" width="300" title={shuttlename} >
      <BlockQuote style={{ "margin": "5px" }}>{traveltext}</BlockQuote>
      <Section fill scrollable height="100%">
        {destinations.map(Destination => {
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
