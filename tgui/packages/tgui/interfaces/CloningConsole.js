import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, NoticeBox, Tabs, Flex, Icon, ProgressBar, AnimatedNumber } from '../components';
import { Window } from '../layouts';

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { proper_name } = "data";
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  const records = data.clone_records || [];
  return (
    <Window
      width={440}
      height={250}>
      <Window.Content scrollable>
        {(!!proper_name && (
          <NoticeBox textAlign="center">
            {proper_name} Cloning Console
          </NoticeBox>
        ))}
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => {
              setTabIndex(1);
              act('check-records');
            }}>
            Records
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => {
              setTabIndex(2);
              act('check-functions');
            }}>
            Functions
          </Tabs.Tab>
        </Tabs>
        <Section>
          <ProgressBar>
            value={0.5}
            <AnimatedNumber value={10} />%
          </ProgressBar>
          <Button
            content={"Scan"}
            onClick={() => act('scan')} />
          <i>{error_message}</i>
        </Section>
        <Section>
          <LabeledList>
            {records.map(record => (
              <LabeledList.Item
                key={record.id}
                className="LblRecord"
                label={record.id + "-" + record.name}
                labelColor={record.color}
                color={record.color}
                buttons={(
                  <Button
                    content={"Clone"}
                    onClick={() => act('clone', {
                      wire: record.color,
                    })} />
                )}>
                {!!record.health && (
                  <i>
                    ({record.health})
                  </i>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
