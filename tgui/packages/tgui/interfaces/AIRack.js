import { useBackend } from '../backend';
import { BlockQuote, Button, Collapsible, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const AIRack = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lawTitles,
    lawText,
    welded,
    screwed,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            {lawTitles.map((item, index) => (
              <LabeledList.Item key={index}>
                <Collapsible title={item ? lawTitles[index] : "Empty"}>
                  <BlockQuote>{item ? lawText[index] : "<Empty Slot>"}</BlockQuote>
                  <Button
                    icon={item ? 'circle' : 'circle-o'}
                    content={item ? "Remove" : "Empty"}
                    onClick={() => act("rack", { rack_index: index+1 })}
                    disabled={welded[index] || screwed[index]}
                  />
                  <Button
                    icon={welded[index] ? 'circle' : 'circle-o'}
                    content={welded[index] ? "Welded" : "Not Welded"}
                    onClick={() => act("weld", { rack_index: index+1 })}
                    color={welded[index] ? "red" : "green"}
                  />
                  <Button
                    icon={screwed[index] ? 'circle' : 'circle-o'}
                    content={screwed[index] ? "Screwed In" : "Not Screwed In"}
                    onClick={() => act("screw", { rack_index: index+1 })}
                    color={screwed[index] ? "red" : "green"}
                  />
                </Collapsible>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
