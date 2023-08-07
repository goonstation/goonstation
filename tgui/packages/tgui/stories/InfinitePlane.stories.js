/**
 * @file
 * @copyright 2023 ZeWaka
 * @license MIT
 */

import { Box, Button, InfinitePlane, Section, Stack } from '../components';
// import { Connections } from '../interfaces/common/Connections';

export const meta = {
  title: 'InfinitePlane',
  render: () => <Story />,
};

const Story = (props, context) => {
  // const connections = [];
  // connections.push({
  //   from: { x: 50, y: 50 },
  //   to: { x: 100, y: 100 },
  //   color: 'blue',
  // });

  const comps = ["test", "dog", "cat"];

  return (
    <Section>
      <InfinitePlane
        width="100%"
        height="100%"
      >
        {
          comps.map(
            (str, index) =>
              (
                <DisplayComponent key={index} text={str} />
              )
          )
        }
        {/* <Connections connections={connections} /> */}
      </InfinitePlane>
    </Section>
  );
};

const DisplayComponent = (props) => {
  const component = {
    color: 'red',
    name: "dog",
    description: "yeet",
  };
  return (
    <Box>
      <div>
        <Box
          backgroundColor={component.color || 'blue'}
          py={1}
          px={1}
          className="ObjectComponent__Titlebar">
          <Stack>
            <Stack.Item grow={1} unselectable="on">
              {component.name}
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                icon="info"
                compact
                tooltip={component.description}
                tooltipPosition="top"
              />
            </Stack.Item>
          </Stack>
        </Box>
        <Box
          className="ObjectComponent__Content"
          unselectable="on"
          py={1}
          px={1}>
          <Stack>
            <Stack.Item grow={1}>
              <Stack vertical fill>
                <Stack.Item key={1}>
                  left1
                </Stack.Item>
                <Stack.Item key={2}>
                  left2
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item key={1}>
                  right
                </Stack.Item>
                <Stack.Item key={2}>
                  right2
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      </div>
    </Box>
  );
};

