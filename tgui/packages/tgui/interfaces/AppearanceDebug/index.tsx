import { useCallback, useRef, useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  InfinitePlane,
  Stack,
} from 'tgui-core/components';
import { Window } from '../../layouts';
import { AppearanceBox } from './AppearanceBox';
import { AppearanceInfo } from './AppearanceInfo';
import { type Connection, Connections } from '../common/Connections';
import type {
  Appearance,
  AppearanceData,
  AppearanceDebugData,
  AppearanceMap,
  Coordinates,
} from './types';
import {
  APPEARANCE_FLAGS,
  AppearanceParentType,
  AppearanceType,
  HiddenState,
  VIS_FLAGS,
} from './types';
import { AppearanceDebugContext } from './useAppearanceDebug';

function textWidth(text: string, font: string, fontsize: number) {
  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');
  if (!context) return 0;
  context.font = `${fontsize}px ${font}`;
  return context.measureText(text).width;
}

function mapAppearance(
  appearance_data: AppearanceData,
  parent: Appearance | null = null,
  parentType: AppearanceParentType = AppearanceParentType.None,
  depth: number = 0,
  appearances: AppearanceMap = {},
  planeFilter: number | null,
  hideEmissives: boolean,
  keepTogether: boolean,
): Appearance {
  if (appearance_data.flags & APPEARANCE_FLAGS.KEEP_APART) keepTogether = false;

  const appearance: Appearance = {
    data: appearance_data,
    underlays: null,
    overlays: null,
    parent: parent,
    hidden: HiddenState.Visible,
    boundingBox: [
      { x: 0, y: 0 },
      { x: 0, y: 0 },
    ],
    parentType: parentType,
    renderTargetTo: null,
    relativePosition: { x: 0, y: 0 },
    depth: depth,
    inherited_icon: !!(
      (appearance_data.vis_flags || 0) & VIS_FLAGS.VIS_INHERIT_ICON
    ),
    inherited_icon_state: !!(
      (appearance_data.vis_flags || 0) & VIS_FLAGS.VIS_INHERIT_ICON_STATE
    ),
    inherited_layer: !!(
      (appearance_data.vis_flags || 0) & VIS_FLAGS.VIS_INHERIT_LAYER
    ),
    inherited_plane: !!(
      (appearance_data.vis_flags || 0) & VIS_FLAGS.VIS_INHERIT_PLANE
    ),
    inherited_dir:
      !!((appearance_data.vis_flags || 0) & VIS_FLAGS.VIS_INHERIT_DIR) ||
      keepTogether,
    total_alpha:
      parent && keepTogether
        ? Math.round((appearance_data.alpha * parent.total_alpha) / 255)
        : appearance_data.alpha,
  };

  // Filter by plane
  if (planeFilter !== null && appearance_data.plane_true !== planeFilter) {
    appearance.hidden = HiddenState.Hidden;
  }

  // Filter emissives
  if (
    hideEmissives &&
    (isEmissive(appearance) || isEmissiveBlocker(appearance))
  ) {
    appearance.hidden = HiddenState.Hidden;
  }

  appearances[appearance_data.id] = appearance;

  // Process underlays
  let underlays = appearance_data.underlays
    ? [...appearance_data.underlays]
    : [];
  if (appearance_data.vis_contents) {
    underlays = underlays.concat(
      appearance_data.vis_contents.filter(
        (x) => x.vis_flags && x.vis_flags & VIS_FLAGS.VIS_UNDERLAY,
      ),
    );
  }
  if (underlays.length > 0) {
    appearance.underlays = underlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Underlay,
          depth + 1,
          appearances,
          planeFilter,
          hideEmissives,
          keepTogether ||
            !!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER),
        ),
      )
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
    if (
      appearance.hidden === HiddenState.Hidden &&
      appearance.underlays.filter((x) => x.hidden !== HiddenState.Hidden)
        .length > 0
    )
      appearance.hidden = HiddenState.VisibleChild;
  }

  // Process overlays
  let overlays = appearance_data.overlays ? [...appearance_data.overlays] : [];
  if (appearance_data.vis_contents) {
    overlays = overlays.concat(
      appearance_data.vis_contents.filter(
        (x) => !x.vis_flags || !(x.vis_flags & VIS_FLAGS.VIS_UNDERLAY),
      ),
    );
  }
  if (overlays.length > 0) {
    appearance.overlays = overlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Overlay,
          depth + 1,
          appearances,
          planeFilter,
          hideEmissives,
          keepTogether ||
            !!(appearance.data.flags & APPEARANCE_FLAGS.KEEP_TOGETHER),
        ),
      )
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.type === AppearanceType.Atom &&
            b.data.type !== AppearanceType.Atom
            ? 1
            : a.data.type !== AppearanceType.Atom &&
                b.data.type === AppearanceType.Atom
              ? -1
              : a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
    if (
      appearance.hidden === HiddenState.Hidden &&
      appearance.overlays.filter((x) => x.hidden !== HiddenState.Hidden)
        .length > 0
    )
      appearance.hidden = HiddenState.VisibleChild;
  }
  return appearance;
}

function getAppearanceHeight(appearance: Appearance) {
  const TITLEBAR = 27;
  const COLUMN_BREAK = 20;
  let rows = 0;
  if (appearance.data.icon) rows++;
  if (appearance.data.icon_state) rows++;
  if (appearance.data.layer) rows++;
  if (appearance.data.plane) rows++;
  let height = COLUMN_BREAK + TITLEBAR + rows * 15 + (rows - 1) * 6 - 8;
  if (appearance.data.embed_icon) height += 64 + 6;
  if (appearance.data.embed_icon_error) height += 70;
  return height;
}

export function isEmissive(appearance: Appearance) {
  // In goonstation, PLANE_LIGHTING (-90) is the emissive plane, anything there is emissive
  return appearance.data.plane_true === -90;
}

export function isEmissiveBlocker(appearance: Appearance) {
  // Emissive blockers are black overlays on PLANE_LIGHTING that mask out emission
  if (appearance.data.plane_true !== -90 || !appearance.data.color)
    return false;
  if (appearance.data.color === '#000000') return true;
  if (!Array.isArray(appearance.data.color)) return false;
  const colorMatrix = appearance.data.color as number[];
  for (let i = 0; i < colorMatrix.length; i++) {
    if (colorMatrix[i] !== 0 && i !== 15) return false;
  }
  return true;
}

function getAppearanceWidth(
  appearance: Appearance,
  layerToText: Record<string, number>,
  planeToText: Record<string, number>,
) {
  return Math.max(
    textWidth(
      (appearance.data.name || appearance.data.icon_state) +
        (isEmissive(appearance)
          ? ' (Emissive)'
          : isEmissiveBlocker(appearance)
            ? ' (Emissive Blocker)'
            : ''),
      'Verdana, Geneva',
      12,
    ) + 18,
    textWidth(`icon: ${appearance.data.icon}`, 'Verdana, Geneva', 12) + 12,
    textWidth(
      `icon_state: ${appearance.data.icon_state}`,
      'Verdana, Geneva',
      12,
    ) + 12,
    layerToText
      ? textWidth(
          `layer: ${getReadableLayer(appearance, layerToText)}`,
          'Verdana, Geneva',
          12,
        ) + 12
      : 0,
    planeToText
      ? textWidth(
          `plane: ${getReadablePlane(appearance, planeToText)}`,
          'Verdana, Geneva',
          12,
        ) + 12
      : 0,
    150,
  );
}

export function getReadableLayer(
  appearance: Appearance,
  layerToText: Record<string, number>,
) {
  return (
    (appearance.data.layer_text_override ||
      Object.keys(layerToText).find(
        (x) => layerToText[x] === appearance.data.layer,
      ) ||
      '') + (appearance.data.layer !== -1 ? ` (${appearance.data.layer})` : '')
  );
}

export function getReadablePlane(
  appearance: Appearance,
  planeToText: Record<string, number>,
) {
  return (
    (Object.keys(planeToText).find(
      (x) => planeToText[x] === appearance.data.plane_true,
    ) || appearance.data.plane_true.toString()) +
    (appearance.data.plane !== -32767 ? ` (${appearance.data.plane})` : '')
  );
}

function parseAppearanceData(
  mainAppearance: AppearanceData,
  layerToText: Record<string, number>,
  planeToText: Record<string, number>,
  planeFilter: number | null,
  hideEmissives: boolean,
): AppearanceMap {
  const appearances: AppearanceMap = {};
  const primary: Appearance = mapAppearance(
    mainAppearance,
    null,
    AppearanceParentType.None,
    0,
    appearances,
    planeFilter,
    hideEmissives,
    !!(mainAppearance.flags & APPEARANCE_FLAGS.KEEP_TOGETHER),
  );

  const sourceMap: Record<string, Appearance> = {};
  Object.values(appearances).forEach((element) => {
    if (element.data.render_target)
      sourceMap[element.data.render_target] = element;
  });

  Object.values(appearances).forEach((element) => {
    if (element.data.render_source && element.data.render_source in sourceMap) {
      if (sourceMap[element.data.render_source].renderTargetTo === null)
        sourceMap[element.data.render_source].renderTargetTo = [];
      sourceMap[element.data.render_source].renderTargetTo!.push(element);
    }
  });

  // Position children relative to parent
  const STACK_COLUMN_GAP = 60;
  const VERTICAL_APPEARANCE_GAP = 15;
  const CENTRAL_APPEARANCE_GAP = 30;
  const KEEP_APART_TOGETHER_GAP = 18;
  const KEEP_APART_TOGETHER_GAP_TOP = 30;

  function positionChildren(appearance: Appearance) {
    const height = getAppearanceHeight(appearance);

    if (appearance.overlays) {
      let minHeight = -height / 2 + CENTRAL_APPEARANCE_GAP / 2;
      let totalOverlayHeight = 0;
      for (let i = 0; i < appearance.overlays.length; i++) {
        const overlay = appearance.overlays[i];
        if (overlay.hidden === HiddenState.Hidden) continue;
        positionChildren(overlay);
        const overlayBounds = getBoundingBox(overlay);
        overlay.boundingBox = overlayBounds;
        overlay.relativePosition.x =
          -STACK_COLUMN_GAP -
          getAppearanceWidth(overlay, layerToText, planeToText);
        overlay.relativePosition.y = -minHeight - overlayBounds[1].y;
        const totalHeight =
          overlayBounds[1].y - overlayBounds[0].y + VERTICAL_APPEARANCE_GAP;
        minHeight += totalHeight;
        totalOverlayHeight += totalHeight;
      }
      // If we don't have any underlays, shift all overlays down
      if (
        !appearance.underlays?.filter((x) => x.hidden !== HiddenState.Hidden)
          .length
      ) {
        const staticShift =
          CENTRAL_APPEARANCE_GAP / 2 +
          (totalOverlayHeight - VERTICAL_APPEARANCE_GAP) / 2;
        for (let i = 0; i < appearance.overlays.length; i++) {
          appearance.overlays[i].relativePosition.y += staticShift;
        }
      }
    }

    if (appearance.underlays) {
      let minHeight = height / 2 - CENTRAL_APPEARANCE_GAP / 2;
      let totalUnderlayHeight = 0;
      for (let i = 0; i < appearance.underlays.length; i++) {
        const underlay = appearance.underlays[i];
        if (underlay.hidden === HiddenState.Hidden) continue;
        positionChildren(underlay);
        const underlayBounds = getBoundingBox(underlay);
        underlay.boundingBox = underlayBounds;
        underlay.relativePosition.x =
          -STACK_COLUMN_GAP -
          getAppearanceWidth(underlay, layerToText, planeToText);
        underlay.relativePosition.y = minHeight + getAppearanceHeight(underlay);
        const totalHeight =
          underlayBounds[1].y - underlayBounds[0].y + VERTICAL_APPEARANCE_GAP;
        minHeight += totalHeight;
        totalUnderlayHeight += totalHeight;
      }
      // If we don't have any overlays, shift all underlays up
      if (
        !appearance.overlays?.filter((x) => x.hidden !== HiddenState.Hidden)
          .length
      ) {
        const staticShift =
          CENTRAL_APPEARANCE_GAP / 2 +
          (totalUnderlayHeight - VERTICAL_APPEARANCE_GAP) / 2;
        for (let i = 0; i < appearance.underlays.length; i++) {
          appearance.underlays[i].relativePosition.y -= staticShift;
        }
      }
    }
  }

  // Get bounding box
  function getBoundingBox(appearance: Appearance): [Coordinates, Coordinates] {
    let minX = 0;
    let minY = 0;
    let maxX = getAppearanceWidth(appearance, layerToText, planeToText);
    let maxY = getAppearanceHeight(appearance);

    if (appearance.underlays) {
      for (const underlay of appearance.underlays) {
        if (underlay.hidden === HiddenState.Hidden) continue;
        const underlayBox = getBoundingBox(underlay);
        minX = Math.min(minX, underlayBox[0].x + underlay.relativePosition.x);
        minY = Math.min(minY, underlayBox[0].y + underlay.relativePosition.y);
        maxX = Math.max(maxX, underlayBox[1].x + underlay.relativePosition.x);
        maxY = Math.max(maxY, underlayBox[1].y + underlay.relativePosition.y);
      }
    }

    if (appearance.overlays) {
      for (const overlay of appearance.overlays) {
        if (overlay.hidden === HiddenState.Hidden) continue;
        const overlayBox = getBoundingBox(overlay);
        minX = Math.min(minX, overlayBox[0].x + overlay.relativePosition.x);
        minY = Math.min(minY, overlayBox[0].y + overlay.relativePosition.y);
        maxX = Math.max(maxX, overlayBox[1].x + overlay.relativePosition.x);
        maxY = Math.max(maxY, overlayBox[1].y + overlay.relativePosition.y);
      }
    }

    if (
      appearance.data.flags &
      (APPEARANCE_FLAGS.KEEP_TOGETHER | APPEARANCE_FLAGS.KEEP_APART)
    ) {
      minX -= KEEP_APART_TOGETHER_GAP;
      minY -= KEEP_APART_TOGETHER_GAP_TOP;
      maxX += KEEP_APART_TOGETHER_GAP;
      maxY += KEEP_APART_TOGETHER_GAP;
    }

    return [
      { x: minX, y: minY },
      { x: maxX, y: maxY },
    ];
  }

  positionChildren(primary);
  primary.boundingBox = getBoundingBox(primary);
  return appearances;
}

export function AppearanceDebug() {
  const { data, act } = useBackend<AppearanceDebugData>();
  const {
    mainAppearance,
    planeToText,
    layerToText,
    flagsToText,
    visToText,
    blendToText,
    mapRefHover,
    mapRefSelected,
    updateWarning,
  } = data;
  const [planeFilter, setPlaneFilter] = useState<string | null>(null);
  const [hideEmissives, setHideEmissives] = useState(false);

  const appsProcessed = parseAppearanceData(
    mainAppearance,
    layerToText,
    planeToText,
    planeFilter ? planeToText[planeFilter] : null,
    hideEmissives,
  );
  const [zoomToX, setZoomToX] = useState<number>();
  const [zoomToY, setZoomToY] = useState<number>();
  const [selection, setSelection] = useState<number | null>(null);

  const hoverTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);
  const lastHoverId = useRef<number | null>(null);
  const debouncedHover = useCallback(
    (id: number) => {
      if (lastHoverId.current === id) return;
      if (hoverTimeout.current) clearTimeout(hoverTimeout.current);
      hoverTimeout.current = setTimeout(() => {
        lastHoverId.current = id;
        act('swapMapViewHover', { id });
      }, 90); // 90ms
    },
    [act],
  );

  function mapPosition(
    appearance: Appearance,
    positions: Record<number, Coordinates>,
  ) {
    if (appearance.data.id in positions) return positions[appearance.data.id];
    const position: Coordinates = {
      x: appearance.relativePosition.x,
      y: appearance.relativePosition.y,
    };
    if (appearance.parent) {
      if (!(appearance.parent.data.id in positions))
        mapPosition(appearance.parent, positions);
      position.x += positions[appearance.parent.data.id].x;
      position.y += positions[appearance.parent.data.id].y;
    }
    positions[appearance.data.id] = position;
    return position;
  }

  const NODE_PADDING = 20;

  const appearancePositions: Record<number, Coordinates> = {};
  const connections: Connection[] = [];
  let connectionIndex = 0;
  for (const key of Object.keys(appsProcessed)) {
    const appearance = appsProcessed[key as unknown as number];
    if (!appearance.parent || appearance.hidden === HiddenState.Hidden)
      continue;
    const position = mapPosition(appearance, appearancePositions);
    const parentPosition = mapPosition(appearance.parent, appearancePositions);
    const childWidth = getAppearanceWidth(appearance, layerToText, planeToText);
    const childHeight = getAppearanceHeight(appearance);
    const parentHeight = getAppearanceHeight(appearance.parent);

    // All children are to the LEFT of parent
    connections.push({
      from: {
        x: position.x + childWidth - NODE_PADDING,
        y: position.y + childHeight / 2,
      },
      to: {
        x: parentPosition.x + NODE_PADDING,
        y: parentPosition.y + parentHeight / 2,
      },
      index: connectionIndex,
      color: `hsl(${60 + 5 * (connectionIndex % 30)}, 50%, ${50 + (connectionIndex % 30)}%)`,
    });
    connectionIndex++;
  }

  return (
    <AppearanceDebugContext.Provider
      value={{
        act,
        planeToText,
        layerToText,
        flagsToText,
        visToText,
        blendToText,
        mapRefHover,
        mapRefSelected,
        appsProcessed,
        zoomToX,
        setZoomToX,
        zoomToY,
        setZoomToY,
      }}
    >
      <Window
        width={1600}
        height={840}
        title={`OverFlayer${mainAppearance.name || mainAppearance.icon_state ? `: ${mainAppearance.name || mainAppearance.icon_state}` : ''}${updateWarning ? ' (Out of date)' : ''}`}
        buttons={
          <Stack fill>
            <Stack.Item
              width={`${
                Math.max(
                  90,
                  textWidth(
                    Object.keys(planeToText)
                      .sort((a, b) => a.length - b.length)
                      .pop() as string,
                    'Verdana, Geneva',
                    12,
                  ),
                ) + 40
              }px`}
            >
              <Dropdown
                options={['(All Planes)', ...Object.keys(planeToText).sort()]}
                placeholder="Filter by Plane"
                selected={planeFilter || '(All Planes)'}
                onSelected={(value) => {
                  setSelection(null);
                  if (value === '(All Planes)' || !(value in planeToText))
                    setPlaneFilter(null);
                  else setPlaneFilter(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color={hideEmissives ? 'green' : 'transparent'}
                tooltip="Hide Emissives"
                icon="ban"
                selected={hideEmissives}
                onClick={() => {
                  setSelection(null);
                  setHideEmissives(!hideEmissives);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="Refresh Appearance"
                icon="arrows-rotate"
                onClick={() => act('refreshAppearance')}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <Window.Content
          style={{
            backgroundImage: 'none',
          }}
        >
          {!!mapRefHover && (
            <Box
              position="absolute"
              left="12px"
              top="42px"
              width="140px"
              height="140px"
              style={{
                zIndex: 3,
                pointerEvents: 'none',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: '#1a1a1a',
              }}
            >
              <ByondUi
                width="128px"
                height="128px"
                params={{
                  id: mapRefHover,
                  type: 'map',
                }}
              />
            </Box>
          )}
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Crect width='100' height='100' fill='%23282828'/%3E%3Cpath d='M100 0L0 0 0 100' fill='none' stroke='%23666' stroke-width='2'/%3E%3C/svg%3E"
            imageWidth={100}
            initialLeft={500}
            initialTop={-1350}
            zoomPadding={selection !== null ? 400 : 0}
            zoomToX={-(zoomToX || 0) + 525}
            zoomToY={-(zoomToY || 0) + 300}
          >
            {Object.entries(appsProcessed)
              .filter((keyValue) => keyValue[1].hidden !== HiddenState.Hidden)
              .map((keyValue) => (
                <AppearanceBox
                  key={keyValue[0]}
                  appearance={keyValue[1]}
                  position={mapPosition(keyValue[1], appearancePositions)}
                  onMouseEnter={() => debouncedHover(keyValue[1].data.id)}
                  onClick={() => {
                    setSelection(keyValue[1].data.id);
                    setZoomToX(mapPosition(keyValue[1], appearancePositions).x);
                    setZoomToY(mapPosition(keyValue[1], appearancePositions).y);
                    act('swapMapViewSelected', {
                      id: keyValue[1].data.id,
                    });
                  }}
                />
              ))}
            <Connections connections={connections} />
          </InfinitePlane>
          {selection !== null && (
            <AppearanceInfo
              appearance={
                Object.values(appsProcessed).find(
                  (x) => x.data.id === selection,
                ) as Appearance
              }
              onClose={() => setSelection(null)}
            />
          )}
        </Window.Content>
      </Window>
    </AppearanceDebugContext.Provider>
  );
}
