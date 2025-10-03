/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { memo, useMemo } from 'react';
import { Button, NumberInput, Section, Stack } from 'tgui-core/components';
import { shallowDiffers } from 'tgui-core/react';

import { useBackend } from '../../../backend';
import { truncate } from '../../../format';
import { usePagination } from '../../common/hooks';
import { PlantmasterTable } from '../PlantmasterTable';
import type { SeedData, SeedsViewData, Sort, SortProps } from '../type';
import { createSortPropsBuilder, getSortFromData, isNonNull } from '../util';

export const SeedsView = () => {
  const { data } = useBackend<SeedsViewData>();
  return <MemoizedSeedsView {...data} />;
};

type MemoizedSeedsViewProps = SeedsViewData;

const MemoizedSeedsView = memo(
  (props: MemoizedSeedsViewProps) => {
    const { act } = useBackend();
    const {
      allow_infusion,
      output_externally,
      seeds,
      sortAsc,
      sortBy,
      splice_chance,
      splice_seeds,
    } = props;
    const sort = useMemo(
      () => getSortFromData(sortBy, sortAsc),
      [sortAsc, sortBy],
    );
    const buildSortProps = createSortPropsBuilder(act, sort);
    const sortedSeeds = useMemo(() => {
      const sorted = [...seeds];
      if (sort) {
        sorted.sort((a, b) => compareSeeds(a, b, sort));
      }
      return sorted;
    }, [seeds, sort]);
    const filteredSplicedSeeds = (splice_seeds ?? []).filter(isNonNull);
    const sortedSplicedSeeds = useMemo(() => {
      const sorted = [...filteredSplicedSeeds];
      if (sort) {
        sorted.sort((a, b) => compareSeeds(a, b, sort));
      }
      return sorted;
    }, [splice_seeds, sort]);
    const {
      canDecrementPage,
      canIncrementPage,
      changePage,
      decrementPage,
      incrementPage,
      items,
      numPages,
      page,
    } = usePagination(sortedSeeds, {
      pageSize: 10,
    });
    const spliceBayFull = filteredSplicedSeeds.length >= 2;
    const showSpliceBay = filteredSplicedSeeds.length > 0;
    return (
      <Stack vertical fill>
        <Stack.Item grow>
          <Section
            fill
            title="Seeds"
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
                  disabled={!canDecrementPage}
                  onClick={decrementPage}
                />
                <NumberInput
                  value={page + 1}
                  format={(value) => `Page ${value}/${numPages}`}
                  minValue={1}
                  maxValue={numPages}
                  step={1}
                  stepPixelSize={15}
                  onChange={(pageOneIndexed) => changePage(pageOneIndexed - 1)}
                />
                <Button
                  icon="caret-right"
                  tooltip="Next Page"
                  disabled={!canIncrementPage}
                  onClick={incrementPage}
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
            <SeedsTable
              allow_infusion={allow_infusion}
              buildSortProps={buildSortProps}
              items={items}
              spliceBayFull={spliceBayFull}
              showSplice
            />
          </Section>
        </Stack.Item>
        {showSpliceBay && (
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
              <SeedsTable
                allow_infusion={allow_infusion}
                items={sortedSplicedSeeds}
                buildSortProps={buildSortProps}
              />
            </Section>
          </Stack.Item>
        )}
      </Stack>
    );
  },
  (prevProps, nextProps) => {
    const {
      seeds: prevSeeds,
      splice_seeds: prevSpliceSeeds,
      ...prevRest
    } = prevProps;
    const {
      seeds: nextSeeds,
      splice_seeds: nextSpliceSeeds,
      ...nextRest
    } = nextProps;
    return (
      !shallowDiffers(prevRest, nextRest) &&
      (prevSpliceSeeds ?? []).length === (nextSpliceSeeds ?? []).length &&
      JSON.stringify(prevSpliceSeeds) === JSON.stringify(nextSpliceSeeds) &&
      (prevSeeds ?? []).length === (nextSeeds ?? []).length &&
      JSON.stringify(prevSeeds) === JSON.stringify(nextSeeds)
    );
  },
);

type SeedsTableProps = Pick<SeedsViewData, 'allow_infusion'> & {
  buildSortProps: (field: string) => SortProps;
  items: SeedData[];
  showSplice?: boolean;
  spliceBayFull?: boolean;
};

const SeedsTable = (props: SeedsTableProps) => {
  const { allow_infusion, buildSortProps, items, showSplice, spliceBayFull } =
    props;
  const { act } = useBackend();
  return (
    <PlantmasterTable>
      <PlantmasterTable.HeadingRow>
        <PlantmasterTable.HeadingCell {...buildSortProps('name')}>
          Name
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps('species')}>
          Species
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps('damage')}>
          Damage
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps('charges')}>
          Count
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('genome')}>
          Genome
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('generation')}>
          Generation
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('growtime')}>
          Maturity Rate
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('harvesttime')}>
          Production Rate
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('lifespan')}>
          Lifespan
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('yield')}>
          Yield
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('potency')}>
          Potency
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell {...buildSortProps?.('endurance')}>
          Endurance
        </PlantmasterTable.HeadingCell>
        <PlantmasterTable.HeadingCell>Actions</PlantmasterTable.HeadingCell>
      </PlantmasterTable.HeadingRow>
      {items.map((item) => (
        <PlantmasterTable.Row key={item.item_ref}>
          <PlantmasterTable.Cell>
            <Button.Input
              width="100px"
              tooltip="Click to rename"
              color="transparent"
              textColor="#FFFFFF"
              value={item.name}
              onCommit={(new_name) =>
                act('label', {
                  label_ref: item.item_ref,
                  label_new: new_name,
                })
              }
              buttonText={truncate(item.name, 10)}
            />
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.species[1]}>
            {item.species[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell>{item.damage}</PlantmasterTable.Cell>
          <PlantmasterTable.Cell>{item.charges}</PlantmasterTable.Cell>
          <PlantmasterTable.Cell>{item.genome}</PlantmasterTable.Cell>
          <PlantmasterTable.Cell>{item.generation}</PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.growtime[1]}>
            {item.growtime[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.harvesttime[1]}>
            {item.harvesttime[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.lifespan[1]}>
            {item.lifespan[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.cropsize[1]}>
            {item.cropsize[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.potency[1]}>
            {item.potency[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell dominant={!!item.endurance[1]}>
            {item.endurance[0]}
          </PlantmasterTable.Cell>
          <PlantmasterTable.Cell>
            <Button
              icon="fill-drip"
              tooltip="Infuse"
              disabled={!allow_infusion}
              onClick={() => act('infuse', { infuse_ref: item.item_ref })}
            />
            {showSplice ? (
              <Button
                disabled={spliceBayFull}
                icon="code-branch"
                tooltip="Splice"
                onClick={() =>
                  act('splice_select', {
                    splice_select_ref: item.item_ref,
                  })
                }
              />
            ) : (
              <Button
                icon="window-close"
                color="red"
                tooltip="Cancel Splice"
                onClick={() =>
                  act('splice_select', {
                    splice_select_ref: item.item_ref,
                  })
                }
              />
            )}
            <Button
              icon="search"
              tooltip="Analyze"
              onClick={() => act('analyze', { analyze_ref: item.item_ref })}
            />
            <Button
              icon="eject"
              tooltip="Eject"
              onClick={() => act('eject', { eject_ref: item.item_ref })}
            />
          </PlantmasterTable.Cell>
        </PlantmasterTable.Row>
      ))}
    </PlantmasterTable>
  );
};

function compareSeeds(a: SeedData, b: SeedData, sort: Sort): number {
  let order = 0;
  switch (sort.sortBy) {
    // flat string
    case 'name': {
      order = a[sort.sortBy].localeCompare(b[sort.sortBy]);
      break;
    }
    // dominant string
    case 'species': {
      order = a[sort.sortBy][0].localeCompare(b[sort.sortBy][0]);
      break;
    }
    // flat number
    case 'charges':
    case 'damage':
    case 'genome':
    case 'generation': {
      order = Math.sign(a[sort.sortBy] - b[sort.sortBy]);
      break;
    }
    // dominant number
    case 'growtime':
    case 'harvesttime':
    case 'lifespan':
    case 'cropsize':
    case 'potency':
    case 'endurance': {
      order = Math.sign(a[sort.sortBy][0] - b[sort.sortBy][0]);
      break;
    }
  }
  return sort.sortAsc ? order : -order;
}
