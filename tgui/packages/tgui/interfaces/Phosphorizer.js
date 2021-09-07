import { useBackend } from '../backend';
import { Box, Button, ColorBox, Divider, Knob, NoticeBox, Stack } from '../components';
import { Window } from '../layouts';

export const Phosphorizer = (props, context) => {
  const { data } = useBackend(context);
  const { busy } = data;
  return (
    <Window
      title="Phosphorizer"
      width={360}
      height={190}>
      <Window.Content>
        { busy ? (
          <BusyWindow />
        ) : (
          <OperateWindow />
        )}
      </Window.Content>
    </Window>
  );
};

const OperateWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const { lights, online, hostR, hostG, hostB } = data;

  return (
    <Box>
      <NoticeBox success>
        Please insert only standard light tubes and bulbs.
      </NoticeBox>
      <Stack vertical>
        <Stack.Item>
          <strong>Loaded Lights:</strong>
          {' '}{ lights }
        </Stack.Item>
        <Stack.Item>
          Color Tuning:
          {' '}
          <Knob
            inline
            minValue={20}
            maxValue={255}
            value={hostR}
            color="red"
            format={value => "R:" + value}
            onDrag={(e, value) => act('tune_hue', {
              hue: "R",
              output: value,
            })}
          />
          <Knob
            inline
            minValue={20}
            maxValue={255}
            value={hostG}
            color="green"
            format={value => "G:" + value}
            onDrag={(e, value) => act('tune_hue', {
              hue: "G",
              output: value,
            })}
          />
          <Knob
            inline
            minValue={20}
            maxValue={255}
            value={hostB}
            color="blue"
            format={value => "B:" + value}
            onDrag={(e, value) => act('tune_hue', {
              hue: "B",
              output: value,
            })}
          />
          {' '}
          <ColorBox color={`rgba(${hostR}, ${hostG}, ${hostB}, 1)`} />
        </Stack.Item>
      </Stack>
      <Divider />
      <Button
        icon="power-off"
        content={online ? 'Stop Phosphorizing' : 'Start Phosphorizing'}
        tooltip={online ? 'Abort current processing.' : 'Begin applying chosen color to contents.'}
        tooltipPosition="right"
        onClick={() => act('toggle-process')} />
      <Button
        icon="eject"
        content="Eject"
        tooltip="Remove contents without colorizing."
        tooltipPosition="bottom"
        onClick={() => act('eject')} />
    </Box>
  );
};

const BusyWindow = () => {
  return (
    <NoticeBox warning>
      Phosphorization in progress, please wait!
    </NoticeBox>
  );
};
