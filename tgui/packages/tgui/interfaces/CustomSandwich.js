import { useBackend } from "../backend";
import { Box, Button, Section, LabeledList } from '../components';
import { Window } from "../layouts";

export const CustomSandwich = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    ingredients,
  } = data;

  return (
    <Window
      resizable
      width={600}
      height={800}>
      <Window.Content scrollable>
        <Section
          title={name}>
          <Box>
            {ingredients.reverse().map((item, index) => (

              <LabeledList
                key={index}>
                <LabeledList.Item
                  label={(ingredients.length - index)}
                  buttons={<Button
                    content="Remove ingredient"
                    onClick={() => act('remove', { sandwich_index: index+1 })}
                    color="red"
                  />}>
                  {item}
                </LabeledList.Item>
                <LabeledList.Divider
                  size={1} />
              </LabeledList>

              /*
              <Collapsible
                key={index}
                title={item}
                buttons={<Button
                  content="Remove ingredient"
                  onClick={() => act('remove', { sandwich_index: index+1 })}
                  color="red"
                />}>
              </Collapsible>
              */

            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
