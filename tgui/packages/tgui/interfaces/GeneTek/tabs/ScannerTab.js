/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../../../backend";
import { Box, Button, ByondUi, Flex, LabeledList, Modal, Section } from "../../../components";
import { AppearanceEditor } from "../AppearanceEditor";
import { GeneList, haveDevice, onCooldown } from "../BioEffect";
import { GeneIcon } from "../GeneIcon";

export const ScannerTab = (props, context) => {
  const { data, act } = useBackend(context);
  let [changingMutantRace, setChangingMutantRace] = useSharedState(context, "changingmutantrace", false);
  const [showPreview, togglePreview] = useSharedState(context, 'togglePreview', false);
  const {
    haveScanner,
    subject,
    modifyAppearance,
    equipmentCooldown,
    mutantRaces,
  } = data;

  const {
    preview,
    name,
    health,
    human,
    age,
    bloodType,
    mutantRace,
    canAppearance,
    premature,
    potential,
    active,
  } = subject || {};

  if (changingMutantRace
    && (!subject || !human || premature)) {
    changingMutantRace = false;
    setChangingMutantRace(false);
  }

  if (!subject) {
    return (
      <Section title="Scanner Error">
        {haveScanner ? "Subject has absconded." : "Check connection to scanner."}
      </Section>
    );
  }

  return (
    <Fragment>
      {!!changingMutantRace && (
        <Modal full>
          <Box bold width={20} mb={0.5}>
            Change to which body type?
          </Box>
          {mutantRaces.map(mr => (
            <Box key={mr.ref}>
              <Button
                color="blue"
                disabled={mutantRace === mr.name}
                mt={0.5}
                onClick={() => {
                  setChangingMutantRace(false);
                  act("mutantrace", { ref: mr.ref });
                }}>
                <GeneIcon
                  name={mr.icon}
                  size={1.5}
                  style={{
                    "margin": "-4px",
                    "margin-right": "4px",
                  }} />
                {mr.name}
              </Button>
            </Box>
          ))}
          <Box mt={1} textAlign="right">
            <Button
              color="bad"
              icon="times"
              onClick={() => setChangingMutantRace(false)}>
              Cancel
            </Button>
          </Box>
        </Modal>
      )}
      {modifyAppearance ? (
        <AppearanceEditor {...modifyAppearance} />
      ) : (
        <Fragment>
          <Section title="Occupant">
            <Flex>
              <Flex.Item mr={1}>
                <LabeledList>
                  <LabeledList.Item
                    label="Name"
                    buttons={haveDevice(equipmentCooldown, "Emitter") && (
                      <Button
                        icon="radiation"
                        disabled={onCooldown(equipmentCooldown, "Emitter") || health <= 0}
                        color="bad"
                        onClick={() => act("emitter")}>
                        Scramble DNA
                      </Button>
                    )}>
                    {name}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Body Type"
                    buttons={!!human && (
                      <Fragment>
                        <Button
                          icon="user"
                          color="blue"
                          disabled={!!premature}
                          onClick={() => setChangingMutantRace(true)}>
                          Change
                        </Button>
                        <Button
                          icon="wrench"
                          color="average"
                          disabled={!canAppearance}
                          onClick={() => act("editappearance")} />
                      </Fragment>
                    )}>
                    {mutantRace}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Physical Age"
                    buttons={!!human && (
                      <Button.Checkbox
                        inline
                        color="good"
                        content="DNA Render"
                        checked={showPreview}
                        onClick={() => togglePreview(!showPreview)}
                      />
                    )}>
                    {age} years
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Type">
                    {bloodType}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
              {human && showPreview && (
                <Flex.Item grow={0} shrink={0}>
                  <ByondUi
                    params={{
                      id: preview,
                      type: "map",
                    }}
                    style={{
                      width: "64px",
                      height: "128px",
                    }}
                    hideOnScroll />
                </Flex.Item>
              )}
            </Flex>
          </Section>
          <Section title="Potential Genes">
            <GeneList
              genes={potential}
              noGenes="All detected potential mutations are active."
              isPotential />
          </Section>
          <Section title="Active Mutations">
            <GeneList
              genes={active}
              noGenes="Subject has no detected mutations."
              isActive />
          </Section>
        </Fragment>
      )}
    </Fragment>
  );
};
