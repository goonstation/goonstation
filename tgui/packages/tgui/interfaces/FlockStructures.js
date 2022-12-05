import { useBackend } from '../backend';
import { Section, Image, Stack } from '../components';
import { Window } from '../layouts';

export const FlockStructures = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    structures,
  } = data;
  return (
    <Window
      title="Flock structures"
      width={500}
      height={600}
    >
      <Window.Content scrollable>
        <Stack vertical>
          {structures.map(structure => {
            const {
              name,
              icon,
              description,
              cost,
            } = structure;
            return (
              <Stack.Item key={name}>
                <Stack height="100%">
                  <Stack.Item width={9}>
                    <Section align="center">
                      <Stack vertical>
                        <Stack.Item>
                          {name}
                        </Stack.Item>
                        <Stack.Item>
                          <Image
                            pixelated
                            height="64px"
                            width="64px"
                            src={`data:image/png;base64,${icon}`} />
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Stack.Item width={29}>
                    <Section height="100%">
                      <Stack vertical>
                        <Stack.Item>
                          {description}
                        </Stack.Item>
                        <Stack.Item>
                          {!!cost && `Cost: ${cost}`}
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>

            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};

