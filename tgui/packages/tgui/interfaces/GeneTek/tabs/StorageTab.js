/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../../../backend";
import { BioEffect, GeneList } from "../BioEffect";
import { Box, Button, LabeledList, Section } from "../../../components";

export const StorageTab = (props, context) => {
  const { data, act } = useBackend(context);
  const [menu, setMenu] = useSharedState(context, "menu", "research");
  const [isCombining, setIsCombining] = useSharedState(context, "iscombining", false);
  const {
    saveSlots,
    samples,
    savedMutations,
    savedChromosomes,
    toSplice,
  } = data;

  const chromosomes = Object.values(savedChromosomes.reduce((p, c) => {
    if (!p[c.name]) {
      p[c.name] = {
        name: c.name,
        desc: c.desc,
        count: 0,
      };
    }

    p[c.name].count++;
    p[c.name].ref = c.ref;

    return p;
  }, {}));
  chromosomes.sort((a, b) => a.name > b.name ? 1 : -1);

  return (
    <Fragment>
      {saveSlots > 0 && (
        <Section
          title="Stored Mutations"
          buttons={
            <Button
              icon="sitemap"
              onClick={() => setIsCombining(true)}>
              Combine
            </Button>
          }>
          {savedMutations.length ? savedMutations.map(g => (
            <BioEffect
              key={g.ref}
              gene={g}
              showSequence
              isStorage />
          )) : "There are no mutations in storage."}
        </Section>
      )}
      <Section title="Stored Chromosomes">
        {chromosomes.length ? (
          <LabeledList>
            {chromosomes.map(c => (
              <LabeledList.Item
                key={c.ref}
                label={c.name}
                buttons={
                  <Fragment>
                    <Button
                      disabled={c.name === toSplice}
                      icon="map-marker-alt"
                      onClick={() => act("splicechromosome", { ref: c.ref })}>
                      Splice
                    </Button>
                    <Button
                      color="bad"
                      icon="trash"
                      onClick={() => act("deletechromosome", { ref: c.ref })} />
                  </Fragment>
                }>
                {c.desc}
                <Box mt={0.5}>
                  <Box inline color="grey">Stored Copies:</Box> {c.count}
                </Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : "There are no chromosomes in storage."}
      </Section>
      <Section title="DNA Samples">
        <LabeledList>
          {samples.map(s => (
            <LabeledList.Item
              key={s.ref}
              label={s.name}
              buttons={
                <Button
                  icon="save"
                  onClick={() => {
                    act("setrecord", { ref: s.ref });
                    setMenu("record");
                  }}>
                  View Record
                </Button>
              }>
              <tt>{s.uid}</tt>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Fragment>
  );
};

export const RecordTab = (props, context) => {
  const { data } = useBackend(context);
  const {
    record,
  } = data;

  if (!record) {
    return;
  }

  const {
    name,
    uid,
    genes,
  } = record;

  return (
    <Fragment>
      <Section title={name}>
        <LabeledList>
          <LabeledList.Item label="Genetic Signature">
            <tt>{uid}</tt>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section>
        <GeneList
          genes={genes}
          noGenes="No genes found in sample."
          isSample />
      </Section>
    </Fragment>
  );
};
