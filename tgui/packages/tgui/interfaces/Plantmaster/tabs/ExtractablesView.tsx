/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useMemo } from 'react';
import { Button, NumberInput, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { usePagination } from '../../common/hooks';
import { compare, Row, TitleRow } from '../PlantmasterTable';
import type { ExtractablesViewData } from '../type';

export const ExtractablesView = () => {
  const { act, data } = useBackend<ExtractablesViewData>();
  const { allow_infusion, extractables, output_externally, sortAsc, sortBy } =
    data;
  const sortedExtractables = useMemo(
    () =>
      [...(extractables ?? [])].sort((a, b) =>
        compare(a, b, sortBy, !!sortAsc),
      ),
    [compare, extractables, sortAsc, sortBy],
  );
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
      <Table>
        <TitleRow sortBy={sortBy} sortAsc={!!sortAsc} />
        {items.map((extractable) => (
          <Row
            allow_infusion={allow_infusion}
            extractable={extractable}
            key={extractable.ref[1]}
            extract
          />
        ))}
      </Table>
    </Section>
  );
};
