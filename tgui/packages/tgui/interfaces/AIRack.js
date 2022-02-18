import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const AIRack = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    laws
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
      <Section>
          <LabeledList>
            {laws.map((item,index) => (
              <LabeledList.Item>
                <Button
                  icon={item ? 'circle' : 'circle-o'}
                  content={item ? item : "Empty"}
                  onClick={() => act(index+1)}
                  fluid={true}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
