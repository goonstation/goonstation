/**
 * @file
 * @copyright 2022
 * @author Original Amylizzle (https://github.com/amylizzle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useState } from 'react';
import { Button, NumberInput, Section, Table } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../../backend';
import { compare, Row, TitleRow } from '../PlantmasterTable';
import type { ExtractablesViewData } from '../type';

export const ExtractablesView = () => {
  const { act, data } = useBackend<ExtractablesViewData>();
  const { allow_infusion, output_externally, extractables, sortBy, sortAsc } =
    data;
  const [page, setPage] = useState(1);
  const sortedExtractables = (extractables || []).sort((a, b) =>
    compare(a, b, sortBy, !!sortAsc),
  );
  const extractablesPerPage = 10;
  const totalPages = Math.max(
    1,
    Math.ceil(sortedExtractables.length / extractablesPerPage),
  );
  if (page < 1 || page > totalPages) {
    setPage(clamp(page, 1, totalPages));
  }
  const extractablesOnPage = sortedExtractables.slice(
    extractablesPerPage * (page - 1),
    extractablesPerPage * (page - 1) + extractablesPerPage,
  );

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
        {extractablesOnPage.map((extractable) => (
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
