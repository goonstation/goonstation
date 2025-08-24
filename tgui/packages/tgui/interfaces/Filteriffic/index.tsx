/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { map } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { FilterEntry } from './FilterEntry';
import type { FilterifficData } from './type';

export const Filteriffic = () => {
  const { act, data } = useBackend<FilterifficData>();
  const name = data.target_name || 'Unknown Object';
  const filters = data.target_filter_data || {};
  const hasFilters = Object.keys(filters).length !== 0;
  const filterDefaults = data['filter_info'];
  const [massApplyPath, setMassApplyPath] = useState('');
  const [hiddenSecret, setHiddenSecret] = useState(false);
  return (
    <Window width={500} height={500} title="Filteriffic">
      <Window.Content scrollable>
        <NoticeBox danger>
          DO NOT MESS WITH EXISTING FILTERS IF YOU DO NOT KNOW THE CONSEQUENCES.
          YOU HAVE BEEN WARNED.
        </NoticeBox>
        <Section
          title={
            hiddenSecret ? (
              <>
                <Box mr={0.5} inline>
                  MASS EDIT:
                </Box>
                <Input
                  value={massApplyPath}
                  width="100px"
                  onInput={(e, value) => setMassApplyPath(value)}
                />
                <Button.Confirm
                  confirmContent="ARE YOU SURE?"
                  onClick={() => act('mass_apply', { path: massApplyPath })}
                >
                  Apply
                </Button.Confirm>
              </>
            ) : (
              <Box inline onDoubleClick={() => setHiddenSecret(true)}>
                {name}
              </Box>
            )
          }
          buttons={
            <Dropdown
              icon="plus"
              displayText="Add Filter"
              noChevron
              options={Object.keys(filterDefaults)}
              selected={null}
              onSelected={(value) =>
                act('add_filter', {
                  name: 'default',
                  priority: 10,
                  type: value,
                })
              }
            />
          }
        >
          {!hasFilters ? (
            <Box>No filters</Box>
          ) : (
            map(filters, (entry, key) => (
              <FilterEntry filterDataEntry={entry} name={key} key={key} />
            ))
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
