/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Fragment } from "inferno";
import { useBackend } from "../../../backend";
import { AnimatedNumber, Button, LabeledList, Section } from "../../../components";
import { Description } from "../BioEffect";

export const ResearchTab = (props, context) => {
  const { data, act } = useBackend(context);
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

  const {
    maxBuyMats,
    setBuyMats,
  } = props;

  return (
    <Fragment>
      <Section
        title="Statistics"
        buttons={(
          <Button
            icon="dollar-sign"
            disabled={maxBuyMats <= 0}
            onClick={() => setBuyMats(1)}>
            Purchase Additional Materials
          </Button>
        )}>
        <LabeledList>
          <LabeledList.Item label="Research Materials">
            {materialCur}{" / "}{materialMax}
          </LabeledList.Item>
          <LabeledList.Item label="Research Budget">
            <AnimatedNumber value={budget} />
            {" Credits"}
          </LabeledList.Item>
          <LabeledList.Item label="Mutations Researched">
            {mutationsResearched}
          </LabeledList.Item>
          {saveSlots > 0 && (
            <LabeledList.Item label="Mutations Stored">
              {savedMutations.length}{" / "}{saveSlots}
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Auto-Decryptors">
            {autoDecryptors}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Available Research">
        {availableResearch.map((ar, tier) => (
          <Section
            key={tier}
            title={"Tier " + (tier + 1)}>
            {ar.length ? ar.map(r => (
              <Section
                key={r.ref}
                title={research[r.ref].name}
                buttons={
                  <Button
                    icon="flask"
                    disabled={materialCur < r.cost}
                    onClick={() => act("research", { ref: r.ref })}
                    color="teal">
                    {"Research (" + r.cost + " mat, " + r.time + "s)"}
                  </Button>
                }>
                <Description text={research[r.ref].desc} />
              </Section>
            )) : "No research is currently available at this tier."}
          </Section>
        ))}
      </Section>
      <Section title="Finished Research">
        {finishedResearch.map((fr, tier) => (
          <Section
            key={tier}
            title={"Tier " + (tier + 1)}>
            {fr.length ? fr.map(r => (
              <Section
                key={research[r.ref].name}
                title={research[r.ref].name}>
                <Description text={research[r.ref].desc} />
              </Section>
            )) : "No research has been completed at this tier."}
          </Section>
        ))}
      </Section>
    </Fragment>
  );
};
