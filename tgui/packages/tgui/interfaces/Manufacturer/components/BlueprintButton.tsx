/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { BooleanLike } from 'common/react';
import { memo, useCallback } from 'react';
import {
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import { shallowDiffers } from 'tgui-core/react';

import { truncate } from '../../../format';
import { BlueprintButtonStyle, BlueprintMiniButtonStyle } from '../constant';
import type { ManufacturableData } from '../type';
import { ButtonWithBadge } from './ButtonWithBadge';
import { CenteredText } from './CenteredText';

const getBlueprintTime = (time, manufacturerSpeed) => {
  return round(time / 10 / manufacturerSpeed, 0.01);
};

export type BlueprintButtonProps = {
  onBlueprintRemove: (byondRef: string) => void;
  onVendProduct: (byondRef: string) => void;
  blueprintData: ManufacturableData;
  blueprintProducibilityData: Record<string, BooleanLike>;
  manufacturerSpeed: number;
  deleteAllowed: boolean;
  hasPower: boolean;
};

export const BlueprintButtonView = (props: BlueprintButtonProps) => {
  const {
    onBlueprintRemove,
    onVendProduct,
    blueprintData,
    blueprintProducibilityData,
    manufacturerSpeed,
    deleteAllowed,
    hasPower,
  } = props;
  // Condense producability
  let safeBlueprintProducibilityData = blueprintProducibilityData;
  let showSoftError = false;
  if (
    blueprintProducibilityData === undefined ||
    blueprintProducibilityData.length === 0
  ) {
    // The key doesn't actually show up here but this is all part of showing an imcoder blurb if this EVER happens (shouldn't)
    safeBlueprintProducibilityData = { '1-800-IMCODER': 0 };
    showSoftError = true;
  }
  const notProduceable = Object.values(safeBlueprintProducibilityData).some(
    (x) => !x,
  );
  const memoizedOnRemoveBlueprint = useCallback(
    () => onBlueprintRemove(blueprintData.byondRef),
    [blueprintData.byondRef, onBlueprintRemove],
  );
  const handleVendProduct = useCallback(
    () => onVendProduct(blueprintData.byondRef),
    [blueprintData.byondRef, onVendProduct],
  );
  // Don't include this flavor if we only output one item, because if so, then we know what we're making
  const outputs =
    (blueprintData?.item_names?.length ?? 0) < 2 &&
    (blueprintData?.create ?? 0) < 2 &&
    !blueprintData?.apply_material ? null : (
      <>
        <br />
        Outputs: <br />
        {blueprintData?.item_names?.map((value: string, index: number) => (
          <b key={index}>
            {`${blueprintData.create}x ${value}`}
            <br />
          </b>
        ))}
      </>
    );
  const content_requirements = (
    <Section
      title="Requirements"
      buttons={
        <Button icon="hourglass" backgroundColor="rgba(0,0,0,0)">
          {getBlueprintTime(blueprintData.time, manufacturerSpeed)}s
        </Button>
      }
    >
      <LabeledList>
        {Object.keys(blueprintData.requirement_data).map(
          (value: string, index: number) => (
            <LabeledList.Item
              key={index}
              labelColor={
                safeBlueprintProducibilityData[
                  blueprintData.requirement_data[value].name
                ]
                  ? undefined
                  : 'bad'
              }
              label={blueprintData.requirement_data[value].name}
              textAlign="right"
            >
              {blueprintData?.requirement_data?.[value].amount / 10}
            </LabeledList.Item>
          ),
        )}
      </LabeledList>
      {outputs}
    </Section>
  );

  const canDelete = blueprintData.isMechBlueprint && deleteAllowed;
  // /datum/manufacture contains no description of its 'contents', so the first item works
  const content_info = canDelete
    ? 'Click this to remove the blueprint from the fabricator.'
    : (blueprintData?.item_descriptions?.[0] ?? '');

  return (
    <Stack style={{ display: BlueprintButtonStyle.Display }}>
      <Stack.Item
        ml={BlueprintButtonStyle.MarginX}
        my={BlueprintButtonStyle.MarginY}
      >
        <ButtonWithBadge
          width={BlueprintButtonStyle.Width}
          height={BlueprintButtonStyle.Height}
          key={blueprintData.name}
          imagePath={blueprintData.img}
          disabled={!hasPower || notProduceable}
          onClick={handleVendProduct}
        >
          <CenteredText
            height={BlueprintButtonStyle.Height}
            text={
              showSoftError
                ? 'Call 1-800-IMCODER'
                : truncate(blueprintData?.name ?? '', 40)
            }
          />
        </ButtonWithBadge>
      </Stack.Item>
      <Stack.Item mr={BlueprintButtonStyle.MarginX}>
        <Stack inline vertical my={BlueprintButtonStyle.MarginY}>
          <Stack.Item mb={BlueprintMiniButtonStyle.Spacing}>
            <Tooltip content={content_info}>
              <Button
                width={BlueprintMiniButtonStyle.Width}
                height={
                  (BlueprintButtonStyle.Height -
                    BlueprintMiniButtonStyle.Spacing) /
                  2
                }
                align="center"
                disabled={canDelete ? false : !hasPower || notProduceable}
                onClick={
                  canDelete ? memoizedOnRemoveBlueprint : handleVendProduct
                }
                py={BlueprintMiniButtonStyle.IconSize / 2}
              >
                <Icon
                  name={canDelete ? 'trash' : 'info'}
                  size={BlueprintMiniButtonStyle.IconSize}
                />
              </Button>
            </Tooltip>
          </Stack.Item>
          <Stack.Item mt={BlueprintMiniButtonStyle.Spacing}>
            <Tooltip content={content_requirements}>
              <Button
                width={BlueprintMiniButtonStyle.Width}
                height={
                  (BlueprintButtonStyle.Height -
                    BlueprintMiniButtonStyle.Spacing) /
                  2
                }
                align="center"
                disabled={!hasPower || notProduceable}
                onClick={handleVendProduct}
                py={BlueprintMiniButtonStyle.IconSize / 2}
              >
                <Icon name="gear" size={BlueprintMiniButtonStyle.IconSize} />
              </Button>
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const BlueprintButton = memo(
  BlueprintButtonView,
  (prevProps, nextProps) => {
    const {
      blueprintData: prevBlueprintData,
      blueprintProducibilityData: prevBlueprintProducibilityData,
      ...prevRest
    } = prevProps;
    const {
      blueprintData: nextBlueprintData,
      blueprintProducibilityData: nextBlueprintProducibilityData,
      ...nextRest
    } = nextProps;
    if (shallowDiffers(prevRest, nextRest)) {
      return false;
    }
    // Special check for blueprintData as it has moving parts and otherwise pretends to change on material swap
    // The only truly constant thing it checks is byondRef as NOTHING else should change if the ref doesn't
    if (prevProps.blueprintData.byondRef !== nextProps.blueprintData.byondRef) {
      return false;
    }
    // Slightly more in depth check for the producibility data to see if it actually changed
    if (
      shallowDiffers(
        prevBlueprintProducibilityData,
        nextBlueprintProducibilityData,
      )
    ) {
      return false;
    }
    return true;
  },
);
