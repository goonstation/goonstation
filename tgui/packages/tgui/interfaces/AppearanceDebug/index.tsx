import { useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  InfinitePlane,
  Stack,
} from 'tgui-core/components';
import { Window } from '../../layouts';
import { AppearanceBox } from './AppearanceBox';
import { AppearanceInfo } from './AppearanceInfo';
import { type Connection, Connections } from './Connections';
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
  return height;
}

export function isEmissive(appearance: Appearance) {
  // Emissive appearances typically have a specific plane
  // For goonstation, we'll use PLANE_SELFILLUM (-80) as the emissive equivalent
  const EMISSIVE_PLANE = -80;
  if (appearance.data.plane_true !== EMISSIVE_PLANE) return false;
  if (!appearance.data.color) return false;
  if (
    appearance.data.color === '#FFFFFF' ||
    appearance.data.color === '#ffffff'
  )
    return true;
  if (!Array.isArray(appearance.data.color)) return false;
  const colorMatrix = appearance.data.color as number[];
  for (let i = 0; i < colorMatrix.length; i++) {
    if (colorMatrix[i] !== 0 && i !== 15 && colorMatrix[i] !== 1) return false;
  }
  return true;
}

export function isEmissiveBlocker(appearance: Appearance) {
  const EMISSIVE_PLANE = -80;
  if (appearance.data.plane_true !== EMISSIVE_PLANE || !appearance.data.color)
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
  function positionChildren(appearance: Appearance) {
    const width = getAppearanceWidth(appearance, layerToText, planeToText);
    const height = getAppearanceHeight(appearance);
    const NODE_PADDING = 20;

    let underlayY = height - 40;
    if (appearance.underlays) {
      for (const underlay of appearance.underlays) {
        if (underlay.hidden === HiddenState.Hidden) continue;
        underlay.relativePosition = {
          x: -(
            getAppearanceWidth(underlay, layerToText, planeToText) +
            NODE_PADDING
          ),
          y: underlayY,
        };
        underlayY += getAppearanceHeight(underlay) + NODE_PADDING;
        positionChildren(underlay);
      }
    }

    let overlayY = 40;
    if (appearance.overlays) {
      for (const overlay of appearance.overlays) {
        if (overlay.hidden === HiddenState.Hidden) continue;
        overlay.relativePosition = {
          x: width + NODE_PADDING,
          y: overlayY,
        };
        overlayY += getAppearanceHeight(overlay) + NODE_PADDING;
        positionChildren(overlay);
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
  const OVERLAY_NODE_INPUT_PADDING = 60;
  const UNDERLAY_NODE_INPUT_PADDING = 40;

  const appearancePositions: Record<number, Coordinates> = {};
  const connections: Connection[] = [];
  let connectionIndex = 0;
  for (const key of Object.keys(appsProcessed)) {
    const appearance = appsProcessed[key as unknown as number];
    if (!appearance.parent || appearance.hidden === HiddenState.Hidden)
      continue;
    const position = mapPosition(appearance, appearancePositions);
    const parentPosition = mapPosition(appearance.parent, appearancePositions);
    const parentWidth = getAppearanceWidth(
      appearance.parent,
      layerToText,
      planeToText,
    );
    const childWidth = getAppearanceWidth(appearance, layerToText, planeToText);
    const childHeight = getAppearanceHeight(appearance);

    if (appearance.parentType === AppearanceParentType.Overlay) {
      // Overlay is to the RIGHT of parent: line from parent right → child left
      connections.push({
        from: {
          x: parentPosition.x + parentWidth - NODE_PADDING,
          y: parentPosition.y + OVERLAY_NODE_INPUT_PADDING,
        },
        to: {
          x: position.x + NODE_PADDING,
          y: position.y + childHeight / 2,
        },
        index: connectionIndex,
        color: `hsl(${60 + 5 * (connectionIndex % 30)}, 50%, ${50 + (connectionIndex % 30)}%)`,
      });
    } else {
      // Underlay is to the LEFT of parent: line from child right → parent left
      connections.push({
        from: {
          x: position.x + childWidth - NODE_PADDING,
          y: position.y + childHeight / 2,
        },
        to: {
          x: parentPosition.x + NODE_PADDING,
          y:
            parentPosition.y +
            getAppearanceHeight(appearance.parent) -
            UNDERLAY_NODE_INPUT_PADDING,
        },
        index: connectionIndex,
        color: `hsl(${60 + 5 * (connectionIndex % 30)}, 50%, ${50 + (connectionIndex % 30)}%)`,
      });
    }
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
                options={Object.keys(planeToText).sort()}
                placeholder="Filter by Plane"
                selected={planeFilter || ''}
                onSelected={(value) => {
                  setSelection(null);
                  if (!(value in planeToText)) setPlaneFilter(null);
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
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Crect width='100' height='100' fill='%23282828'/%3E%3Cpath d='M100 0L0 0 0 100' fill='none' stroke='%23333' stroke-width='1'/%3E%3C/svg%3E"
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
                  onClick={() => {
                    setSelection(keyValue[1].data.id);
                    setZoomToX(mapPosition(keyValue[1], appearancePositions).x);
                    setZoomToY(mapPosition(keyValue[1], appearancePositions).y);
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
