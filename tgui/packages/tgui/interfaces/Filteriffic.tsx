/**
 * @file
 * @copyright 2020
 * @author actioninja  (https://github.com/actioninja )
 * @license MIT
 */

import { map } from 'common/collections';
import { numberOfDecimalDigits } from 'common/math';
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  ColorBox,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface FilterifficData {
  filter_info;
  target_name;
  target_filter_data;
}

const FilterIntegerEntry = (props) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  return (
    <NumberInput
      value={value}
      minValue={-500}
      maxValue={500}
      stepPixelSize={5}
      step={1}
      width="39px"
      onDrag={(value) =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value,
          },
        })
      }
    />
  );
};

const FilterFloatEntry = (props) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  const [step, setStep] = useState(0.01);
  return (
    <>
      <NumberInput
        value={value}
        minValue={-500}
        maxValue={500}
        stepPixelSize={4}
        step={step}
        format={(value) => toFixed(value, numberOfDecimalDigits(step))}
        width="80px"
        onDrag={(value) =>
          act('transition_filter_value', {
            name: filterName,
            new_data: {
              [name]: value,
            },
          })
        }
      />
      <Box inline ml={2} mr={1}>
        Step:
      </Box>
      <NumberInput
        value={step}
        step={0.001}
        format={(value) => toFixed(value, 4)}
        width="70px"
        onChange={(value) => setStep(value)}
        maxValue={Infinity}
        minValue={-Infinity}
      />
    </>
  );
};

const FilterTextEntry = (props) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();

  return (
    <Input
      value={value}
      width="250px"
      onInput={(e, value) =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value,
          },
        })
      }
    />
  );
};

const FilterTransformEntry = (props) => {
  const { value, name, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  let transMatrix = value;
  if (transMatrix === null) {
    transMatrix = Array(1, 0, 0, 0, 1, 0);
  }
  return (
    <>
      Matrix:
      <Stack>
        {[0, 1, 2].map((col, key) => (
          <Stack.Item key={key}>
            <Stack vertical>
              {[0, 1, 2].map((row, key) => (
                <Stack.Item key={key}>
                  {col === 2 && row < 2 && 0}
                  {col === 2 && row === 2 && 1}
                  {col < 2 && (
                    <NumberInput
                      value={transMatrix[col * 3 + row]}
                      step={0.01}
                      width="50px"
                      format={(v) => toFixed(v, 2)}
                      onDrag={(v) => {
                        let retTrans = transMatrix;
                        retTrans[col * 3 + row] = v;
                        act('transition_filter_value', {
                          name: filterName,
                          new_data: {
                            [name]: retTrans,
                          },
                        });
                      }}
                      maxValue={Infinity}
                      minValue={-Infinity}
                    />
                  )}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </>
  );
};

const FilterColorEntry = (props, context) => {
  const { value, filterName, name } = props;
  const { act } = useBackend<FilterifficData>();
  const prefixes = ['r', 'g', 'b', 'a', 'c'];
  if (Array.isArray(value)) {
    // standardise to 20 val color matrix
    let colmatrix = value;
    if (colmatrix.length < 20) {
      while (colmatrix.length < 12) {
        colmatrix.push(0);
      }
      colmatrix = Array(
        colmatrix[0],
        colmatrix[1],
        colmatrix[2],
        0,
        colmatrix[3],
        colmatrix[4],
        colmatrix[5],
        0,
        colmatrix[6],
        colmatrix[7],
        colmatrix[8],
        0,
        0,
        0,
        0,
        1,
        colmatrix[9],
        colmatrix[10],
        colmatrix[11],
        0,
      );
      while (colmatrix.length < 20) {
        colmatrix.push(0);
      }
    }
    return (
      <>
        <Button
          icon="pencil-alt"
          onClick={() =>
            act('modify_color_value', {
              name: filterName,
            })
          }
        />
        <Stack>
          {[0, 1, 2, 3].map((col, key) => (
            <Stack.Item key={key}>
              <Stack vertical>
                {[0, 1, 2, 3, 4].map((row, key) => (
                  <Stack.Item key={key}>
                    <Box inline textColor="label" width="2.1rem">
                      {`${prefixes[row]}${prefixes[col]}:`}
                    </Box>
                    <NumberInput
                      value={colmatrix[row * 4 + col]}
                      step={0.01}
                      width="50px"
                      format={(v) => toFixed(v, 2)}
                      onDrag={(v) => {
                        let retColor = colmatrix;
                        retColor[row * 4 + col] = v;
                        act('transition_filter_value', {
                          name: filterName,
                          new_data: {
                            [name]: retColor,
                          },
                        });
                      }}
                      maxValue={Infinity}
                      minValue={-Infinity}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </>
    );
  } else {
    return (
      <>
        {value.type}
        <Button
          icon="pencil-alt"
          onClick={() =>
            act('modify_color_value', {
              name: filterName,
            })
          }
        />
        <ColorBox color={value} mr={0.5} />
        <Input
          value={value}
          width="90px"
          onInput={(e, value) =>
            act('transition_filter_value', {
              name: filterName,
              new_data: {
                [name]: value,
              },
            })
          }
        />
        <Button
          onClick={() =>
            act('convert_color_value_matrix', {
              name: filterName,
            })
          }
        >
          Convert to color matrix
        </Button>
      </>
    );
  }
};

const FilterIconEntry = (props) => {
  const { value, filterName } = props;
  const { act } = useBackend<FilterifficData>();
  return (
    <>
      <Button
        icon="pencil-alt"
        onClick={() =>
          act('modify_icon_value', {
            name: filterName,
          })
        }
      />
      <Box inline ml={1}>
        {value}
      </Box>
    </>
  );
};

const FilterFlagsEntry = (props) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['flags'];
  return map(flags, (bitField: number, flagName) => (
    <Button.Checkbox
      checked={value & bitField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value ^ bitField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};

const FilterSpaceEntry = (props) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['space'];
  return map(flags, (spaceField, flagName) => (
    <Button.Checkbox
      checked={value === spaceField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: spaceField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};

const FilterBlendmodeEntry = (props) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend<FilterifficData>();

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['blend_mode'];
  return map(flags, (flagField, flagName) => (
    <Button.Checkbox
      checked={value === flagField}
      onClick={() =>
        act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: flagField,
          },
        })
      }
    >
      {flagName}
    </Button.Checkbox>
  ));
};

const FilterDataEntry = (props) => {
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

const FilterEntry = (props) => {
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
            placeholder={name}
            onCommit={(e, new_name) =>
              act('rename_filter', {
                name: name,
                new_name: new_name,
              })
            }
            width="90px"
          >
            Rename
          </Button.Input>
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
