/**
 * @file
 * @copyright 2020
 * @author actioninja (https://github.com/actioninja)
 * @license MIT
 */

import { Box, LabeledList } from 'tgui-core/components';

import {
  FilterBlendmodeEntry,
  FilterColorEntry,
  FilterFlagsEntry,
  FilterFloatEntry,
  FilterIconEntry,
  FilterIntegerEntry,
  FilterSpaceEntry,
  FilterTextEntry,
  FilterTransformEntry,
} from './filterDataEntries';

export const FilterDataEntry = (props) => {
  const { name, hasValue } = props;

  const filterEntryTypes = {
    int: <FilterIntegerEntry {...props} />,
    float: <FilterFloatEntry {...props} />,
    string: <FilterTextEntry {...props} />,
    color: <FilterColorEntry {...props} />,
    icon: <FilterIconEntry {...props} />,
    flags: <FilterFlagsEntry {...props} />,
    space: <FilterSpaceEntry {...props} />,
    blendmode: <FilterBlendmodeEntry {...props} />,
    matrix: <FilterTransformEntry {...props} />,
  };

  const filterEntryMap = {
    x: 'float',
    y: 'float',
    icon: 'icon',
    render_source: 'string',
    flags: 'flags',
    size: 'float',
    color: 'color',
    offset: 'float',
    radius: 'float',
    space: 'space',
    falloff: 'float',
    density: 'int',
    threshold: 'float',
    factor: 'float',
    repeat: 'int',
    transform: 'matrix',
    blend_mode: 'blendmode',
  };

  return (
    <LabeledList.Item label={name}>
      {filterEntryTypes[filterEntryMap[name]] || 'Not Found (This is an error)'}
      {!hasValue && (
        <>
          {' '}
          <Box inline color="average">
            (Default)
          </Box>
        </>
      )}
    </LabeledList.Item>
  );
};
