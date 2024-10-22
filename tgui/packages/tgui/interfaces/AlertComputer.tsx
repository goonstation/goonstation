import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface AlertComputerData {
  PriorityList: AlertData[];
  MinorList: AlertData[];
}

interface AlertData {
  area_name: string;
  area_ckey: string;
}

export const AlertComputer = () => {
  const { act, data } = useBackend<AlertComputerData>();
  const { PriorityList, MinorList } = data;
  return (
    <Window title="Current Station Alerts">
      <Window.Content>
        <Section title="Priority Alerts">
          <LabeledList>
            {PriorityList.length === 0 && (
              <LabeledList.Item>No priority alerts detected.</LabeledList.Item>
            )}
            {PriorityList.length > 0 &&
              PriorityList.map((value, index) => {
                return (
                  <LabeledList.Item
                    key={index}
                    label={value.area_name}
                    buttons={
                      <Button
                        align="right"
                        onClick={() =>
                          act('priority_clear', { area_ckey: value.area_ckey })
                        }
                      >
                        Clear Alarm
                      </Button>
                    }
                  />
                );
              })}
          </LabeledList>
        </Section>
        <Section title="Minor Alerts">
          <LabeledList>
            {MinorList.length === 0 && (
              <LabeledList.Item>No minor alerts detected.</LabeledList.Item>
            )}
            {MinorList.length > 0 &&
              MinorList.map((value, index) => {
                return (
                  <LabeledList.Item
                    key={index}
                    label={value.area_name}
                    buttons={
                      <Button
                        align="right"
                        onClick={() =>
                          act('minor_clear', { area_ckey: value.area_ckey })
                        }
                      >
                        Clear Alarm
                      </Button>
                    }
                  />
                );
              })}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
