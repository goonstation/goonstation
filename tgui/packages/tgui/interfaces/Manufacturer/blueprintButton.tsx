
import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack, Tooltip } from '../../components';
import { Resource } from './type';
import { round } from 'common/math';
import { ButtonWithBadge } from '../../components/goonstation/ButtonWithBadge';
import { CenteredText } from '../../components/goonstation/CenteredText';
import { truncate } from '../../format';

const getBlueprintTime = (time, manufacturerSpeed) => {
  return round(time / 10 / manufacturerSpeed, 0.01);
};

/*
Get whether or not there is a sufficient amount to make. does NOT affect sanity checks on the DM side,
this just offloads some of the computation to the client.

Consequently, if the checks on the .dm end change, this has to change as well.

Thankfully as this is mostly cosmetic, the only implication is that people might be able
to try printing blueprints that get refused, or they may not be allowed to fabricate
blueprints they should be allowed to.
*/
const getProductionSatisfaction = (
  pattern_requirements:string[],
  amount_requirements:number[],
  materials_stored:Resource[]) =>
{
  let satisfaction:boolean[] = [];
  let availableMaterials:Record<string, number> = {};
  for (let i in pattern_requirements) {
    let required_pattern = pattern_requirements[i];
    let compatible_material:Resource;
    // Try to find compatible resource
    for (let resource of materials_stored) {
      if (Object.keys(availableMaterials).find((value:string) => (value === resource.id)) === undefined) {
        availableMaterials[resource.id] = resource.amount;
      }
      if (availableMaterials[resource.id] < amount_requirements[i]/10) {
        continue;
      }
      if (resource.satisfies.find((satisfies_pattern:string) => (
        (required_pattern === "ALL" || required_pattern === satisfies_pattern)
      )) === undefined) {
        continue;
      }
      compatible_material = resource;
      break;
    }
    if (compatible_material === undefined) {
      satisfaction.push(false);
      continue;
    }
    satisfaction.push(true);
    availableMaterials[compatible_material.id] -= amount_requirements[i];
  }
  return satisfaction;
};

export const BlueprintButton = (props, context) => {

  const { blueprintData, materialData, manufacturerSpeed } = props;
  const { act } = useBackend(context);
  const blueprintSatisfaction = getProductionSatisfaction(
    blueprintData.item_paths,
    blueprintData.item_amounts,
    materialData
  );
  const isProduceable = !blueprintSatisfaction.some((satisfied) => !satisfied))
  // Don't include this flavor if we only output one item, because if so, then we know what we're making
  const outputs = (blueprintData.item_outputs.length < 2
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
            labelColor={(blueprintSatisfaction[index]) ? "label" : "red"}
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
    <Stack inline
      width={18.75}
      height={5.5}
      m={0.5}
    >
      <Stack.Item>
        <ButtonWithBadge
          key={blueprintData.name}
          width={16.25}
          height={5.5}
          image_path={blueprintData.img}
          disabled={!isProduceable}
          onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
        >
          <CenteredText text={truncate(blueprintData.name, 40)} height={5.5} />
        </ButtonWithBadge>
      </Stack.Item>
      <Stack.Item ml={0.5}>
        <Stack vertical>
          <Stack.Item>
            <Tooltip
              content={content_info}
            >
              <Button
                align="center"
                width={2}
                height={2.625}
                mb={0.5}
                pt={0.7}
                icon="info"
                disabled={!isProduceable}
                onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
              />
            </Tooltip>
          </Stack.Item>
          <Stack.Item m={0}>
            <Tooltip
              content={content_requirements}
            >
              <Button
                align="center"
                width={2}
                height={2.625}
                pt={0.7}
                icon="gear"
                disabled={!isProduceable}
                onClick={() => act("product", { "blueprint_ref": blueprintData.byondRef })}
              />
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
