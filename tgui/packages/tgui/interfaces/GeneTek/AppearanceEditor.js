/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Fragment } from "inferno";
import { useBackend } from "../../backend";
import { Box, Button, ByondUi, ColorBox, Dropdown, Flex, Knob, LabeledList, Section } from "../../components";

export const AppearanceEditor = (params, context) => {
  const { act } = useBackend(context);
  const {
    preview,
    hairStyles,
    skin,
    eyes,
    color1,
    color2,
    color3,
    style1,
    style2,
    style3,
    fixColors,
    hasEyes,
    hasSkin,
    hasHair,
    channels,
  } = params;

  return (
    <Section
      title="Appearance Editor"
      buttons={
        <Fragment>
          <Button
            onClick={() => act("editappearance", { apply: true })}
            icon="user"
            color="good">
            Apply Changes
          </Button>
          <Button
            onClick={() => act("editappearance", { cancel: true })}
            icon="times"
            color="bad" />
        </Fragment>
      }>
      <Flex>
        <Flex.Item shrink="1">
          <LabeledList>
            {!!hasSkin && (
              <LabeledList.Item label="Skin Tone">
                <ColorInput
                  color={skin}
                  onChange={c => act("editappearance", { skin: c })} />
              </LabeledList.Item>
            )}
            {!!hasEyes && (
              <LabeledList.Item label="Eye Color">
                <ColorInput
                  color={eyes}
                  onChange={c => act("editappearance", { eyes: c })} />
              </LabeledList.Item>
            )}
            {!!((hasSkin || hasEyes) && channels[0]) && <LabeledList.Divider />}
            {!!channels[0] && !!hasHair && (
              <LabeledList.Item label={channels[0]}>
                <Dropdown
                  width={20}
                  selected={style1}
                  onSelected={s => act("editappearance", { style1: s })}
                  options={hairStyles} />
              </LabeledList.Item>
            )}
            {!!channels[0] && (
              <LabeledList.Item label={`${channels[0].replace(/ Detail$/, "")} Color`}>
                <ColorInput
                  color={color1}
                  onChange={c => act("editappearance", { color1: c })}
                  fix={fixColors} />
              </LabeledList.Item>
            )}
            {!!channels[1] && <LabeledList.Divider />}
            {!!channels[1] && !!hasHair && (
              <LabeledList.Item label={channels[1]}>
                <Dropdown
                  width={20}
                  selected={style2}
                  onSelected={s => act("editappearance", { style2: s })}
                  options={hairStyles} />
              </LabeledList.Item>
            )}
            {!!channels[1] && (
              <LabeledList.Item label={`${channels[1].replace(/ Detail$/, "")} Color`}>
                <ColorInput
                  color={color2}
                  onChange={c => act("editappearance", { color2: c })}
                  fix={fixColors} />
              </LabeledList.Item>
            )}
            {!!channels[2] && <LabeledList.Divider />}
            {!!channels[2] && !!hasHair && (
              <LabeledList.Item label={channels[2]}>
                <Dropdown
                  width={20}
                  selected={style3}
                  onSelected={s => act("editappearance", { style3: s })}
                  options={hairStyles} />
              </LabeledList.Item>
            )}
            {!!channels[2] && (
              <LabeledList.Item label={`${channels[2].replace(/ Detail$/, "")} Color`}>
                <ColorInput
                  color={color3}
                  onChange={c => act("editappearance", { color3: c })}
                  fix={fixColors} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Flex.Item>
        <Flex.Item basis="80px" shrink="0">
          <ByondUi
            params={{
              id: preview,
              type: "map",
            }}
            style={{
              width: "80px",
              height: "80px",
            }} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ColorInput = (params, context) => {
  const {
    color,
    onChange,
    fix,
  } = params;

  const r = parseInt(color.substr(1, 2), 16);
  const g = parseInt(color.substr(3, 2), 16);
  const b = parseInt(color.substr(5, 2), 16);

  const onComponentChange = (newR, newG, newB) => {
    if (onChange) {
      onChange("#"
        + newR.toString(16).padStart(2, "0")
        + newG.toString(16).padStart(2, "0")
        + newB.toString(16).padStart(2, "0"));
    }
  };

  return (
    <Box>
      <ColorBox color={color} />
      <Knob
        inline
        ml={1}
        minValue={fix ? 50 : 0}
        maxValue={fix ? 190 : 255}
        value={r}
        color="red"
        onChange={(_, newR) => onComponentChange(newR, g, b)} />
      <Knob
        inline
        ml={1}
        minValue={fix ? 50 : 0}
        maxValue={fix ? 190 : 255}
        value={g}
        color="green"
        onChange={(_, newG) => onComponentChange(r, newG, b)} />
      <Knob
        inline
        ml={1}
        minValue={fix ? 50 : 0}
        maxValue={fix ? 190 : 255}
        value={b}
        color="blue"
        onChange={(_, newB) => onComponentChange(r, g, newB)} />
    </Box>
  );
};
