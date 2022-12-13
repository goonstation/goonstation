import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { adjustSizes, handleEvents } from './utils/window';
import { Component } from 'inferno';

import { Icon, Box, Dimmer } from '../../components';
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
    <Dimmer className="boardgame__helpmodal" onClick={helpModalClose}>
      <Box>
        <p>
          <strong>Help</strong>
        </p>
        <p>
          <Icon name="mouse" /> Click on a piece to select it, click on a tile to move it there.
        </p>
        <p>Pieces may also be click-dragged to a target tile.</p>
        <p>
          Moving a piece onto a tile occupied by another piece will
          replace/capture the piece already on that tile.
        </p>
        <p>Right click a piece to delete it.</p>
      </Box>
    </Dimmer>
  );
};
