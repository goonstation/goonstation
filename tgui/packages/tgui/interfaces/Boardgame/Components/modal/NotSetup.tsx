import { useBackend, useLocalState } from '../../../../backend';
import { Box, Button, Divider, Flex, Icon, Section, TextArea } from '../../../../components';
import { convertBoardToGNot } from '../../utils/notations';
import { BoardgameData } from '../../utils/types';
import { useStates } from '../../utils/config';

const NotSetup = (_props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { closeModal } = useStates(context);

  const { width, height } = data.boardInfo;
  const { pieces } = data;

  const [gnot, setGnot] = useLocalState(context, 'gnot', '');

  return (
    <Box fill>
      <Section
        title="Apply notation"
        buttons={
          <Button
            icon="arrow-circle-right"
            onClick={() => {
              act('applyGNot', {
                gnot: gnot,
              });
              closeModal();
            }}>
            Apply and close
          </Button>
        }>
        <Flex direction="column">
          <TextArea height="200px" value={gnot} onChange={(e, value) => setGnot(value)} />
          <Divider />
          <Button
            onClick={() => {
              const gnotString = convertBoardToGNot(width, height, pieces);
              setGnot(gnotString);
            }}>
            <Icon name="sync-alt" />
            Fetch GNot from board
          </Button>
        </Flex>
      </Section>
    </Box>
  );
};

export default NotSetup;
