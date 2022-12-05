import { useBackend, useLocalState } from '../../../../backend';

import { Box, Button, Flex, Tabs, Tooltip } from '../../../../components';

import { codeRecordFromPieces, fetchPieces, PieceSetupType } from '../../games';
import { BoardgameData } from '../../utils/types';
import { PresetType, presetsByGame } from '../../games';
import { useStates } from '../../utils/config';
import NotSetup from './NotSetup';

export const ConfigModal = (_props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const { closeModal, isModalOpen, setModalTabIndex, modalTabIndex } = useStates(context);

  return isModalOpen ? (
    <Box className="boardgame__modal">
      <Box className="boardgame__modal-inner">
        <Tabs fluid className="boardgame__modal-tabs">
          <Tabs.Tab className="boardgame__modal-tab" selected={modalTabIndex === 0} onClick={() => setModalTabIndex(0)}>
            Presets
          </Tabs.Tab>
          <Tabs.Tab className="boardgame__modal-tab" selected={modalTabIndex === 1} onClick={() => setModalTabIndex(1)}>
            Notation Setup
          </Tabs.Tab>
        </Tabs>
        <Box className="boardgame__modal-config">{modalTabIndex === 0 ? <PresetsTab /> : <NotSetup />}</Box>
      </Box>
    </Box>
  ) : null;
};

type PieceSVGImageProps = {
  width: number;
  height: number;
  pieceData: PieceSetupType;
};

const PieceSVGImage = ({ width, height, pieceData }: PieceSVGImageProps) => {
  if (pieceData?.image) {
    return <image width={width} height={height} xlinkHref={pieceData.image} />;
  }

  if (pieceData?.code) {
    return <text>{pieceData.code} </text>;
  }
  return null;
};

type GenerateSvgBoardProps = {
  preset: string;
  size?: number;
};

// Create an svg element with the boardgame specified in the boardInfo
// The board size is 128x128
// TODO: Remove this and use a board component instead
const GenerateSvgBoard = ({ preset, size }: GenerateSvgBoardProps, context) => {
  const { act } = useBackend<BoardgameData>(context);
  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);

  const { data } = useBackend<BoardgameData>(context);
  const { width } = data.boardInfo;
  const { tileColor1, tileColor2 } = data.styling;

  const allPieces = fetchPieces();
  const codeRecords = codeRecordFromPieces(allPieces);

  const presetArray = preset.split(',');
  let currentIndex = 0;

  const s = (size || 1) * 80;
  return (
    <svg width="80" height="80" viewBox="0 0 80 80">
      <pattern id="pattern-checkerboard-preset" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
        <rect width="10" height="10" fill={tileColor1} />
        <rect x="10" y="10" width="10" height="10" fill={tileColor1} />
        <rect x="10" width="10" height="10" fill={tileColor2} />
        <rect y="10" width="10" height="10" fill={tileColor2} />
      </pattern>
      <rect width="80" height="80" fill="url(#pattern-checkerboard-preset)" />

      {
        // Draw the pieces on the board
        presetArray.map((piece, index) => {
          const pieceData = codeRecords[piece];

          // Convert index to x and y, use current index to get the piece
          const x = currentIndex % width;
          const y = Math.floor(currentIndex / width);

          // if the piece is a number, apply the number to the current index
          if (!isNaN(parseInt(piece, 10))) {
            currentIndex += parseInt(piece, 10);
          } else {
            currentIndex++;
          }

          return (
            <g key={index} transform={`translate(${x * 10}, ${y * 10})`}>
              <PieceSVGImage width={10} height={10} pieceData={pieceData} />
            </g>
          );
        })
      }
    </svg>
  );
};

const PresetDetails = (_props, context) => {
  const { act } = useBackend<BoardgameData>(context);
  const [selectedPreset, setSelectedPreset] = useLocalState<PresetType | null>(context, 'selectedPreset', null);
  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);

  if (!selectedPreset) return null;

  let setupString = '';

  if (selectedPreset) {
    setupString = typeof selectedPreset.setup === 'function' ? selectedPreset.setup() : selectedPreset.setup;
  }
  return (
    <Box className={`boardgame__preset-details ${selectedPreset ? 'boardgame__preset-details--active' : ''}`}>
      <Flex>
        <Flex.Item>
          <Box className="boardgame__preset-details-board">
            <GenerateSvgBoard preset={setupString} />
          </Box>
        </Flex.Item>
        <Flex.Item className="boardgame__preset-details-summary">
          <h4>{selectedPreset?.name}</h4>
          <p>{selectedPreset?.description}</p>
          <Box>
            <Button
              onClick={() => {
                act('applyGNot', {
                  gnot: setupString,
                });
                setSelectedPreset(null);
                setConfigModalOpen(false);
              }}>
              Play
            </Button>
            <Button
              onClick={() => {
                setSelectedPreset(null);
              }}>
              Close
            </Button>
          </Box>
        </Flex.Item>
      </Flex>
      {selectedPreset.rules ? <DetailRules element={selectedPreset.rules} /> : null}
    </Box>
  );
};

type DetailRulesProps = {
  element: JSX.Element;
};
const DetailRules = ({ element }: DetailRulesProps) => {
  if (!element) return null;

  return (
    <Box className="boardgame__rules">
      <h4>Rules</h4>
      <Box className="boardgame__rules-content">{element}</Box>
    </Box>
  );
};

const PresetsTab = (_props, context) => {
  const records = presetsByGame();

  return (
    <Flex className="boardgame__presets">
      <h5>Click once for rules, double click to quick launch</h5>
      {Object.keys(records).map((game, i) => {
        const presets = records[game];
        return <PresetsRow key={i} game={game} presets={presets} />;
      })}
      <PresetDetails />
    </Flex>
  );
};

type PresetsRowProps = {
  game: string;
  presets: PresetType[];
};

const PresetsRow = ({ game, presets }: PresetsRowProps, context) => {
  const prettyGameName = game.charAt(0).toUpperCase() + game.slice(1);
  const dateSeed = new Date().getFullYear() + new Date().getMonth() + new Date().getDate();

  return (
    <Flex.Item>
      <Flex direction="column" className="boardgame__presets">
        <Flex.Item className="boardgame__presets-header">
          <h4>{prettyGameName}</h4>
        </Flex.Item>
        <Flex.Item className="boardgame__presets-grid">
          {presets.length > 0 && (
            // Pick a random fact depending on the day
            <Flex.Item key={'fact'} className="boardgame__randomfact">
              <span>
                {presets[0].kit.facts.length > 0 ? presets[0].kit.facts[dateSeed % presets[0].kit.facts.length] : ''}
              </span>
            </Flex.Item>
          )}
          {presets.map((preset, i) => {
            const setup = preset.setup;
            // if setup is a function, call it to get the setup
            const setupString = typeof setup === 'function' ? setup() : setup;

            return (
              <Flex.Item key={i} className="boardgame__preset">
                <Tooltip position="top" content={preset.name}>
                  <Flex position="relative">
                    <Flex.Item>
                      <PresetItem preset={preset} presetSetup={setupString} />
                    </Flex.Item>
                  </Flex>
                </Tooltip>
              </Flex.Item>
            );
          })}
        </Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

PresetsRow.defaultHooks = {
  // onComponentShouldUpdate: () => false,
};

type PresetItemProps = {
  preset: PresetType;
  presetSetup: string;
};

const PresetItem = ({ preset, presetSetup }: PresetItemProps, context) => {
  const { act } = useBackend<BoardgameData>(context);
  const [selectedPreset, setSelectedPreset] = useLocalState<PresetType | null>(context, 'selectedPreset', null);
  const { closeModal } = useStates(context);
  // Draw the board and a ? button on top of it
  return (
    <Box className="boardgame__preset-item">
      <Box
        onClick={() => {
          setTimeout(() => {
            setSelectedPreset(preset);
          }, 200);
        }}
        onDblClick={() => {
          act('applyGNot', {
            gnot: presetSetup,
          });
          closeModal();
          setTimeout(() => {
            setSelectedPreset(null);
          }, 200);
        }}>
        <GenerateSvgBoard preset={presetSetup} />
      </Box>
    </Box>
  );
};
