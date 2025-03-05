/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

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
import type { PlantmasterData, SeedsViewData } from '../type';

type SeedsViewProps = Pick<SeedsViewData, 'allow_infusion' | 'seeds'> & {
  seedoutput;
  splicing;
  splice_seeds;
  splice_chance;
  sortBy;
  sortAsc;
  page;
  setPage;
};

export const SeedsView = (props: SeedsViewProps) => {
  const { act } = useBackend<PlantmasterData>();
  const {
    allow_infusion,
    seedoutput,
    seeds,
    splicing,
    splice_seeds,
    splice_chance,
    sortBy,
    sortAsc,
    page,
    setPage,
  } = props;
  const extractables = (seeds || []).sort((a, b) =>
    compare(a, b, sortBy, sortAsc),
  );
  const extractablesPerPage = splicing ? 7 : 10;
  const totalPages = Math.max(
    1,
    Math.ceil(extractables.length / extractablesPerPage),
  );
  if (page < 1 || page > totalPages) setPage(clamp(page, 1, totalPages));
  const extractablesOnPage = extractables.slice(
    extractablesPerPage * (page - 1),
    extractablesPerPage * (page - 1) + extractablesPerPage,
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
                format={(value) => 'Page ' + value + '/' + totalPages}
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
                checked={!seedoutput}
                tooltip="Seeds will be extracted into the Plantmaster."
                onClick={() => act('outputmode')}
              >
                Output Internally
              </Button.Checkbox>
            </>
          }
        >
          <Table>
            <TitleRow show_damage sortBy={sortBy} sortAsc={sortAsc} />
            {extractablesOnPage.map((extractable) => (
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
      {splicing && (
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
              <TitleRow show_damage sortBy={sortBy} sortAsc={sortAsc} />
              {splice_seeds
                .filter((x) => x !== null)
                .sort((a, b) => compare(a, b, sortBy, sortAsc))
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
