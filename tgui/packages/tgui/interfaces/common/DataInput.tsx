/**
 * Copyright (c) 2023 @Azrun
 * SPDX-License-Identifier: MIT
 */

import {
  Button,
  ColorBox,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

export const DataInputOptions = (props) => {
  const { options } = props;

  return options && Object.keys(options).length
    ? Object.keys(options).map((optionName, sectionIndex) => (
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
    : '';
};

const DataInputEntry = (props) => {
  const { name, description, type } = props;
  const { act } = useBackend();

  const dataEntryTypes = {
    Number: <DataInputIntegerEntry {...props} />,
    // Type: <DataInputTypeEntry {...props} />,
    Color: <DataInputColorEntry {...props} />,
    Text: <DataInputTextEntry {...props} />,
    // Icon: <DataInputIconEntry {...props} />,
    // File: <DataInputFileEntry {...props} />,
    // Direction: <DataInputDirectionEntry {...props} />,
    // JSON: <DataInputJSONEntry {...props} />,
    Ref: <DataInputRefEntry {...props} />,
    'Mob Reference': <DataInputRefEntry {...props} />,
    'Reference Picker': <DataInputRefEntry {...props} />,
    'Bit Field': <DataInputBitFieldEntry {...props} />,
    // DATA_INPUT_TURF_BY_COORDS
    // DATA_INPUT_REFPICKER
    // DATA_INPUT_NEW_INSTANCE
    // DATA_INPUT_NULL
    // DATA_INPUT_RESTORE
    // DATA_INPUT_MOB_REFERENCE
    Boolean: <DataInputBoolEntry {...props} />,

    // DATA_INPUT_LIST_BUILD
    // DATA_INPUT_LIST_EDIT
    'Children of Type': <DataInputListEntry {...props} />,
    'List Var': <DataInputListEntry {...props} />,
    List: <DataInputListEntry {...props} />,
  };

  return (
    <LabeledList.Item label={description}>
      {dataEntryTypes[type] ||
        act('unsupported_type', {
          name: name,
          type: type,
        })}
    </LabeledList.Item>
  );
};

export const DataInputBitFieldEntry = (props) => {
  const { value, name, type } = props;
  const { act } = useBackend();
  return (
    <Section>
      {Array.apply(null, Array(24)).map((_item, buttonIndex) => (
        <Button.Checkbox
          minWidth={4}
          checked={value & (1 << buttonIndex)}
          key={buttonIndex}
          onClick={() =>
            act('modify_value', {
              name: name,
              type: type,
              value: value ^ (1 << buttonIndex),
            })
          }
        >
          {buttonIndex + 1}
        </Button.Checkbox>
      ))}
    </Section>
  );
};

const DataInputListEntry = (props) => {
  const { value, name, type, list } = props;
  const { act } = useBackend();
  return (
    <Section fill scrollable height={15}>
      {list.map((item, buttonIndex) => (
        <Button
          fluid
          key={buttonIndex}
          selected={item === value}
          color="transparent"
          onClick={() =>
            act('modify_value', {
              name: name,
              value: item,
              type: type,
            })
          }
        >
          {item}
        </Button>
      ))}
    </Section>
  );
};

const DataInputRefEntry = (props) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="location-crosshairs"
        onClick={() =>
          act('modify_ref_value', {
            name: name,
            type: type,
          })
        }
      >
        {value}
      </Button>
    </Tooltip>
  );
};

const DataInputColorEntry = (props) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="pencil-alt"
        onClick={() =>
          act('modify_color_value', {
            name: name,
            type: type,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
      <Input
        value={value}
        width="90px"
        onInput={(value) =>
          act('modify_value', {
            name: name,
            value: value,
            type: type,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputIntegerEntry = (props) => {
  const { value, tooltip, name, type, a, b } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <NumberInput
        value={value ?? a ?? 0}
        minValue={a ?? 0}
        maxValue={b ?? 100}
        stepPixelSize={5}
        width="39px"
        step={1}
        onDrag={(value) =>
          act('modify_value', {
            name: name,
            value: value,
            type: type,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputBoolEntry = (props) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button.Checkbox
        checked={value}
        // content={toggleOption}
        onClick={() =>
          act('modify_value', {
            name: name,
            value: !value,
            type: type,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputTextEntry = (props) => {
  const { value, tooltip, name, type } = props;
  const { act } = useBackend();

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        value={value}
        width="200px"
        onChange={(value) =>
          act('modify_value', {
            name: name,
            value: value,
            type: type,
          })
        }
      />
    </Tooltip>
  );
};
