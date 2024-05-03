/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Button, Icon, LabeledList, Section, Stack, Tooltip } from '../../components';
import { BlueprintButtonData, ResourceData } from './type';
import { round } from 'common/math';
import { ButtonWithBadge } from './ButtonWithBadge';
import { CenteredText } from './CenteredText';
import { truncate } from '../../format';
import { BLUEPRINT_BUTTON_HEIGHT, BLUEPRINT_BUTTON_MARGINS_HORIZONTAL, BLUEPRINT_BUTTON_MARGINS_VERTICAL, BLUEPRINT_BUTTON_WIDTH, BLUEPRINT_MINIBUTTON_ICON_SIZE, BLUEPRINT_MINIBUTTON_INBETWEEN_SPACING, BLUEPRINT_MINIBUTTON_WIDTH } from './constant';

const getBlueprintTime = (time, manufacturerSpeed) => {
  return round(time / 10 / manufacturerSpeed, 0.01);
};

/*
Get whether or not there is a sufficient amount to make. does NOT affect sanity checks on the DM side,
this just offloads some of the computation to the client.

Consequently, if the checks on the .dm end change, this has to change as well.

Only the DM checks matter for actually making the item though, this just enables and disables buttons /
shows what materials are missing.
*/
const getProductionSatisfaction = (
  pattern_requirements:string[],
  amount_requirements:number[],
  materials_stored:ResourceData[]) =>
{
  // Copy values of mats stored to edit in case we need to try the same material twice
  let material_amts_predicted:Record<string, number> = {};
  materials_stored.forEach((value:ResourceData) => (
    material_amts_predicted[value.id] = value.amount
  ));
  let patterns_satisfied:boolean[] = [];
  for (let i in pattern_requirements) {
    const target_pattern = pattern_requirements[i];
    const target_amount = amount_requirements[i];
    const matchingMaterial = materials_stored.find((material:ResourceData) => (
      target_pattern === "ALL" || material.satisfies.find((pattern:string) => (pattern === target_pattern)) !== undefined
    ));
    if (matchingMaterial !== undefined && matchingMaterial.amount >= target_amount/10) {
      material_amts_predicted[i] -= target_amount/10;
      patterns_satisfied.push(true);
    }
    else {
      patterns_satisfied.push(false);
    }
  }
  return patterns_satisfied;
};

export const BlueprintButton = (props:BlueprintButtonData) => {

  const {
    actionVendProduct,
    blueprintData,
    materialData,
    manufacturerSpeed,
  } = props;
  const blueprintSatisfaction = getProductionSatisfaction(
    blueprintData.item_paths,
    blueprintData.item_amounts,
    materialData,
  );
  // Condense producability
  const notProduceable = blueprintSatisfaction.some((materialIsProducable:boolean) => materialIsProducable === false);
  // Don't include this flavor if we only output one item, because if so, then we know what we're making
  const outputs = (blueprintData.item_names.length < 2
    && blueprintData.create < 2
    && !blueprintData.apply_material) ? null : (
      <>
        <br />
        Outputs: <br />
        {blueprintData.item_names.map((value:string, index:number) => (
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
        {blueprintData.material_names.map((value:string, index:number) => (
          <LabeledList.Item
            key={index}
            labelColor={(blueprintSatisfaction[index]) ? undefined : "bad"}
            label={value}
            textAlign="right"
          >
            {blueprintData.item_amounts[index]/10}
          </LabeledList.Item>
        ))}
      </LabeledList>
      {outputs}
    </Section>
  );

  // /datum/manufacture contains no description of its 'contents', so the first item works
  let content_info = blueprintData.item_descriptions[0];
  return (
    <Stack inline>
      <Stack.Item
        ml={BLUEPRINT_BUTTON_MARGINS_HORIZONTAL}
        my={BLUEPRINT_BUTTON_MARGINS_VERTICAL}
      >
        <ButtonWithBadge
          width={BLUEPRINT_BUTTON_WIDTH}
          height={BLUEPRINT_BUTTON_HEIGHT}
          key={blueprintData.name}
          imagePath={blueprintData.img}
          disabled={notProduceable}
          onClick={() => actionVendProduct(blueprintData.byondRef)}
        >
          <CenteredText
            height={BLUEPRINT_BUTTON_HEIGHT}
            text={truncate(blueprintData.name, 40)}
          />
        </ButtonWithBadge>
      </Stack.Item>
      <Stack.Item
        mr={BLUEPRINT_BUTTON_MARGINS_HORIZONTAL}
      >
        <Stack vertical
          my={BLUEPRINT_BUTTON_MARGINS_VERTICAL}
        >
          <Stack.Item
            mb={BLUEPRINT_MINIBUTTON_INBETWEEN_SPACING}
          >
            <Tooltip
              content={content_info}
            >
              <Button
                width={BLUEPRINT_MINIBUTTON_WIDTH}
                height={(BLUEPRINT_BUTTON_HEIGHT-BLUEPRINT_MINIBUTTON_INBETWEEN_SPACING)/2}
                align="center"
                disabled={notProduceable}
                onClick={() => actionVendProduct(blueprintData.byondRef)}
                py={BLUEPRINT_MINIBUTTON_ICON_SIZE/2}
              >
                <Icon
                  name="info"
                  size={BLUEPRINT_MINIBUTTON_ICON_SIZE}
                />
              </Button>
            </Tooltip>
          </Stack.Item>
          <Stack.Item
            mt={BLUEPRINT_MINIBUTTON_INBETWEEN_SPACING}
          >
            <Tooltip
              content={content_requirements}
            >
              <Button
                width={BLUEPRINT_MINIBUTTON_WIDTH}
                height={(BLUEPRINT_BUTTON_HEIGHT-BLUEPRINT_MINIBUTTON_INBETWEEN_SPACING)/2}
                align="center"
                disabled={notProduceable}
                onClick={() => actionVendProduct(blueprintData.byondRef)}
                py={BLUEPRINT_MINIBUTTON_ICON_SIZE/2}
              >
                <Icon
                  name="gear"
                  size={BLUEPRINT_MINIBUTTON_ICON_SIZE}
                />
              </Button>
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
