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
  const {
    haveScanner,
    haveSubject,
    subjectPreview,
    subjectName,
    subjectHealth,
    subjectHuman,
    subjectAge,
    subjectBloodType,
    subjectMutantRace,
    subjectCanAppearance,
    subjectPremature,
    subjectPotential,
    subjectActive,
    modifyAppearance,
    equipmentCooldown,
    mutantRaces,
  } = data;

  if (changingMutantRace
    && (!haveSubject || !subjectHuman || subjectPremature)) {
    changingMutantRace = false;
    setChangingMutantRace(false);
  }

  if (!haveSubject) {
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
                disabled={subjectMutantRace === mr.name}
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
                        disabled={onCooldown(equipmentCooldown, "Emitter") || subjectHealth <= 0}
                        color="bad"
                        onClick={() => act("emitter")}>
                        Scramble DNA
                      </Button>
                    )}>
                    {subjectName}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Body Type"
                    buttons={!!subjectHuman && (
                      <Fragment>
                        <Button
                          icon="user"
                          color="blue"
                          disabled={!!subjectPremature}
                          onClick={() => setChangingMutantRace(true)}>
                          Change
                        </Button>
                        <Button
                          icon="wrench"
                          color="average"
                          disabled={!subjectCanAppearance}
                          onClick={() => act("editappearance")} />
                      </Fragment>
                    )}>
                    {subjectMutantRace}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Physical Age">
                    {subjectAge} years
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Type">
                    {subjectBloodType}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
              {!!subjectHuman && (
                <Flex.Item grow={0} shrink={0}>
                  <ByondUi
                    params={{
                      id: subjectPreview,
                      type: "map",
                    }}
                    style={{
                      width: "80px",
                      height: "80px",
                    }}
                    hideOnScroll />
                </Flex.Item>
              )}
            </Flex>
          </Section>
          <Section title="Potential Genes">
            <GeneList
              genes={subjectPotential}
              noGenes="All detected potential mutations are active."
              isPotential />
          </Section>
          <Section title="Active Mutations">
            <GeneList
              genes={subjectActive}
              noGenes="Subject has no detected mutations."
              isActive />
          </Section>
        </Fragment>
      )}
    </Fragment>
  );
};
