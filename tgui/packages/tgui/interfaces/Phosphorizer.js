import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Divider, BlockQuote, Icon, NumberInput } from '../components';
import { Window } from '../layouts';

export const Phosphorizer = (props, context) => {
  const { data } = useBackend(context);
  const { busy } = data;
  return (
    <Window
      title="Phosphorizer"
      width={375}
      height={215}>
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
  const { tubes, hostR, hostG, hostB } = data;

  return (
    <Box>
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
      </Box>
      <Divider />
      <Button
        content="Phosphorize"
        tooltip="Begin applying a colored \ncoating to contents."
        tooltipPosition="right"
        onClick={() => act('process', {})} />
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
