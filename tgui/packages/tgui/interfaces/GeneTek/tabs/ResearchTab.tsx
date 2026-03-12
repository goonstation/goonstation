/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import {
  AnimatedNumber,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { Description } from '../BioEffect';
import { GeneTekData } from '../type';

export const ResearchTab = (props) => {
  const { data, act } = useBackend<GeneTekData>();
  const {
    materialCur,
    materialMax,
    budget,
    mutationsResearched,
    autoDecryptors,
    saveSlots,
    availableResearch,
    finishedResearch,
    savedMutations,
    research,
  } = data;

  const { maxBuyMats, setBuyMats } = props;

  return (
    <>
      <Section
        title="Statistics"
        buttons={
          <Button
            icon="dollar-sign"
            disabled={maxBuyMats <= 0}
            onClick={() => setBuyMats(1)}
          >
            Purchase Additional Materials
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Research Materials">
            {materialCur}
            {' / '}
            {materialMax}
          </LabeledList.Item>
          <LabeledList.Item label="Research Budget">
            <AnimatedNumber value={budget} />
            {' Credits'}
          </LabeledList.Item>
          <LabeledList.Item label="Mutations Researched">
            {mutationsResearched}
          </LabeledList.Item>
          {saveSlots > 0 && (
            <LabeledList.Item label="Mutations Stored">
              {savedMutations.length}
              {' / '}
              {saveSlots}
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Auto-Decryptors">
            {autoDecryptors}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Available Research">
        {availableResearch.map((ar, tier) => (
          <Section key={tier} title={`Tier ${tier + 1}`}>
            {ar.length
              ? ar.map((partialAvailableResearchEntry) => {
                  if (!partialAvailableResearchEntry?.ref) {
                    return null;
                  }
                  const researchEntry =
                    research[partialAvailableResearchEntry.ref];
                  if (!researchEntry) {
                    return null;
                  }
                  return (
                    <Section
                      key={partialAvailableResearchEntry.ref}
                      title={researchEntry.name}
                      buttons={
                        <Button
                          icon="flask"
                          /** unlike with finished researches below, the cost
                           * property is always set for available researches */
                          disabled={
                            materialCur < partialAvailableResearchEntry.cost!
                          }
                          onClick={() =>
                            act('research', {
                              ref: partialAvailableResearchEntry.ref,
                            })
                          }
                          color="teal"
                        >
                          {'Research (' +
                            partialAvailableResearchEntry.cost +
                            ' mat, ' +
                            partialAvailableResearchEntry.time +
                            's)'}
                        </Button>
                      }
                    >
                      <Description text={researchEntry.desc} />
                    </Section>
                  );
                })
              : 'No research is currently available at this tier.'}
          </Section>
        ))}
      </Section>
      <Section title="Finished Research">
        {finishedResearch.map((fr, tier) => (
          <Section key={tier} title={`Tier ${tier + 1}`}>
            {fr.length
              ? fr.map((partialFinishedResearchEntry) => {
                  const researchEntry =
                    research[partialFinishedResearchEntry.ref];
                  if (!researchEntry) {
                    return null;
                  }
                  return (
                    <Section
                      key={researchEntry.name}
                      title={researchEntry.name}
                    >
                      <Description text={researchEntry.desc} />
                    </Section>
                  );
                })
              : 'No research has been completed at this tier.'}
          </Section>
        ))}
      </Section>
    </>
  );
};
