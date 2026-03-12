/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { BooleanLike } from 'common/react';
import { memo, useCallback } from 'react';
import { Button, LabeledList, Section } from 'tgui-core/components';
import { round } from 'tgui-core/math';
import { shallowDiffers } from 'tgui-core/react';

import { ItemButton } from '../../../components/goonstation/ItemButton';
import { truncate } from '../../../format';
import type { ManufacturableData } from '../type';

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
    <ItemButton
      image={blueprintData.img}
      disabled={!hasPower || notProduceable}
      onMainButtonClick={handleVendProduct}
      name={
        showSoftError
          ? 'Call 1-800-IMCODER'
          : truncate(blueprintData?.name ?? '', 40)
      }
      sideButton1={{
        icon: canDelete ? 'trash' : 'info',
        tooltip: content_info,
        disabled: canDelete ? false : !hasPower || notProduceable,
        onClick: canDelete ? memoizedOnRemoveBlueprint : handleVendProduct,
      }}
      sideButton2={{
        icon: 'gear',
        tooltip: content_requirements,
        disabled: !hasPower || notProduceable,
        onClick: handleVendProduct,
      }}
    />
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
