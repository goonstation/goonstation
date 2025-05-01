/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import {
  Button,
  Collapsible,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { FilterDataEntry } from './FilterDataEntry';
import type { FilterifficData } from './type';

export const FilterEntry = (props) => {
  const { act, data } = useBackend<FilterifficData>();
  const { name, filterDataEntry } = props;
  const { type, priority, ...restOfProps } = filterDataEntry;

  const filterDefaults = data['filter_info'];

  const targetFilterPossibleKeys = Object.keys(
    filterDefaults[type]['defaults'],
  );

  return (
    <Collapsible
      title={name + ' (' + type + ')'}
      buttons={
        <>
          <NumberInput
            value={priority}
            stepPixelSize={10}
            width="60px"
            maxValue={Infinity}
            minValue={-Infinity}
            step={1}
            onChange={(value) =>
              act('change_priority', {
                name: name,
                new_priority: value,
              })
            }
          />
          <Button.Input
            value={name}
            onCommit={(new_name) =>
              act('rename_filter', {
                name: name,
                new_name: new_name,
              })
            }
            width="90px"
            buttonText="Rename"
          />
          <Button.Confirm
            icon="minus"
            onClick={() => act('remove_filter', { name: name })}
          />
        </>
      }
    >
      <Section>
        <LabeledList>
          {targetFilterPossibleKeys.map((entryName) => {
            const defaults = filterDefaults[type]['defaults'];
            const value = restOfProps[entryName] || defaults[entryName];
            const hasValue = value !== defaults[entryName];
            return (
              <FilterDataEntry
                key={entryName}
                filterName={name}
                filterType={type}
                name={entryName}
                value={value}
                hasValue={hasValue}
              />
            );
          })}
        </LabeledList>
      </Section>
    </Collapsible>
  );
};
