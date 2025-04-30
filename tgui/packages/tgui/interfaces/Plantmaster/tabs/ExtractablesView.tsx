/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { memo, useMemo } from 'react';
import { Button, NumberInput, Section } from 'tgui-core/components';
import { shallowDiffers } from 'tgui-core/react';

import { useBackend } from '../../../backend';
import { truncate } from '../../../format';
import { usePagination } from '../../common/hooks';
import { PlantmasterTable } from '../PlantmasterTable';
import type { ExtractableData, ExtractablesViewData, Sort } from '../type';
import { createSortPropsBuilder, getSortFromData } from '../util';

export const ExtractablesView = () => {
  const { data } = useBackend<ExtractablesViewData>();
  return <MemoizedExtractablesView {...data} />;
};

type MemoizedExtractablesViewProps = ExtractablesViewData;

const MemoizedExtractablesView = memo(
  (props: MemoizedExtractablesViewProps) => {
    const { act } = useBackend();
    const { extractables, output_externally, sortAsc, sortBy } = props;
    const sort = useMemo(
      () => getSortFromData(sortBy, sortAsc),
      [sortAsc, sortBy],
    );
    const buildSortProps = createSortPropsBuilder(act, sort);
    const sortedExtractables = useMemo(() => {
      const sorted = [...extractables];
      if (sort) {
        sorted.sort((a, b) => compareExtractables(a, b, sort));
      }
      return sorted;
    }, [extractables, sort]);
    const {
      canDecrementPage,
      canIncrementPage,
      changePage,
      decrementPage,
      incrementPage,
      items,
      numPages,
      page,
    } = usePagination(sortedExtractables, {
      pageSize: 10,
    });
    return (
      <Section
        title="Extractable Items"
        scrollable
        scrollableHorizontal
        buttons={
          <>
            <Button
              icon="eject"
              tooltip="All produce will be ejected from the Plantmaster"
              onClick={() => act('ejectextractables')}
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
        <PlantmasterTable>
          <PlantmasterTable.HeadingRow>
            <PlantmasterTable.HeadingCell {...buildSortProps('name')}>
              Name
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('species')}>
              Species
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('genome')}>
              Genome
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('generation')}>
              Generation
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('growtime')}>
              Maturity Rate
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('harvesttime')}>
              Production Rate
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('lifespan')}>
              Lifespan
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('yield')}>
              Yield
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('potency')}>
              Potency
            </PlantmasterTable.HeadingCell>
            <PlantmasterTable.HeadingCell {...buildSortProps('endurance')}>
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
                  defaultValue={item.name}
                  currentValue={item.name}
                  onCommit={(new_name) =>
                    act('label', {
                      label_ref: item.item_ref,
                      label_new: new_name,
                    })
                  }
                >
                  {truncate(item.name, 10)}
                </Button.Input>
              </PlantmasterTable.Cell>
              <PlantmasterTable.Cell dominant={!!item.species[1]}>
                {item.species[0]}
              </PlantmasterTable.Cell>
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
                  icon="seedling"
                  tooltip="Extract Seeds"
                  onClick={() => act('extract', { extract_ref: item.item_ref })}
                />
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
      </Section>
    );
  },
  (prevProps, nextProps) => {
    const { extractables: prevExtractables, ...prevRest } = prevProps;
    const { extractables: nextExtractables, ...nextRest } = nextProps;
    return (
      !shallowDiffers(prevRest, nextRest) &&
      (prevExtractables ?? []).length === (nextExtractables ?? []).length &&
      JSON.stringify(prevExtractables) === JSON.stringify(nextExtractables)
    );
  },
);

function compareExtractables(
  a: ExtractableData,
  b: ExtractableData,
  sort: Sort,
): number {
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
