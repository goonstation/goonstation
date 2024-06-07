/**
 * Copyright (c) 2023 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../../backend';
import { Button, ColorBox, Input, LabeledList, NumberInput, Section, Tooltip } from '../../components';

export const DataInputOptions = props => {
  const {
    options,
  } = props;

  return (
    options && Object.keys(options).length ? (
      Object.keys(options).map((optionName, sectionIndex) => (
        <DataInputEntry
          key={optionName}
          type={options[optionName].type}
          name={optionName}
          description={options[optionName].description}
          value={options[optionName].value}
          tooltip={options[optionName].description}
          list={options[optionName].list}
          a={options[optionName].a}
          b={options[optionName].b}
        />
      ))
    )
      : ""
  );
};

const DataInputEntry = (props, context) => {
  const { name, description, type } = props;
  const { act } = useBackend(context);

  const dataEntryTypes = {
    Number: <DataInputIntegerEntry {...props} />,
    // Type: <DataInputTypeEntry {...props} />,
    Color: <DataInputColorEntry {...props} />,
    Text: <DataInputTextEntry {...props} />,
    // Icon: <DataInputIconEntry {...props} />,
    // File: <DataInputFileEntry {...props} />,
    // Direction: <DataInputDirectionEntry {...props} />,
    // JSON: <DataInputJSONEntry {...props} />,
    "Ref": <DataInputRefEntry {...props} />,
    "Mob Reference": <DataInputRefEntry {...props} />,
    "Reference Picker": <DataInputRefEntry {...props} />,
    "Bit Field": <DataInputBitFieldEntry {...props} />,
    // DATA_INPUT_TURF_BY_COORDS
    // DATA_INPUT_REFPICKER
    // DATA_INPUT_NEW_INSTANCE
    // DATA_INPUT_NULL
    // DATA_INPUT_RESTORE
    // DATA_INPUT_MOB_REFERENCE
    Boolean: <DataInputBoolEntry {...props} />,

    // DATA_INPUT_LIST_BUILD
    // DATA_INPUT_LIST_EDIT
    "Children of Type": <DataInputListEntry {...props} />,
    "List Var": <DataInputListEntry {...props} />,
    List: <DataInputListEntry {...props} />,
  };

  return (
    <LabeledList.Item label={description}>
      {dataEntryTypes[type] || act('unsupported_type', {
        name: name,
        type: type,
      })}
    </LabeledList.Item>
  );
};

export const DataInputBitFieldEntry = (props, context) => {
  const { value, tooltip, name, type, list } = props;
  const { act } = useBackend(context);
  return (
    <Section>
      {Array.apply(null, { length: 24 }).map((item, buttonIndex) => (
        <Button.Checkbox
          minWidth={4}
          checked={value & (1 <<buttonIndex)}
          key={buttonIndex}
          content={buttonIndex+1}
          onClick={() => act('modify_value', {
            name: name,
            type: type,
            value: value ^ (1 << buttonIndex),
          })}
        />
      ))}
    </Section>
  );
};

const DataInputListEntry = (props, context) => {
  const { value, tooltip, name, type, list } = props;
  const { act } = useBackend(context);
  return (
    <Section fill scrollable height={15}>
      {list.map((item, buttonIndex) => (
        <Button fluid key={buttonIndex}
          selected={item === value}
          color="transparent"
          onClick={() => act('modify_value', {
            name: name,
            value: item,
            type: type,
          })}
        >
          {item}
        </Button>
      ))}
    </Section>
  );
};

const DataInputRefEntry = (props, context) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="location-crosshairs"
        onClick={() => act('modify_ref_value', {
          name: name,
          type: type,
        })}>
        {value}
      </Button>
    </Tooltip>
  );
};

const DataInputColorEntry = (props, context) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="pencil-alt"
        onClick={() => act('modify_color_value', {
          name: name,
          type: type,
        })} />
      <ColorBox
        color={value}
        mr={0.5} />
      <Input
        value={value}
        width="90px"
        onInput={(e, value) => act('modify_value', {
          name: name,
          value: value,
          type: type,
        })} />
    </Tooltip>
  );
};

const DataInputIntegerEntry = (props, context) => {
  const { value, tooltip, name, type, a, b } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
      <NumberInput
        value={value}
        minValue={a | 0}
        maxValue={b | 100}
        stepPixelSize={5}
        width="39px"
        onDrag={(e, value) => act('modify_value', {
          name: name,
          value: value,
          type: type,
        })} />
    </Tooltip>
  );
};

const DataInputBoolEntry = (props, context) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button.Checkbox
        checked={value}
        // content={toggleOption}
        onClick={() => act('modify_value', {
          name: name,
          value: !value,
          type: type,
        })}
      />
    </Tooltip>
  );
};

const DataInputTextEntry = (props, context) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend(context);

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        value={value}
        width="200px"
        onInput={(e, value) => act('modify_value', {
          name: name,
          value: value,
          type: type,
        })} />
    </Tooltip>
  );
};
