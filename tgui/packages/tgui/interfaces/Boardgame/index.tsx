import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { adjustSizes, handleEvents } from './utils/window';
import { Component } from 'inferno';

import { Icon, Box, Modal } from '../../components';
import { useStates, BoardgameData } from './utils';
import { TitleBar } from './Components/common/TitleBar';
import { HeldPieceRenderer } from './Components/common/HeldPieceRenderer';
import { BoardgameContents } from './Components/common/BoardgameContents';

export class Boardgame extends Component<BoardgameData, any> {
  constructor(props) {
    super(props);
  }

  componentDidUpdate() {
    handleEvents(this.context);
    adjustSizes(this.context);
  }

  render() {
    const { data } = useBackend<BoardgameData>(this.context);
    const name = data?.boardInfo?.name || 'Boardgame';

    return (
      <Window title={name} width={580} height={512}>
        <HelpModal />
        <TitleBar />
        <HeldPieceRenderer />
        <BoardgameContents />
      </Window>
    );
  }
}

const HelpModal = (props, context) => {
  const { helpModalClose, isHelpModalOpen } = useStates(context);

  if (!isHelpModalOpen) return null;

  return (
    <Modal onClick={helpModalClose}>
      <Box>
        <p>
          <Icon name="mouse" /> Click on a piece to select, click on a tile to move it there.
        </p>
        <p>
          <i>or</i>
        </p>
        <p>Hold the piece, and drop it at the tile to move it.</p>
        <p>Right click a piece to delete it.</p>
        <i>Click here to close this panel.</i>
      </Box>
    </Modal>
  );
};
