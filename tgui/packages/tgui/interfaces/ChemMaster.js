/**
 * @file
 * @copyright 2022 Saicchi
 * @author Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from "../backend";
import { LabeledControls, Input, Box, NumberInput, Button, Dimmer, Image, SectionEx, Stack, Modal } from '../components';
import { Window } from '../layouts';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';
import { useSharedState, useLocalState } from "../backend";

const ICON_LIST_PILLS = 0;
const ICON_LIST_BOTTLES = 1;
const ICON_LIST_PATCHES = 2;

export const ReagentDisplay = (props, context) => {
  const { act } = useBackend(context);
  const { max_volume } = props;
  const container = props.container || NoContainer;

  const [remove_amount, set_remove_amount] = useSharedState(context, "remove_amount", 10);

  return (
    <SectionEx
      capitalize
      title={container.name}
      buttons={
        <>
          <Button
            title="Flush All"
            icon="times"
            color="red"
            disabled={!container.totalVolume}
            onClick={() => act("flushall")}
          />
          <Button
            title="Eject"
            icon="eject"
            disabled={!props.container}
            onClick={() => act("eject")}
          />
          <Box align="left" as="span">
            {"Remove Amount: "}
            <NumberInput
              width={4}
              format={value => value + "u"}
              value={remove_amount}
              minValue={1}
              maxValue={max_volume}
              onDrag={(e, value) => set_remove_amount(Math.round(value))}
            />
          </Box>
        </>
      }>
      {!!props.container || (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act("insert")}
            bold>
            Insert Beaker
          </Button>
        </Dimmer>
      )}
      <ReagentGraph container={container} />
      <ReagentList container={container}
        renderButtons={(reagent) => {
          return (
            <>
              <Button
                px={0.75}
                mr={1.5}
                icon="search"
                color="green"
                title="Analyze"
                onClick={() => act("analyze", { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                mr={1.5}
                icon="filter"
                color="red"
                title="Isolate"
                onClick={() => act("isolate", { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                mr={1.5}
                icon="times"
                color="red"
                title="Flush all"
                onClick={() => act("flush", { reagent_id: reagent.id })}
              />
              <Button
                px={0.75}
                icon="minus"
                color="yellow"
                title="Flush variable amount of units"
                bold
                onClick={() => act("flushinput", { reagent_id: reagent.id, amount: remove_amount })}>
                {remove_amount}u
              </Button>
            </>
          );
        }}
      />
    </SectionEx>
  );
};


export const SelectIconModal = (props, context) => {
  const { data } = useBackend(context);

  const pill_icons = data.pill_icons ?? [];
  const bottle_icons = data.bottle_icons ?? [];
  const patch_icons = data.patch_icons ?? [];

  const { icon_list, set_icon, cancel_modal } = props;

  const cancel_button = (<Button
    title="Cancel"
    icon="times"
    color="red"
    mr={1}
    onClick={() => cancel_modal()}
  />);


  const button_image = (item, index) => (
    <Button key={index}
      onClick={() => { set_icon(index); }}>
      <Image
        height="32px" width="32px"
        pixelated
        src={`data:image/png;base64,${icon_list !== ICON_LIST_PILLS ? item[1] : item}`}
        style={{
          'vertical-align': 'middle',
          'horizontal-align': 'middle',
        }} />
      {
        icon_list !== ICON_LIST_PILLS && (
          <Box
            textAlign="center" bold>{item[0]}u
          </Box>
        )
      }
    </Button>
  );

  return (
    <Modal full mx="auto"
      backgroundColor="#1c2734"
    >
      {
        icon_list === ICON_LIST_PILLS && (
          <SectionEx capitalize
            title="Select pill" buttons={cancel_button} minWidth={10}>
            {
              pill_icons.map(button_image)
            }
          </SectionEx>)
      }
      {
        icon_list === ICON_LIST_BOTTLES && (
          <SectionEx capitalize
            title="Select bottle" buttons={cancel_button} minWidth={12}>
            {
              bottle_icons.map(button_image)
            }
          </SectionEx>)
      }
      {
        icon_list === ICON_LIST_PATCHES && (
          <SectionEx capitalize
            title="Select patch" buttons={cancel_button} minWidth={12}>
            {
              patch_icons.map(button_image)
            }
          </SectionEx>)
      }
    </Modal>
  );
};

export const IconButtonControl = (props) => {
  const { modal_function, imageb64 } = props;
  return (
    <LabeledControls.Item>
      <Button
        tooltip="Change type"
        tooltipPosition="top"
        onClick={() => modal_function(true)}>
        <Image
          height="32px" width="32px"
          pixelated
          src={`data:image/png;base64,${imageb64}`}
          style={{
            'vertical-align': 'middle',
            'horizontal-align': 'middle',
          }}
        />
      </Button>
    </LabeledControls.Item>
  );
};

export const AmountInputControl = (props) => {
  const { set_amount, current_amount, max_amount } = props;
  return (
    <LabeledControls.Item>
      <NumberInput
        width={5}
        format={value => value + "u"}
        value={current_amount}
        minValue={5}
        maxValue={max_amount}
        onDrag={(e, value) => set_amount(Math.round(value))}
      />
    </LabeledControls.Item>
  );
};

export const MakeButtonControl = (props) => {
  const { text, onClick } = props;
  return (
    <LabeledControls.Item>
      <Button onClick={onClick} width={13}>
        {text}
      </Button>
    </LabeledControls.Item>
  );
};

export const CheckboxControl = (props) => {
  const { label, checked, set_function } = props;
  return (
    <LabeledControls.Item>
      <Button.Checkbox
        checked={checked}
        onClick={() => set_function(!checked)} >
        {label}
      </Button.Checkbox>
    </LabeledControls.Item>
  );
};

export const MakePill = (props, context) => {
  const { act, data } = useBackend(context);

  const { item_name, max_volume } = props;
  const [single_pill_amount, set_single_pill_amount] = useSharedState(context, "single_pill_amount", max_volume);

  const { pill_icons } = data;
  const [modal_singlepill, set_modal_singlepill] = useLocalState(context, "modal_singlepill", false);
  const [icon_singlepill, set_icon_singlepill] = useSharedState(context, "icon_singlepill", 0);
  const close_modal = () => set_modal_singlepill(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_singlepill(index);
    close_modal();
  };

  return (
    <Box>
      {modal_singlepill && <SelectIconModal
        icon_list={ICON_LIST_PILLS}
        set_icon={set_icon} cancel_modal={close_modal} />}
      <LabeledControls width={0}>
        <IconButtonControl modal_function={set_modal_singlepill}
          imageb64={pill_icons ? pill_icons[icon_singlepill] : undefined} />
        <MakeButtonControl text="Create single pill"
          onClick={() => act("makepill", { item_name: item_name, amount: single_pill_amount, icon: icon_singlepill })} />
        <AmountInputControl set_amount={set_single_pill_amount}
          current_amount={single_pill_amount} max_amount={max_volume} />
      </LabeledControls>
    </Box>
  );
};

export const MakePills = (props, context) => {
  const { act, data } = useBackend(context);

  const { item_name, max_volume } = props;
  const [use_bottle, set_use_bottle] = useSharedState(context, "use_bottle", true);
  const [pills_amount, set_pills_amount] = useSharedState(context, "multiple_pills_amount", 5);

  const { pill_icons } = data;
  const [modal_multiplepills, set_modal_multiplepills] = useLocalState(context, "modal_multiplepills", false);
  const [icon_multiplepills, set_icon_multiplepills] = useSharedState(context, "icon_multiplepills", 0);
  const close_modal = () => set_modal_multiplepills(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_multiplepills(index);
    close_modal();
  };

  return (
    <Box>
      {modal_multiplepills && <SelectIconModal
        icon_list={ICON_LIST_PILLS}
        set_icon={set_icon} cancel_modal={close_modal} />}
      <LabeledControls width={0}>
        <IconButtonControl modal_function={set_modal_multiplepills}
          imageb64={pill_icons ? pill_icons[icon_multiplepills] : undefined} />
        <MakeButtonControl text="Create multiple pills"
          onClick={() => act("makepills", { item_name: item_name, amount: pills_amount, use_bottle: use_bottle, icon: icon_multiplepills })} />
        <AmountInputControl set_amount={set_pills_amount}
          current_amount={pills_amount} max_amount={max_volume} />
        <CheckboxControl label="Use bottle" checked={use_bottle} set_function={set_use_bottle} />
      </LabeledControls>
    </Box >
  );
};

export const MakeBottle = (props, context) => {
  const { act, data } = useBackend(context);

  const [bottle_amount, set_bottle_amount] = useSharedState(context, "bottle_amount", 50);

  const { item_name } = props;
  const { bottle_icons } = data;
  const [modal_bottle, set_modal_bottle] = useLocalState(context, "modal_bottle", false);
  const [icon_bottle, set_icon_bottle] = useSharedState(context, "icon_bottle", 2);
  const close_modal = () => set_modal_bottle(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_bottle(index);
    set_bottle_amount(bottle_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_bottle && <SelectIconModal
        icon_list={ICON_LIST_BOTTLES}
        set_icon={set_icon} cancel_modal={close_modal} />}
      <LabeledControls width={0}>
        <IconButtonControl modal_function={set_modal_bottle}
          imageb64={bottle_icons ? bottle_icons[icon_bottle][1] : undefined} />
        <MakeButtonControl text="Create bottle"
          onClick={() => act("makebottle", { item_name: item_name, amount: bottle_amount, bottle: icon_bottle })} />
        <AmountInputControl set_amount={set_bottle_amount}
          current_amount={bottle_amount}
          max_amount={bottle_icons ? bottle_icons[icon_bottle][0] : 50} />
      </LabeledControls>
    </Box>
  );
};

export const MakePatch = (props, context) => {
  const { act, data } = useBackend(context);

  const [single_patch_amount, set_single_patch_amount] = useSharedState(context, "single_patch_amount", 30);

  const { item_name } = props;
  const { patch_icons } = data;
  const [modal_singlepatch, set_modal_singlepatch] = useLocalState(context, "modal_singlepatch", false);
  const [icon_singlepatch, set_icon_singlepatch] = useSharedState(context, "icon_singlepatch", 1);
  const close_modal = () => set_modal_singlepatch(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_singlepatch(index);
    set_single_patch_amount(patch_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_singlepatch && <SelectIconModal
        icon_list={ICON_LIST_PATCHES}
        set_icon={set_icon} cancel_modal={close_modal} />}
      <LabeledControls width={0}>
        <IconButtonControl modal_function={set_modal_singlepatch}
          imageb64={patch_icons ? patch_icons[icon_singlepatch][1] : undefined} />
        <MakeButtonControl text="Create single patch"
          onClick={() => act("makepatch", { item_name: item_name, amount: single_patch_amount, patch: icon_singlepatch })} />
        <AmountInputControl set_amount={set_single_patch_amount}
          current_amount={single_patch_amount}
          max_amount={patch_icons ? patch_icons[icon_singlepatch][0] : 30} />
      </LabeledControls>
    </Box>
  );
};

export const MakePatches = (props, context) => {
  const { act, data } = useBackend(context);
  const [use_box, set_use_box] = useSharedState(context, "use_box", true);
  const [patches_amount, set_patches_amount] = useSharedState(context, "multiple_patches_amount", 30);

  const { item_name } = props;
  const { patch_icons } = data;
  const [modal_multiplepatches, set_modal_multiplepatches] = useLocalState(context, "modal_multiplepatches", false);
  const [icon_multiplepatches, set_icon_multiplepatches] = useSharedState(context, "icon_multiplepatches", 1);
  const close_modal = () => set_modal_multiplepatches(false); // cancel/close modal
  const set_icon = (index) => {
    set_icon_multiplepatches(index);
    set_patches_amount(patch_icons[index][0]); // set maximum value
    close_modal();
  };

  return (
    <Box>
      {modal_multiplepatches && <SelectIconModal
        icon_list={ICON_LIST_PATCHES}
        set_icon={set_icon} cancel_modal={close_modal} />}
      <LabeledControls width={0}>
        <IconButtonControl modal_function={set_modal_multiplepatches}
          imageb64={patch_icons ? patch_icons[icon_multiplepatches][1] : undefined} />
        <MakeButtonControl text="Create multiple patches"
          onClick={() => act("makepatches", { item_name: item_name, amount: patches_amount, use_box: use_box, patch: icon_multiplepatches })} />
        <AmountInputControl set_amount={set_patches_amount}
          current_amount={patches_amount}
          max_amount={patch_icons ? patch_icons[icon_multiplepatches][0] : 30} />
        <CheckboxControl label="Use patch box" checked={use_box} set_function={set_use_box} />
      </LabeledControls>
    </Box >
  );
};

export const OperationsSection = (props, context) => {
  const { act } = useBackend(context);
  const { placeholder, item_name, set_item_name, max_volume } = props;

  const operation_height = 3;
  const margin_bottom = -0.5;

  return (
    <SectionEx
      capitalize
      title="Operations"
      buttons={
        <Box align="left" as="span">
          {"Name: "}
          <Input
            value={item_name}
            placeholder={placeholder}
            onChange={(e, value) => { set_item_name(value); }}
          />
        </Box>
      } >
      <Stack vertical>
        <Stack.Item mb={margin_bottom} height={operation_height}>
          <MakePill max_volume={max_volume} item_name={item_name} />
        </Stack.Item>
        <Stack.Item mb={margin_bottom} height={operation_height} >
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
    </SectionEx>
  );
};

export const ChemMaster = (props, context) => {
  const { data } = useBackend(context);

  const placeholder_name = data.default_name ?? null;
  const [item_name, set_item_name] = useLocalState(context, "item_name", "");
  const max_volume = data.container ? data.container.maxVolume : 100;

  return (
    <Window
      width={435}
      height={480}
      theme="ntos">
      <Window.Content>
        <ReagentDisplay container={data.container} max_volume={max_volume} />
        <OperationsSection container={data.container} max_volume={max_volume}
          item_name={item_name} set_item_name={set_item_name} placeholder={placeholder_name} />
      </Window.Content>
    </Window>
  );
};
