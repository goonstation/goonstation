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

interface DataInputOptionsProps {
  byondRef?: string;
  options: any;
}

export const DataInputOptions = (props: DataInputOptionsProps) => {
  const { options, byondRef } = props;

  return options && Object.keys(options).length
    ? Object.keys(options).map((optionName) => (
        <DataInputEntry
          key={optionName}
          byondRef={byondRef}
          type={options[optionName].type}
          name={
            options[optionName].name ? options[optionName].name : optionName
          }
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
    Button: <DataInputButtonEntry {...props} />,
    Buttons: <DataInputButtonsEntry {...props} />,
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
  const { value, name, type, byondRef } = props;
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
              byondRef: byondRef,
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
  const { value, name, type, list, byondRef } = props;
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
            act('modify_list_value', {
              name: name,
              value: item,
              type: type,
              byondRef: byondRef,
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
  const { value, tooltip, name, type, byondRef } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="location-crosshairs"
        onClick={() =>
          act('modify_ref_value', {
            name: name,
            type: type,
            byondRef: byondRef,
          })
        }
      >
        {value}
      </Button>
    </Tooltip>
  );
};

const DataInputButtonEntry = (props) => {
  const { tooltip, name, type, byondRef } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="play"
        width="50px"
        onClick={() =>
          act('activate', {
            name: name,
            type: type,
            byondRef: byondRef,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputButtonsEntry = (props) => {
  const { name, type, list, byondRef } = props;
  const { act } = useBackend();
  return (
    <Section fill>
      {list.map((item, buttonIndex) => (
        <Button
          fluid
          key={buttonIndex}
          onClick={() =>
            act('activate', {
              name: name,
              value: item,
              type: type,
              byondRef: byondRef,
            })
          }
        >
          {item}
        </Button>
      ))}
    </Section>
  );
};

const DataInputColorEntry = (props) => {
  const { value, tooltip, name, type, byondRef } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button
        icon="pencil-alt"
        onClick={() =>
          act('modify_color_value', {
            name: name,
            type: type,
            byondRef: byondRef,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
      <Input
        value={value}
        width="90px"
        onChange={(value) => {
          act('modify_value', {
            name: name,
            value: value,
            type: type,
            byondRef: byondRef,
          });
        }}
      />
    </Tooltip>
  );
};

const DataInputIntegerEntry = (props) => {
  const { value, tooltip, name, type, a, b, byondRef } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <NumberInput
        value={value ?? a ?? 0}
        minValue={a ?? 0}
        maxValue={b ?? 100}
        stepPixelSize={5}
        width="30px"
        step={1}
        tickWhileDragging
        onChange={(value) =>
          act('modify_value', {
            name: name,
            value: value,
            type: type,
            byondRef: byondRef,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputBoolEntry = (props) => {
  const { value, tooltip, name, type, byondRef } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button.Checkbox
        checked={value}
        onClick={() =>
          act('modify_value', {
            name: name,
            value: !value,
            type: type,
            byondRef: byondRef,
          })
        }
      />
    </Tooltip>
  );
};

const DataInputTextEntry = (props) => {
  const { value, tooltip, name, type, byondRef } = props;
  const { act } = useBackend();

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        fluid
        value={value}
        onChange={(value) => {
          act('modify_value', {
            name: name,
            value: value,
            type: type,
            byondRef: byondRef,
          });
        }}
      />
    </Tooltip>
  );
};
