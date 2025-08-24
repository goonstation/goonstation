/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import {
  Box,
  Button,
  ByondUi,
  Flex,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../../backend';
import { Modal } from '../../../components';
import { AppearanceEditor } from '../AppearanceEditor';
import { GeneList, haveDevice, onCooldown } from '../BioEffect';
import { GeneIcon } from '../GeneIcon';
import { GeneTekData } from '../type';

export const ScannerTab = () => {
  const { data, act } = useBackend<GeneTekData>();
  let [changingMutantRace, setChangingMutantRace] = useSharedState(
    'changingmutantrace',
    false,
  );
  const [showPreview, togglePreview] = useSharedState('togglePreview', false);
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

  if (changingMutantRace && (!subject || !human || premature)) {
    changingMutantRace = false;
    setChangingMutantRace(false);
  }

  if (!subject) {
    return (
      <Section title="Scanner Error">
        {haveScanner
          ? 'Subject has absconded.'
          : 'Check connection to scanner.'}
      </Section>
    );
  }

  return (
    <>
      {!!changingMutantRace && (
        <Modal full>
          <Box bold width={20} mb={0.5}>
            Change to which body type?
          </Box>
          {mutantRaces.map((mr) => (
            <Box key={mr.ref}>
              <Button
                color="blue"
                disabled={mutantRace === mr.name}
                mt={0.5}
                onClick={() => {
                  setChangingMutantRace(false);
                  act('mutantrace', { ref: mr.ref });
                }}
              >
                <GeneIcon
                  name={mr.icon}
                  size={1.5}
                  style={{
                    margin: '-4px',
                    'margin-right': '4px',
                  }}
                />
                {mr.name}
              </Button>
            </Box>
          ))}
          <Box mt={1} textAlign="right">
            <Button
              color="bad"
              icon="times"
              onClick={() => setChangingMutantRace(false)}
            >
              Cancel
            </Button>
          </Box>
        </Modal>
      )}
      {modifyAppearance ? (
        <AppearanceEditor {...modifyAppearance} />
      ) : (
        <>
          <Section title="Occupant">
            <Flex>
              <Flex.Item mr={1}>
                <LabeledList>
                  <LabeledList.Item
                    label="Name"
                    buttons={
                      haveDevice(equipmentCooldown, 'Emitter') && (
                        <Button
                          icon="radiation"
                          disabled={
                            onCooldown(equipmentCooldown, 'Emitter') ||
                            !health ||
                            health <= 0
                          }
                          color="bad"
                          onClick={() => act('emitter')}
                        >
                          Scramble DNA
                        </Button>
                      )
                    }
                  >
                    {name}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Body Type"
                    buttons={
                      !!human && (
                        <>
                          <Button
                            icon="user"
                            color="blue"
                            disabled={!!premature}
                            onClick={() => setChangingMutantRace(true)}
                          >
                            Change
                          </Button>
                          <Button
                            icon="wrench"
                            color="average"
                            disabled={!canAppearance}
                            onClick={() => act('editappearance')}
                          />
                        </>
                      )
                    }
                  >
                    {mutantRace}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Physical Age"
                    buttons={
                      !!human && (
                        <Button.Checkbox
                          inline
                          color="good"
                          checked={showPreview}
                          onClick={() => togglePreview(!showPreview)}
                        >
                          DNA Render
                        </Button.Checkbox>
                      )
                    }
                  >
                    {age} years
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Type">
                    {bloodType}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
              {human && showPreview && (
                <Flex.Item shrink={0}>
                  <ByondUi
                    params={{
                      id: preview,
                      type: 'map',
                    }}
                    style={{
                      width: '64px',
                      height: '128px',
                    }}
                    hideOnScroll
                  />
                </Flex.Item>
              )}
            </Flex>
          </Section>
          <Section title="Potential Genes">
            <GeneList
              genes={potential}
              noGenes="All detected potential mutations are active."
              isPotential
            />
          </Section>
          <Section title="Active Mutations">
            <GeneList
              genes={active}
              noGenes="Subject has no detected mutations."
              isActive
            />
          </Section>
        </>
      )}
    </>
  );
};
