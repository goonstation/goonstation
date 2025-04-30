/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Button, Input, LabeledList, Section } from 'tgui-core/components';

interface PollOptionsSectionProps {
  onAddOption: () => void;
  onChangeOption: (index: number, value: string) => void;
  onRemoveOption: (index: number) => void;
  onSwapOptions: (indexA: number, indexB: number) => void;
  options: string[];
}

export const PollOptionsSection = (props: PollOptionsSectionProps) => {
  const {
    onAddOption,
    onChangeOption,
    onRemoveOption,
    onSwapOptions,
    options,
  } = props;
  const [reorderingOptionIndex, setReorderingOptionIndex] = useState<
    number | null
  >(null);
  const handleReorder = (index: number) => {
    if (reorderingOptionIndex === null) {
      setReorderingOptionIndex(index);
    } else {
      onSwapOptions(reorderingOptionIndex, index);
      setReorderingOptionIndex(null);
    }
  };
  return (
    <Section
      title="Options"
      fill
      scrollable
      buttons={
        <Button icon="add" onClick={onAddOption} tooltip="Add option">
          Add
        </Button>
      }
    >
      <LabeledList>
        {options.map((option, index) => (
          <PollOptionListItem
            key={index}
            label={`${index + 1}`}
            onChange={(value: string) => onChangeOption(index, value)}
            onRemove={() => onRemoveOption(index)}
            onReorder={() => handleReorder(index)}
            reordering={
              index === reorderingOptionIndex
                ? 'self'
                : reorderingOptionIndex
                  ? 'other'
                  : 'none'
            }
            value={option}
          />
        ))}
      </LabeledList>
    </Section>
  );
};

interface PollOptionListItemProps {
  label: string;
  onChange: (value: string) => void;
  onRemove: () => void;
  onReorder: () => void;
  reordering: 'self' | 'other' | 'none';
  value: string;
}

const PollOptionListItem = (props: PollOptionListItemProps) => {
  const { label, onChange, onRemove, onReorder, reordering, value } = props;
  const handleChange = (e: unknown, value: string) => onChange(value);
  const buttons = (
    <>
      {reordering === 'self' && (
        <Button
          color="red"
          icon="cancel"
          onClick={onReorder}
          tooltip="Cancel reorder"
        />
      )}
      {reordering === 'other' && (
        <Button
          icon="arrow-down-up-across-line"
          onClick={onReorder}
          tooltip="Swap"
        />
      )}
      {reordering === 'none' && (
        <Button icon="arrows-up-down" onClick={onReorder} tooltip="Swap" />
      )}
      <Button
        color="bad"
        icon="trash"
        onClick={onRemove}
        tooltip="Remove option"
      />
    </>
  );
  return (
    <LabeledList.Item label={label} buttons={buttons}>
      <Input
        width="100%"
        value={value}
        placeholder="Option text..."
        onChange={handleChange}
      />
    </LabeledList.Item>
  );
};
