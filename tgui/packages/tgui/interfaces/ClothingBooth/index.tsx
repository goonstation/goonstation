/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback, useMemo, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { useConstant } from '../common/hooks';
import { CharacterPreview } from './CharacterPreview';
import { PurchaseInfo } from './PurchaseInfo';
import { StockList } from './StockList';
import { TagsModal } from './TagsModal';
import type { ClothingBoothData, TagFilterLookup } from './type';

export const ClothingBooth = () => {
  const { act, data } = useBackend<ClothingBoothData>();
  const {
    accountBalance,
    cash,
    catalogue,
    everythingIsFree,
    name,
    scannedID,
    selectedGroupingName,
    selectedItemName,
    tags,
  } = data;
  const [showTagsModal, setShowTagsModal] = useState(false);
  const [appliedTagFilters, setAppliedTagFilters] = useState<TagFilterLookup>(
    {},
  );
  const handleOpenTagsModal = useCallback(() => setShowTagsModal(true), []);
  const handleApplyAndCloseTagFilters = useCallback(
    (tagFilters: TagFilterLookup) => {
      setAppliedTagFilters(tagFilters);
      setShowTagsModal(false);
    },
    [],
  );
  const handleCloseTagFilters = useCallback(() => setShowTagsModal(false), []);
  // N.B. memoizedCatalogue does not update in subsequent renders; if this feature becomes required do a smarter memo
  const memoizedCatalogue = useConstant(() => catalogue);
  const selectedGrouping = useMemo(
    () =>
      selectedGroupingName
        ? memoizedCatalogue[selectedGroupingName]
        : undefined,
    [memoizedCatalogue, selectedGroupingName],
  );
  return (
    <Window title={name} width={500} height={600}>
      <Window.Content>
        <Stack fill vertical>
          {!!(!data.everythingIsFree && (scannedID || cash)) && (
            <Stack.Item>
              <Section fill>
                <Stack fill vertical>
                  {!!cash && (
                    <Stack.Item>
                      <Stack align="center" justify="space-between">
                        <Stack.Item bold>Cash: {cash}⪽</Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="eject"
                            onClick={() => act('eject_cash')}
                          >
                            Eject Cash
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  )}
                  {!!scannedID && (
                    <Stack.Item>
                      <Stack align="center" justify="space-between">
                        <Stack.Item bold>
                          Money In Account: {accountBalance}⪽
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            ellipsis
                            icon="id-card"
                            onClick={() => {
                              act('logout');
                            }}
                          >
                            {scannedID}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow={1}>
            <StockList
              accountBalance={accountBalance}
              cash={cash}
              catalogue={memoizedCatalogue}
              everythingIsFree={everythingIsFree}
              onOpenTagsModal={handleOpenTagsModal}
              selectedGroupingName={selectedGroupingName}
              tagFilters={appliedTagFilters}
            />
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item align="center">
                <Section fill>
                  <CharacterPreview />
                </Section>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fill>
                  <Stack fill vertical justify="space-around">
                    <Stack.Item>
                      <PurchaseInfo
                        accountBalance={accountBalance}
                        cash={cash}
                        everythingIsFree={everythingIsFree}
                        selectedGrouping={selectedGrouping}
                        selectedItemName={selectedItemName}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
        {showTagsModal && (
          <TagsModal
            initialTagFilters={appliedTagFilters}
            onApplyAndClose={handleApplyAndCloseTagFilters}
            onClose={handleCloseTagFilters}
            tags={tags}
          />
        )}
      </Window.Content>
    </Window>
  );
};
