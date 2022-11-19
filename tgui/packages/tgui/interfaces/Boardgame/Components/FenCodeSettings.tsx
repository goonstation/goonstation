declare const React;

import { useBackend, useLocalState } from '../../../backend';
import { Box, Button, Flex, Stack, Tabs, TextArea, Tooltip } from '../../../components';
import { fenCodeRecordFromPieces, fetchPieces, getPiece, getPiecesByGame, PieceType } from '../Pieces';
import { BoardgameData, Piece } from '../types';
import { presets, PresetType, presetsByGame } from '../Presets';

export const FenCodeSettings = (_props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);
  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);
  return configModalOpen ? (
    <Box className="boardgame__modal">
      <Box className="boardgame__modal-inner">
        <Tabs fluid className="boardgame__modal-tabs">
          <Tabs.Tab className="boardgame__modal-tab" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            Config
          </Tabs.Tab>
          <Tabs.Tab className="boardgame__modal-tab" selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
            Presets
          </Tabs.Tab>
          <Button onClick={() => setConfigModalOpen(false)}>Close</Button>
        </Tabs>
        <Box className="boardgame__modal-config">
          {tabIndex === 1 && <ConfigTab />}
          {tabIndex === 2 && <PresetsTab />}
        </Box>
      </Box>
    </Box>
  ) : null;
};

const convertFenCodeToBoardArray = (fenCode: string) => {
  // For example, fenCode = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  // Should be split into ["r", "n", "b", "q", "k", "b", "n", "r", "..." and so on]
  // The numbers add x empty spaces to the array
  // The "/" should be ignored

  const fenCodeArray = fenCode.split('/');
  const boardArray: string[] = [];

  for (const fenCodeRow of fenCodeArray) {
    const fenCodeRowArray = fenCodeRow.split('');
    for (const fenCodePiece of fenCodeRowArray) {
      if (isNaN(Number(fenCodePiece))) {
        boardArray.push(fenCodePiece);
      } else {
        for (let i = 0; i < Number(fenCodePiece); i++) {
          boardArray.push('');
        }
      }
    }
  }

  return boardArray;
};

type ConfigTooltipProps = {
  text: string;
  tooltip: string;
  link?: string;
};

const ConfigTooltip = ({ text, tooltip, link }: ConfigTooltipProps) => {
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Box
        style={{
          'padding': '0 0.5em',
        }}
        position="relative">
        {text}
        {link && (
          <a
            href={link}
            target="_blank"
            rel="noreferrer"
            style={{
              'padding': '0 0.5em',
            }}>
            (Wiki)
          </a>
        )}
      </Box>
    </Tooltip>
  );
};

const convertBoardToGNot = (width: number, height: number, pieces: Piece[]) => {
  // Convert the pieces on a board into a GNot string, comma separated
  // For example, if the board is 8x8 a string could formatted like this:
  // r,n,b,q,k,b,n,r,p,p,p,p,p,p,p,p,32,P,P,P,P,P,P,P,P,R,N,B,Q,K,B,N,R
  // The numbers are the number of empty spaces

  // The pieces have x and y coordinates, but we need to convert them to a 1D array
  // and place them in the correct order, filled with empty spaces in between

  let boardArray = Array(width * height).fill('');

  Object.keys(pieces).forEach((pieceKey) => {
    const piece = pieces[pieceKey];
    const index = piece.y * width + piece.x;
    boardArray[index] = piece.code;
  });

  let gNotString = '';
  let emptySpaces = 0;

  for (const piece of boardArray) {
    if (piece === '') {
      emptySpaces++;
    } else {
      if (emptySpaces > 0) {
        gNotString += `${emptySpaces},`;
        emptySpaces = 0;
      }
      gNotString += `${piece},`;
    }
  }

  // Remove the last comma
  gNotString = gNotString.slice(0, -1);

  return gNotString;
};

const ConfigTab = (_props, context) => {
  const { act, data } = useBackend<BoardgameData>(context);
  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);
  const { width, height } = data.boardInfo;
  const { pieces } = data;
  const [gnot, setGnot] = useLocalState(context, 'gnot', '');

  return (
    <Stack vertical>
      <h4>Apply notation</h4>
      <Box
        style={{
          'display': 'flex',
          'flex-direction': 'row',
        }}>
        <span>You can import: </span>
        <ConfigTooltip text="GNot" tooltip="Goon Notation" link={'https://wiki.ss13.co/Main_Page'} />
        <ConfigTooltip text="FEN" tooltip="Forsyth–Edwards Notation" />
        <ConfigTooltip text="PDN" tooltip="Portable Draughts Notation" />
      </Box>
      <TextArea value={gnot} style={{ 'height': '200px' }} />
      <Button
        onClick={() => {
          act('applyGNot', {
            gnot: gnot,
          });
          setConfigModalOpen(false);
        }}>
        Apply and close
      </Button>
      <Button
        onClick={() => {
          const gnotString = convertBoardToGNot(width, height, pieces);
          setGnot(gnotString);
        }}>
        Fetch GNot from board
      </Button>
    </Stack>
  );
};
type PieceSVGImageProps = {
  width: number;
  height: number;
  pieceData: PieceType;
};

const PieceSVGImage = ({ width, height, pieceData }: PieceSVGImageProps) => {
  if (pieceData?.image) {
    return <image width={width} height={height} xlinkHref={pieceData.image} />;
  }

  if (pieceData?.fenCode) {
    return <text>{pieceData.fenCode} </text>;
  }
  return null;
};

type GenerateSvgBoardProps = {
  preset: string;
  size?: number;
};

// Create an svg element with the boardgame specified in the boardInfo
// The board size is 128x128
const GenerateSvgBoard = ({ preset, size }: GenerateSvgBoardProps, context) => {
  const { act } = useBackend<BoardgameData>(context);
  const [configModalOpen, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);

  const { data } = useBackend<BoardgameData>(context);
  const { width } = data.boardInfo;
  const { tileColour1, tileColour2 } = data.styling;

  const allPieces = fetchPieces();
  const codeRecords = fenCodeRecordFromPieces(allPieces);

  const presetArray = preset.split(',');
  let currentIndex = 0;

  const s = (size || 1) * 80;
  return (
    <svg width="80" height="80" viewBox="0 0 80 80">
      <pattern id="pattern-checkerboard-preset" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
        <rect width="10" height="10" fill={tileColour1} />
        <rect x="10" y="10" width="10" height="10" fill={tileColour1} />
        <rect x="10" width="10" height="10" fill={tileColour2} />
        <rect y="10" width="10" height="10" fill={tileColour2} />
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
  const { act } = useBackend<BoardgameData>(context);
  const [, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);

  const prettyGameName = game.charAt(0).toUpperCase() + game.slice(1);

  return (
    <Flex.Item>
      <Flex direction="column" className="boardgame__presets">
        <Flex.Item>
          <h4>{prettyGameName}</h4>
        </Flex.Item>
        <Flex.Item className="boardgame__presets-grid">
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

type PresetItemProps = {
  preset: PresetType;
  presetSetup: string;
};

const PresetItem = ({ preset, presetSetup }: PresetItemProps, context) => {
  const { act } = useBackend<BoardgameData>(context);
  const [selectedPreset, setSelectedPreset] = useLocalState<PresetType | null>(context, 'selectedPreset', null);
  const [, setConfigModalOpen] = useLocalState(context, 'configModalOpen', false);
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
          setConfigModalOpen(false);
          setTimeout(() => {
            setSelectedPreset(null);
          }, 200);
        }}>
        <GenerateSvgBoard preset={presetSetup} />
      </Box>
    </Box>
  );
};
