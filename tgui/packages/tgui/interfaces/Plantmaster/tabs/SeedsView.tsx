/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useEffect, useMemo, useState } from 'react';
import {
  Button,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import { compare, Row, TitleRow } from '../PlantmasterTable';
import type { SeedsViewData } from '../type';

export const SeedsView = () => {
  const { act, data } = useBackend<SeedsViewData>();
  const {
    allow_infusion,
    output_externally,
    seeds,
    show_splicing,
    sortAsc,
    sortBy,
    splice_seeds,
    splice_chance,
  } = data;
  const [page, setPage] = useState(1);
  const sortedSeeds = useMemo(
    () => [...(seeds ?? [])].sort((a, b) => compare(a, b, sortBy, !!sortAsc)),
    [compare, seeds, sortAsc, sortBy],
  );
  const seedsPerPage = show_splicing ? 7 : 10;
  const totalPages = Math.max(1, Math.ceil(sortedSeeds.length / seedsPerPage));
  useEffect(() => {
    if (page < 1 || page > totalPages) {
      setPage(clamp(page, 1, totalPages));
    }
  }, [clamp, page, setPage, totalPages]);
  const seedsOnPage = useMemo(
    () =>
      sortedSeeds.slice(
        seedsPerPage * (page - 1),
        seedsPerPage * (page - 1) + seedsPerPage,
      ),
    [page, seedsPerPage, sortedSeeds],
  );
  const splice_disable = splice_seeds[0] !== null && splice_seeds[1] !== null;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          title="Seeds"
          fill
          scrollable
          scrollableHorizontal
          buttons={
            <>
              <Button
                icon="eject"
                tooltip="All seeds will be ejected from the Plantmaster"
                onClick={() => act('ejectseeds')}
              >
                Eject All
              </Button>
              <Button
                icon="caret-left"
                tooltip="Previous Page"
                disabled={page < 2}
                onClick={() => setPage(page - 1)}
              />
              <NumberInput
                value={page}
                format={(value) => `Page ${value}/${totalPages}`}
                minValue={1}
                maxValue={totalPages}
                step={1}
                stepPixelSize={15}
                onChange={(value) => setPage(value)}
              />
              <Button
                icon="caret-right"
                tooltip="Next Page"
                disabled={page > totalPages - 1}
                onClick={() => setPage(page + 1)}
              />
              <Button.Checkbox
                checked={!output_externally}
                tooltip="Seeds will be extracted into the Plantmaster."
                onClick={() => act('toggle-output-mode')}
              >
                Output Internally
              </Button.Checkbox>
            </>
          }
        >
          <Table>
            <TitleRow showDamage sortBy={sortBy} sortAsc={!!sortAsc} />
            {seedsOnPage.map((extractable) => (
              <Row
                allow_infusion={allow_infusion}
                extractable={extractable}
                key={extractable.ref[1]}
                show_damage
                infuse
                splice
                splice_disable={splice_disable}
              />
            ))}
          </Table>
        </Section>
      </Stack.Item>
      {show_splicing && (
        <Stack.Item>
          <Section
            title="Splicing"
            scrollable
            scrollableHorizontal
            buttons={
              <>
                {`Splice Chance: ${splice_chance}%`}
                <Button ml={1} onClick={() => act('splice')}>
                  Splice
                </Button>
              </>
            }
          >
            <Table>
              <TitleRow showDamage sortBy={sortBy} sortAsc={!!sortAsc} />
              {splice_seeds
                .filter((x) => x !== null)
                .sort((a, b) => compare(a, b, sortBy, !!sortAsc))
                .map((extractable) => (
                  <Row
                    allow_infusion={allow_infusion}
                    extractable={extractable}
                    key={extractable.ref[1]}
                    show_damage
                    infuse
                    splice
                  />
                ))}
            </Table>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
