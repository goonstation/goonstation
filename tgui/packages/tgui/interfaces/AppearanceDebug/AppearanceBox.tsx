import { Box, Button, Image, Stack, Tooltip } from 'tgui-core/components';

import {
  getReadableLayer,
  getReadablePlane,
  isEmissive,
  isEmissiveBlocker,
} from '.';
import {
  type Appearance,
  APPEARANCE_FLAGS,
  AppearanceType,
  type Coordinates,
  HiddenState,
} from './types';
import { useAppearanceDebugContext } from './useAppearanceDebug';

export type AppearanceProps = {
  appearance: Appearance;
  position: Coordinates;
  onClick: React.MouseEventHandler<HTMLDivElement>;
  onMouseEnter?: React.MouseEventHandler<HTMLDivElement>;
};

export function AppearanceBox(props: AppearanceProps) {
  const { appearance, position, onClick, onMouseEnter } = props;
  const { planeToText, layerToText, act } = useAppearanceDebugContext();
  const singleLineStyle = {
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
  } as const;

  return (
    <>
      {!!(
        appearance.data.flags &
        (APPEARANCE_FLAGS.KEEP_APART | APPEARANCE_FLAGS.KEEP_TOGETHER)
      ) && (
        <Box
          position="absolute"
          left={`${position.x + appearance.boundingBox[0].x}px`}
          top={`${position.y + appearance.boundingBox[0].y}px`}
          width={`${appearance.boundingBox[1].x - appearance.boundingBox[0].x}px`}
          height={`${appearance.boundingBox[1].y - appearance.boundingBox[0].y}px`}
          style={{
            zIndex: -(999 - appearance.depth),
            border: `3px solid ${appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART ? (appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER ? '#2a7dc6' : '#107e2e') : '#e9cb0c'}`,
            borderRadius: '5px',
            padding: '5px',
            backgroundColor: `${appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART ? (appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER ? '#223c54' : '#13381c') : '#544b15'}`,
          }}
        >
          {!!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART) &&
            'KEEP_APART'}
          {!!(
            appearance.data.flags & APPEARANCE_FLAGS.KEEP_APART &&
            appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER
          ) && ' | '}
          {!!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER) &&
            'KEEP_TOGETHER'}
        </Box>
      )}
      <Box
        position="absolute"
        left={`${position.x}px`}
        top={`${position.y}px`}
        minWidth="150px"
        maxWidth="220px"
        onClick={onClick}
        onMouseEnter={onMouseEnter}
        style={{
          zIndex: 1,
          borderRadius: '6px',
          border: '1px solid rgba(255, 255, 255, 0.1)',
          overflow: 'hidden',
        }}
        opacity={appearance.hidden === HiddenState.VisibleChild ? 0.7 : 1}
      >
        <Box
          backgroundColor={
            appearance.data.type === AppearanceType.Atom
              ? '#ba5614'
              : appearance.data.type === AppearanceType.Image
                ? '#932bad'
                : '#19964d'
          }
          py={1}
          px={1}
          style={{
            borderRadius: '6px 6px 0 0',
            fontWeight: 'bold',
          }}
        >
          <Stack>
            <Stack.Item grow style={singleLineStyle}>
              {appearance.data.name || appearance.data.icon_state}
              {isEmissive(appearance)
                ? ' (Emissive)'
                : isEmissiveBlocker(appearance)
                  ? ' (Emissive Blocker)'
                  : ''}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="pager"
                compact
                tooltip={
                  appearance.data.type === AppearanceType.Atom
                    ? 'View Variables (Atom)'
                    : 'View Variables (Appearance Copy)'
                }
                onClick={() => act('vvAppearance', { id: appearance.data.id })}
              />
            </Stack.Item>
          </Stack>
        </Box>

        <Box
          py={1}
          px={1}
          style={{
            backgroundColor: 'rgba(0, 0, 0, 0.6)',
            borderRadius: '0 0 6px 6px',
            borderTop: 'none',
          }}
        >
          <Stack vertical>
            {appearance.data.icon && (
              <Stack.Item style={singleLineStyle}>
                icon: {appearance.data.icon}
              </Stack.Item>
            )}
            {appearance.data.icon_state && (
              <Stack.Item style={singleLineStyle}>
                icon_state: {appearance.data.icon_state}
              </Stack.Item>
            )}
            <Stack.Item style={singleLineStyle}>
              layer: {getReadableLayer(appearance, layerToText)}
            </Stack.Item>
            <Stack.Item
              style={{
                borderBottom: '1px dashed hsl(0, 0%, 60%)',
                paddingBottom: '0.5rem',
                overflow: 'hidden',
              }}
            >
              <Tooltip content={`True plane: ${appearance.data.plane_true}`}>
                <Box style={singleLineStyle}>
                  plane: {getReadablePlane(appearance, planeToText)}
                </Box>
              </Tooltip>
            </Stack.Item>
            {!!appearance.data.embed_icon && (
              <Stack.Item>
                <Image
                  src={`data:image/png;base64,${appearance.data.embed_icon}`}
                  height="64px"
                  width="64px"
                  objectFit="contain"
                />
              </Stack.Item>
            )}
            {!!appearance.data.embed_icon_error && (
              <Stack.Item>
                <Box
                  px={1}
                  py={0.5}
                  style={{
                    backgroundColor: '#800080aa',
                    color: '#fff',
                    fontWeight: '600',
                    fontSize: '10px',
                    border: '2px solid #000',
                    backgroundImage:
                      'repeating-linear-gradient(45deg, #000 0px, #000 4px, #800080aa 4px, #800080aa 8px)',
                    wordBreak: 'break-word',
                  }}
                >
                  {appearance.data.embed_icon_error}
                </Box>
              </Stack.Item>
            )}
          </Stack>
        </Box>
      </Box>
    </>
  );
}
