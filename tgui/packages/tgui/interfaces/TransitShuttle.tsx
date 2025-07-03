import { BlockQuote, Button, Divider, Section } from 'tgui-core/components';
import { Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface TransitShuttleData {
  shuttlename;
  moving;
  locked;
  destinations;
  currentlocation;
  endlocation;
}

export const TransitShuttle = () => {
  const { act, data } = useBackend<TransitShuttleData>();
  const destinations = data.destinations || [];
  const currentlocation = data.currentlocation || [];
  const endlocation = data.endlocation || [];

  const { shuttlename, moving, locked } = data;

  let traveltext = `the ${shuttlename} is currently at ${currentlocation.name}`;
  if (moving && endlocation) {
    traveltext += ` moving to ${endlocation.name}`;
  }

  return (
    <Window height={520} width={300} title={shuttlename}>
      <BlockQuote style={{ margin: '5px' }}>{traveltext}</BlockQuote>
      <Section fill scrollable height="100%">
        {destinations.map((Destination) => {
          return (
            <>
              <Table align="center" key={Destination.type}>
                <Table.Row>
                  <Table.Cell>
                    <Button
                      disabled={
                        locked ||
                        moving ||
                        currentlocation.type === Destination.type
                      }
                      onClick={() =>
                        act('callto', {
                          dest: Destination.type,
                        })
                      }
                    >
                      {Destination.name}
                    </Button>
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
