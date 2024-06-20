import { useBackend } from '../backend';
import { Button, Divider, LabeledList, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

export const VRRaceControl = (props, context) => {
  const { act, data } = useBackend(context);
  const race_results = data.race_results|| [];

  const {
    Active,
  } = data;

  return (
    <Window height="520" width="460" title="VR Race Console">
      <Window.Content>
        <Stack vertical fill minHeight="1%" maxHeight="100%">

          <Stack.Item my={1}>
            <Stack textAlign="center">
              <Stack.Item grow mx={2}>
                <Button fluid color="good" disabled={Active} content="Start Race"
                  onClick={() => act("start_race", {})} />
              </Stack.Item>
              <Stack.Item grow mx={2}>
                <Button fluid color="bad" disabled={!Active} content="End Race"
                  onClick={() => act("end_race", {})} />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow minHeight="1%" maxHeight="100%">
            <Section fill scrollable height="100%" title="Last Race">
              {race_results.map((result, position) => {
                return (
                  <>
                    <Table direction="row" align="center" key={result.driver}>
                      <Table.Row>
                        <Table.Cell align="center">
                          <LabeledList direction="column">
                            <LabeledList.Item label={`${result.place}: "${result.driver}" `} />
                          </LabeledList>
                          <Stack fill my={1}>
                            {(result.times).map((time, v) => {
                              return (
                                <Stack.Item grow key={result} >{`Lap ${v+1}: ${time}`}</Stack.Item>
                              ); })}
                          </Stack>
                        </Table.Cell>
                      </Table.Row>
                    </Table>
                    <Divider />
                  </>
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
