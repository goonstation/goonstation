/**
 * @file
 * @copyright 2022 Saicchi
 * @author Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Image,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { LabeledControls } from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Modal } from '../components';
import { Window } from '../layouts';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';
import { capitalize } from './common/stringUtils';

const ICON_LIST_PILLS = 0;
const ICON_LIST_BOTTLES = 1;
const ICON_LIST_PATCHES = 2;

interface ChemMasterData {
  bottle_icons;
  container;
  default_name;
  patch_icons;
  pill_icons;
  name_max_len;
}

export const ReagentDisplay = (props) => {
  const { act } = useBackend();
  const { max_volume } = props;
  const container = props.container || NoContainer;

  const [remove_amount, set_remove_amount] = useSharedState(
    'remove_amount',
    10,
  );

  return (
    <Section
      title={capitalize(container.name)}
      buttons={
        <>
          <Button
            tooltip="Flush All"
            icon="times"
            color="red"
            disabled={!container.totalVolume}
            onClick={() => act('flushall')}
          />
          <Button
            tooltip="Eject"
            icon="eject"
            disabled={!props.container}
            onClick={() => act('eject')}
          />
          <Box align="left" as="span">
            {'Remove Amount: '}
            <NumberInput
              width={'4'}
              format={(value) => value + 'u'}
              value={remove_amount}
              minValue={1}
              maxValue={max_volume}
              step={1}
              onChange={(value) => set_remove_amount(Math.round(value))}
            />
          </Box>
        </>
      }
    >
      {!!props.container || (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act('insert')}
            bold
          >
            Insert Beaker
          </Button>
        </Dimmer>
      )}
      <ReagentGraph container={container} />
      <ReagentList
        container={container}
        renderButtons={(reagent) => {
          return (
            <>
              <Button
                px={0.75}
                mr={1.5}
                icon="search"
                color="green"
                tooltip="Analyze"
                onClick={() => act('analyze', { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                mr={1.5}
                icon="filter"
                color="red"
                tooltip="Isolate"
                onClick={() => act('isolate', { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                mr={1.5}
                icon="times"
                color="red"
                tooltip="Flush all"
                onClick={() => act('flush', { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                icon="minus"
                color="yellow"
                tooltip="Flush variable amount of units"
                bold
                onClick={() =>
                  act('flushinput', {
                    reagent_id: reagent.id,
                    amount: remove_amount,
                  })
                }
              >
                {remove_amount}u
              </Button>
            </>
          );
        }}
        renderButtonsDeps={remove_amount}
      />
    </Section>
  );
};

export const SelectIconModal = (props) => {
  const { data } = useBackend<ChemMasterData>();

  const pill_icons = data.pill_icons ?? [];
  const bottle_icons = data.bottle_icons ?? [];
  const patch_icons = data.patch_icons ?? [];

  const { icon_list, set_icon, cancel_modal } = props;

  const cancel_button = (
    <Button
      tooltip="Cancel"
      icon="times"
      color="red"
      mr={1}
      onClick={() => cancel_modal()}
    />
  );

  const button_image = (item, index) => (
    <Button
      key={index}
      onClick={() => {
        set_icon(index);
      }}
    >
      <Image
        height="32px"
        width="32px"
        src={`data:image/png;base64,${icon_list !== ICON_LIST_PILLS ? item[1] : item}`}
        style={{
          verticalAlign: 'middle',
        }}
      />
      {icon_list !== ICON_LIST_PILLS && (
        <Box textAlign="center" bold>
          {item[0]}u
        </Box>
      )}
    </Button>
  );

  return (
    <Modal full mx="auto" backgroundColor="#1c2734">
      {icon_list === ICON_LIST_PILLS && (
        <Section title="Select Pill" buttons={cancel_button} minWidth={10}>
          {pill_icons.map(button_image)}
        </Section>
      )}
      {icon_list === ICON_LIST_BOTTLES && (
        <Section title="Select Bottle" buttons={cancel_button} minWidth={12}>
          {bottle_icons.map(button_image)}
        </Section>
      )}
      {icon_list === ICON_LIST_PATCHES && (
        <Section title="Select Patch" buttons={cancel_button} minWidth={12}>
          {patch_icons.map(button_image)}
        </Section>
      )}
    </Modal>
  );
};

export const IconButtonControl = (props) => {
  const { modal_function, imageb64 } = props;
  return (
    <LabeledControls.Item label="">
      <Button
        tooltip="Change type"
        tooltipPosition="top"
        onClick={() => modal_function(true)}
      >
        <Image
          height="32px"
          width="32px"
          src={`data:image/png;base64,${imageb64}`}
          style={{
            verticalAlign: 'middle',
          }}
        />
      </Button>
    </LabeledControls.Item>
  );
};

export const AmountInputControl = (props) => {
  const { set_amount, current_amount, max_amount } = props;
  return (
    <LabeledControls.Item label="">
      <NumberInput
        width={'5'}
        format={(value) => value + 'u'}
        value={current_amount}
        minValue={5}
        maxValue={max_amount}
        step={1}
        onChange={(value) => set_amount(Math.round(value))}
      />
    </LabeledControls.Item>
  );
};

export const MakeButtonControl = (props) => {
  const { text, onClick } = props;
  return (
    <LabeledControls.Item label="">
      <Button onClick={onClick} width={13}>
        {text}
      </Button>
    </LabeledControls.Item>
  );
};

export const CheckboxControl = (props) => {
  const { label, checked, set_function } = props;
  return (
    <LabeledControls.Item label="">
      <Button.Checkbox checked={checked} onClick={() => set_function(!checked)}>
        {label}
      </Button.Checkbox>
    </LabeledControls.Item>
  );
};

export const MakePill = (props) => {
  const { act, data } = useBackend<ChemMasterData>();

  const { item_name, max_volume } = props;
  const [single_pill_amount, set_single_pill_amount] = useSharedState(
    'single_pill_amount',
    max_volume,
  );

  const { pill_icons } = data;
  const [modal_singlepill, set_modal_singlepill] = useState(false);
  const [icon_singlepill, set_icon_singlepill] = useSharedState(
    'icon_singlepill',
    0,
  );
  const close_modal = () => set_modal_singlepill(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_singlepill(index);
    close_modal();
  };

  return (
    <Box>
      {modal_singlepill && (
        <SelectIconModal
          icon_list={ICON_LIST_PILLS}
          set_icon={set_icon}
          cancel_modal={close_modal}
        />
      )}
      <LabeledControls width={0}>
        <IconButtonControl
          modal_function={set_modal_singlepill}
          imageb64={pill_icons ? pill_icons[icon_singlepill] : undefined}
        />
        <MakeButtonControl
          text="Create single pill"
          onClick={() =>
            act('makepill', {
              item_name,
              amount: single_pill_amount,
              icon: icon_singlepill,
            })
          }
        />
        <AmountInputControl
          set_amount={set_single_pill_amount}
          current_amount={single_pill_amount}
          max_amount={max_volume}
        />
      </LabeledControls>
    </Box>
  );
};

export const MakePills = (props) => {
  const { act, data } = useBackend<ChemMasterData>();

  const { item_name, max_volume } = props;
  const [use_bottle, set_use_bottle] = useSharedState('use_bottle', true);
  const [pills_amount, set_pills_amount] = useSharedState(
    'multiple_pills_amount',
    5,
  );

  const { pill_icons } = data;
  const [modal_multiplepills, set_modal_multiplepills] = useState(false);
  const [icon_multiplepills, set_icon_multiplepills] = useSharedState(
    'icon_multiplepills',
    0,
  );
  const close_modal = () => set_modal_multiplepills(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_multiplepills(index);
    close_modal();
  };

  return (
    <Box>
      {modal_multiplepills && (
        <SelectIconModal
          icon_list={ICON_LIST_PILLS}
          set_icon={set_icon}
          cancel_modal={close_modal}
        />
      )}
      <LabeledControls width={0}>
        <IconButtonControl
          modal_function={set_modal_multiplepills}
          imageb64={pill_icons ? pill_icons[icon_multiplepills] : undefined}
        />
        <MakeButtonControl
          text="Create multiple pills"
          onClick={() =>
            act('makepills', {
              item_name,
              amount: pills_amount,
              use_bottle: use_bottle,
              icon: icon_multiplepills,
            })
          }
        />
        <AmountInputControl
          set_amount={set_pills_amount}
          current_amount={pills_amount}
          max_amount={max_volume}
        />
        <CheckboxControl
          label="Use bottle"
          checked={use_bottle}
          set_function={set_use_bottle}
        />
      </LabeledControls>
    </Box>
  );
};

export const MakeBottle = (props) => {
  const { act, data } = useBackend<ChemMasterData>();

  const [bottle_amount, set_bottle_amount] = useSharedState(
    'bottle_amount',
    50,
  );

  const { item_name } = props;
  const { bottle_icons } = data;
  const [modal_bottle, set_modal_bottle] = useState(false);
  const [icon_bottle, set_icon_bottle] = useSharedState('icon_bottle', 2);
  const close_modal = () => set_modal_bottle(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_bottle(index);
    set_bottle_amount(bottle_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_bottle && (
        <SelectIconModal
          icon_list={ICON_LIST_BOTTLES}
          set_icon={set_icon}
          cancel_modal={close_modal}
        />
      )}
      <LabeledControls width={0}>
        <IconButtonControl
          modal_function={set_modal_bottle}
          imageb64={bottle_icons ? bottle_icons[icon_bottle][1] : undefined}
        />
        <MakeButtonControl
          text="Create bottle"
          onClick={() =>
            act('makebottle', {
              item_name,
              amount: bottle_amount,
              bottle: icon_bottle,
            })
          }
        />
        <AmountInputControl
          set_amount={set_bottle_amount}
          current_amount={bottle_amount}
          max_amount={bottle_icons ? bottle_icons[icon_bottle][0] : 50}
        />
      </LabeledControls>
    </Box>
  );
};

export const MakePatch = (props) => {
  const { act, data } = useBackend<ChemMasterData>();

  const [single_patch_amount, set_single_patch_amount] = useSharedState(
    'single_patch_amount',
    30,
  );

  const { item_name } = props;
  const { patch_icons } = data;
  const [modal_singlepatch, set_modal_singlepatch] = useState(false);
  const [icon_singlepatch, set_icon_singlepatch] = useSharedState(
    'icon_singlepatch',
    1,
  );
  const close_modal = () => set_modal_singlepatch(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_singlepatch(index);
    set_single_patch_amount(patch_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_singlepatch && (
        <SelectIconModal
          icon_list={ICON_LIST_PATCHES}
          set_icon={set_icon}
          cancel_modal={close_modal}
        />
      )}
      <LabeledControls width={0}>
        <IconButtonControl
          modal_function={set_modal_singlepatch}
          imageb64={patch_icons ? patch_icons[icon_singlepatch][1] : undefined}
        />
        <MakeButtonControl
          text="Create single patch"
          onClick={() =>
            act('makepatch', {
              item_name,
              amount: single_patch_amount,
              patch: icon_singlepatch,
            })
          }
        />
        <AmountInputControl
          set_amount={set_single_patch_amount}
          current_amount={single_patch_amount}
          max_amount={patch_icons ? patch_icons[icon_singlepatch][0] : 30}
        />
      </LabeledControls>
    </Box>
  );
};

export const MakePatches = (props) => {
  const { act, data } = useBackend<ChemMasterData>();
  const [use_box, set_use_box] = useSharedState('use_box', true);
  const [patches_amount, set_patches_amount] = useSharedState(
    'multiple_patches_amount',
    30,
  );

  const { item_name } = props;
  const { patch_icons } = data;
  const [modal_multiplepatches, set_modal_multiplepatches] = useState(false);
  const [icon_multiplepatches, set_icon_multiplepatches] = useSharedState(
    'icon_multiplepatches',
    1,
  );
  const close_modal = () => set_modal_multiplepatches(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_multiplepatches(index);
    set_patches_amount(patch_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_multiplepatches && (
        <SelectIconModal
          icon_list={ICON_LIST_PATCHES}
          set_icon={set_icon}
          cancel_modal={close_modal}
        />
      )}
      <LabeledControls width={0}>
        <IconButtonControl
          modal_function={set_modal_multiplepatches}
          imageb64={
            patch_icons ? patch_icons[icon_multiplepatches][1] : undefined
          }
        />
        <MakeButtonControl
          text="Create multiple patches"
          onClick={() =>
            act('makepatches', {
              item_name,
              amount: patches_amount,
              use_box: use_box,
              patch: icon_multiplepatches,
            })
          }
        />
        <AmountInputControl
          set_amount={set_patches_amount}
          current_amount={patches_amount}
          max_amount={patch_icons ? patch_icons[icon_multiplepatches][0] : 30}
        />
        <CheckboxControl
          label="Use patch box"
          checked={use_box}
          set_function={set_use_box}
        />
      </LabeledControls>
    </Box>
  );
};

export const OperationsSection = (props) => {
  const { placeholder, item_name, set_item_name, max_volume } = props;
  const { data } = useBackend<ChemMasterData>();
  const operation_height = 3;
  const margin_bottom = -0.5;

  return (
    <Section
      title="Operations"
      buttons={
        <Box align="left" as="span">
          {'Name: '}
          <Input
            value={item_name}
            placeholder={placeholder}
            onBlur={(value) => {
              set_item_name(value);
            }}
            maxLength={data.name_max_len}
          />
        </Box>
      }
    >
      <Stack vertical>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakePill max_volume={max_volume} item_name={item_name} />
        </Stack.Item>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakePills max_volume={max_volume} item_name={item_name} />
        </Stack.Item>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakeBottle item_name={item_name} />
        </Stack.Item>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakePatch item_name={item_name} />
        </Stack.Item>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakePatches item_name={item_name} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const ChemMaster = () => {
  const { data } = useBackend<ChemMasterData>();

  const placeholder_name = data.default_name ?? null;
  const [item_name, set_item_name] = useState('');
  const max_volume = data.container ? data.container.maxVolume : 100;

  return (
    <Window width={435} height={480} theme="ntos">
      <Window.Content>
        <ReagentDisplay container={data.container} max_volume={max_volume} />
        <OperationsSection
          container={data.container}
          max_volume={max_volume}
          item_name={item_name}
          set_item_name={set_item_name}
          placeholder={placeholder_name}
        />
      </Window.Content>
    </Window>
  );
};
