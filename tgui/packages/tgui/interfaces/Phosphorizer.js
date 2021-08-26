import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Divider, ColorBox, NumberInput } from '../components';
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
        <Box>
          { busy ? (
            <BusyWindow />
          ) : (
            <OperateWindow />
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};

const OperateWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const { tubes, online, hostR, hostG, hostB } = data;

  return (
    <Box>
      <NoticeBox success>
        Please insert only standard light tubes and bulbs.
      </NoticeBox>
      <Box>
        <strong># Loaded Lights:</strong>
        {' '}{ tubes }
      </Box>
      <Box>
        Color Tuning:
        {' '}
        <NumberInput
          minValue={20}
          maxValue={255}
          value={hostR}
          format={value => "R:" + value}
          onDrag={(e, value) => act('tune_hue', {
            hue: "R",
            output: value,
          })}
        />
        <NumberInput
          minValue={20}
          maxValue={255}
          value={hostG}
          format={value => "G:" + value}
          onDrag={(e, value) => act('tune_hue', {
            hue: "G",
            output: value,
          })}
        />
        <NumberInput
          minValue={20}
          maxValue={255}
          value={hostB}
          format={value => "B:" + value}
          onDrag={(e, value) => act('tune_hue', {
            hue: "B",
            output: value,
          })}
        />
        {' '}
        <ColorBox
          color={`rgba(${hostR}, ${hostG}, ${hostB}, 1)`} />
      </Box>
      <Divider />
      <Button
        icon="power-off"
        content={online ? "Stop Phosphorizing" : "Start Phosphorizing"}
        tooltip={online ? "Abort current processing." : "Begin applying chosen color to contents."}
        tooltipPosition="right"
        onClick={() => act('process', {})} />
      <Button
        icon="eject"
        content="Eject"
        tooltip="Remove contents without colorizing."
        tooltipPosition="bottom"
        onClick={() => act('eject', {})} />
    </Box>
  );
};

const BusyWindow = () => {
  return (
    <NoticeBox warning>
      The Machine is busy, please wait!
    </NoticeBox>
  );
};
