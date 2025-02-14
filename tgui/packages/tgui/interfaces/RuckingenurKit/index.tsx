/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license MIT
 */

import { useState } from 'react';
import { Input, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ScannedItem } from './ScannedItem';
import { ScannedItemLegacyElectronicFrameMode } from './ScannedItemLegacyElectronicFrameMode';
import { RuckingenurKitData } from './type';

export const RuckingenurKit = () => {
  const { data } = useBackend<RuckingenurKitData>();
  const { scanned_items, hide_allowed, legacyElectronicFrameMode } = data;

  const [filter, setFilter] = useState('');
  const filterExp = new RegExp(filter, 'i');

  return (
    <Window width={925} height={420}>
      <Window.Content>
        <Section
          title="Scanned Items"
          scrollable
          fill
          buttons={
            <label>
              Filter items:{' '}
              <Input value={filter} onInput={(_e, value) => setFilter(value)} />
            </label>
          }
        >
          {scanned_items
            .filter(
              (scanned_item) => !filter || scanned_item.name.match(filterExp),
            )
            .map((scanned_item) =>
              !legacyElectronicFrameMode ? (
                <ScannedItem
                  ScannedItem={scanned_item}
                  key={scanned_item.ref}
                  hide_allowed={hide_allowed}
                />
              ) : (
                <ScannedItemLegacyElectronicFrameMode
                  ScannedItem={scanned_item}
                  key={scanned_item.ref}
                  hide_allowed={hide_allowed}
                />
              ),
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};
