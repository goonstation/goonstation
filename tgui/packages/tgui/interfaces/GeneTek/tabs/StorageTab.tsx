/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../../backend';
import { BioEffect, GeneList } from '../BioEffect';
import type { GeneTekData } from '../type';

export const StorageTab = () => {
  const { data, act } = useBackend<GeneTekData>();
  const [_menu, setMenu] = useSharedState('menu', 'research');
  const [_isCombining, setIsCombining] = useSharedState('iscombining', false);
  const { saveSlots, samples, savedMutations, savedChromosomes, toSplice } =
    data;

  interface ChromosomeMapped {
    ref: string;
    name: string;
    desc: string;
    count: number;
  }

  const chromosomes: ChromosomeMapped[] = Object.values(
    savedChromosomes.reduce((p, c) => {
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
    }, {}),
  );
  chromosomes.sort((a, b) => (a.name > b.name ? 1 : -1));

  return (
    <>
      {saveSlots > 0 && (
        <Section
          title="Stored Mutations"
          buttons={
            <Button icon="sitemap" onClick={() => setIsCombining(true)}>
              Combine
            </Button>
          }
        >
          {savedMutations.length
            ? savedMutations.map((g) => (
                <BioEffect key={g.ref} gene={g} showSequence isStorage />
              ))
            : 'There are no mutations in storage.'}
        </Section>
      )}
      <Section title="Stored Chromosomes">
        {chromosomes.length ? (
          <LabeledList>
            {chromosomes.map((c) => (
              <LabeledList.Item
                key={c.ref}
                label={c.name}
                buttons={
                  <>
                    <Button
                      disabled={c.name === toSplice}
                      icon="map-marker-alt"
                      onClick={() => act('splicechromosome', { ref: c.ref })}
                    >
                      Splice
                    </Button>
                    <Button
                      color="bad"
                      icon="trash"
                      onClick={() => act('deletechromosome', { ref: c.ref })}
                    />
                  </>
                }
              >
                {c.desc}
                <Box mt={0.5}>
                  <Box inline color="grey">
                    Stored Copies:
                  </Box>
                  {` ${c.count}`}
                </Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : (
          'There are no chromosomes in storage.'
        )}
      </Section>
      <Section title="DNA Samples">
        <LabeledList>
          {samples.map((s) => (
            <LabeledList.Item
              key={s.ref}
              label={s.name}
              buttons={
                <Button
                  icon="save"
                  onClick={() => {
                    act('setrecord', { ref: s.ref });
                    setMenu('record');
                  }}
                >
                  View Record
                </Button>
              }
            >
              <code>{s.uid}</code>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </>
  );
};

export const RecordTab = () => {
  const { data } = useBackend<GeneTekData>();
  const { record } = data;

  if (!record) {
    return;
  }

  const { name, uid, genes } = record;

  return (
    <>
      <Section title={name}>
        <LabeledList>
          <LabeledList.Item label="Genetic Signature">
            <code>{uid}</code>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section>
        <GeneList genes={genes} noGenes="No genes found in sample." isSample />
      </Section>
    </>
  );
};
