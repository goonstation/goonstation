import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Rockbox = (props, context) => {
  const {data} =useBackend(context);
  const {ores} =data;
  return (

    <Window
      title ="Rockbox"
      width ={500}
      height ={500}
    >
      <Window.content>
        <Section>
          <LabeledList>
            <LabeledList.item
              label ="Ores"
            >{data.ores}
            </LabeledList.item>
          </LabeledList>
        </Section>
      </Window.content>
    </Window>
  );
};
