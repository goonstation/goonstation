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

import { truncate } from '../../../format';
import { BlueprintButtonStyle, BlueprintMiniButtonStyle } from '../constant';
import { ManufacturableData } from '../type';
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
  const notProduceable = !!Object.keys(blueprintProducibilityData).find(
    (requirement_name: string) =>
      (!!blueprintProducibilityData[requirement_name] === false) === true,
  );
  const memoizedOnRemoveBlueprint = useCallback(
    () => onBlueprintRemove(blueprintData.byondRef),
    [blueprintData.byondRef],
  );
  const handleVendProduct = useCallback(
    () => onVendProduct(blueprintData.byondRef),
    [blueprintData.byondRef],
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
            {blueprintData.create}x {value}
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
                blueprintProducibilityData[
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
  let content_info = '';
  if (canDelete) {
    content_info = 'Click this to remove the blueprint from the fabricator.';
  } else {
    content_info = blueprintData?.item_descriptions?.[0] ?? '';
  }
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
            text={truncate(blueprintData?.name ?? '', 40)}
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
    if (
      prevProps.manufacturerSpeed !== nextProps.manufacturerSpeed ||
      prevProps.deleteAllowed !== nextProps.deleteAllowed ||
      prevProps.hasPower !== nextProps.hasPower
    ) {
      return false;
    }
    // Special check for blueprintData as it has moving parts and otherwise pretends to change on material swap
    // The only truly constant thing it checks is byondRef as NOTHING else should change if the ref doesn't
    if (prevProps.blueprintData.byondRef !== nextProps.blueprintData.byondRef) {
      return false;
    }
    // Slightly more in depth check for the producibility data to see if it actually changed
    for (let key in prevProps.blueprintProducibilityData) {
      if (
        prevProps.blueprintProducibilityData[key] !==
        nextProps.blueprintProducibilityData[key]
      ) {
        return false;
      }
    }
    return true;
  },
);
