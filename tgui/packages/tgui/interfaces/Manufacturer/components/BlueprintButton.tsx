/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Button, Icon, LabeledList, Section, Stack, Tooltip } from '../../../components';
import { ManufacturableData, RequirementData, ResourceData } from '../type';
import { round } from 'common/math';
import { ButtonWithBadge } from './ButtonWithBadge';
import { CenteredText } from './CenteredText';
import { truncate } from '../../../format';
import { BlueprintButtonStyle, BlueprintMiniButtonStyle } from '../constant';

const getBlueprintTime = (time, manufacturerSpeed) => {
  return round(time / 10 / manufacturerSpeed, 0.01);
};

export type BlueprintButtonProps = {
  actionRemoveBlueprint: (byondRef:string) => void;
  actionVendProduct: (byondRef:string) => void;
  blueprintData: ManufacturableData;
  materialData: ResourceData[];
  manufacturerSpeed: number;
  deleteAllowed: boolean;
  hasPower: boolean;
}


/*
Get whether or not there is a sufficient amount to make. does NOT affect sanity checks on the DM side,
this just offloads some of the computation to the client.

Consequently, if the checks on the .dm end change, this has to change as well.

Only the DM checks matter for actually making the item though, this just enables and disables buttons /
shows what materials are missing.
*/
const getProductionSatisfaction = (
  requirement_data:RequirementData[],
  materials_stored:ResourceData[]) =>
{
  if (!requirement_data || !materials_stored) {
    return false;
  }
  // Copy values of mats stored to edit in case we need to try the same material twice
  let material_amts_predicted:Record<string, number> = {};
  materials_stored.forEach((value:ResourceData) => (
    material_amts_predicted[value.byondRef] = value.amount
  ));
  let patterns_satisfied:boolean[] = [];
  for (let i in requirement_data) {
    const target_pattern = requirement_data[i].id;
    const target_amount = requirement_data[i].amount / 10;
    const matchingMaterial = materials_stored.find((material:ResourceData) => (
      (material_amts_predicted[material.byondRef] >= target_amount) && material.satisfies?.includes(target_pattern)
    ));
    if (matchingMaterial === undefined) {
      patterns_satisfied.push(false);
      continue;
    }
    material_amts_predicted[matchingMaterial.byondRef] -= target_amount;
    patterns_satisfied.push(true);
  }
  return patterns_satisfied;
};

export const BlueprintButton = (props:BlueprintButtonProps) => {

  const {
    actionRemoveBlueprint,
    actionVendProduct,
    blueprintData,
    materialData,
    manufacturerSpeed,
    deleteAllowed,
    hasPower,
  } = props;
  const blueprintSatisfaction = getProductionSatisfaction(
    blueprintData.requirement_data,
    materialData,
  );
  if (!blueprintSatisfaction) {
    return null;
  }
  // Condense producability
  const notProduceable = blueprintSatisfaction.includes(false);
  // Don't include this flavor if we only output one item, because if so, then we know what we're making
  const outputs = ((blueprintData?.item_names?.length ?? 0) < 2
    && (blueprintData?.create ?? 0) < 2
    && !blueprintData?.apply_material) ? null : (
      <>
        <br />
        Outputs: <br />
        {blueprintData?.item_names?.map((value:string, index:number) => (
          <b key={index}>
            {blueprintData.create}x {value}<br />
          </b>
        ))}
      </>
    );
  const content_requirements = (
    <Section
      title="Requirements"
      buttons={<Button icon="hourglass" backgroundColor="rgba(0,0,0,0)">{getBlueprintTime(blueprintData.time, manufacturerSpeed)}s</Button>}
    >
      <LabeledList>
        {Object.keys(blueprintData.requirement_data).map((value:string, index:number) => (
          <LabeledList.Item
            key={index}
            labelColor={(blueprintSatisfaction[index]) ? undefined : "bad"}
            label={blueprintData?.requirement_data?.[value].name}
            textAlign="right"
          >
            {blueprintData?.requirement_data?.[value].amount/10}
          </LabeledList.Item>
        ))}
      </LabeledList>
      {outputs}
    </Section>
  );

  const canDelete = blueprintData.isMechBlueprint && deleteAllowed;
  // /datum/manufacture contains no description of its 'contents', so the first item works
  let content_info = "";
  if (canDelete) {
    content_info = "Click this to remove the blueprint from the fabricator.";
  }
  else {
    content_info = (blueprintData?.item_descriptions?.[0] ?? "");
  }
  return (
    <Stack inline>
      <Stack.Item
        ml={BlueprintButtonStyle.MarginX}
        my={BlueprintButtonStyle.MarginY}
      >
        <ButtonWithBadge
          width={BlueprintButtonStyle.Width}
          height={BlueprintButtonStyle.Height}
          key={blueprintData.name}
          imagePath={blueprintData.img}
          disabled={(!hasPower || notProduceable)}
          onClick={() => actionVendProduct(blueprintData.byondRef)}
        >
          <CenteredText
            height={BlueprintButtonStyle.Height}
            text={truncate(blueprintData?.name ?? "", 40)}
          />
        </ButtonWithBadge>
      </Stack.Item>
      <Stack.Item
        mr={BlueprintButtonStyle.MarginX}
      >
        <Stack vertical
          my={BlueprintButtonStyle.MarginY}
        >
          <Stack.Item
            mb={BlueprintMiniButtonStyle.Spacing}
          >
            <Tooltip
              content={content_info}
            >
              <Button
                width={BlueprintMiniButtonStyle.Width}
                height={(BlueprintButtonStyle.Height-BlueprintMiniButtonStyle.Spacing)/2}
                align="center"
                disabled={canDelete ? false : (!hasPower || notProduceable)}
                onClick={() => (canDelete ? (
                  actionRemoveBlueprint(blueprintData.byondRef)
                ) : actionVendProduct(blueprintData.byondRef)
                )}
                py={BlueprintMiniButtonStyle.IconSize/2}
              >
                <Icon
                  name={canDelete ? "trash" : "info"}
                  size={BlueprintMiniButtonStyle.IconSize}
                />
              </Button>
            </Tooltip>
          </Stack.Item>
          <Stack.Item
            mt={BlueprintMiniButtonStyle.Spacing}
          >
            <Tooltip
              content={content_requirements}
            >
              <Button
                width={BlueprintMiniButtonStyle.Width}
                height={(BlueprintButtonStyle.Height-BlueprintMiniButtonStyle.Spacing)/2}
                align="center"
                disabled={(!hasPower || notProduceable)}
                onClick={() => actionVendProduct(blueprintData.byondRef)}
                py={BlueprintMiniButtonStyle.IconSize/2}
              >
                <Icon
                  name="gear"
                  size={BlueprintMiniButtonStyle.IconSize}
                />
              </Button>
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
