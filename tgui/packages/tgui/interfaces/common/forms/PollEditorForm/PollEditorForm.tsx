/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { ExpiryInput } from './ExpiryInput';
import { PollOptionsSection } from './PollOptionsSection';
import type { ExpiryOptions, PollSettings } from './types';

interface PollEditorFormProps {
  currentSettings: PollSettings;
  currentOptions: string[];
  onChangeOptions: (newOptions: string[]) => void;
  onSettingsUpdate: (update: Partial<PollSettings>) => void;
  serverOptions: string[];
}

export const PollEditorForm = (props: PollEditorFormProps) => {
  const {
    currentSettings,
    currentOptions,
    onChangeOptions,
    onSettingsUpdate,
    serverOptions,
  } = props;
  const { alertPlayers, expiry, multipleChoice, servers, title } =
    currentSettings;

  const handleChangeServer = (value: string) =>
    onSettingsUpdate({ servers: value });
  const handleChangeTitle = (_e: unknown, value: string) =>
    onSettingsUpdate({ title: value });
  const handleChangeExpiry = (newExpiry: ExpiryOptions) =>
    onSettingsUpdate({
      expiry: newExpiry,
    });
  const handleToggleAlertPlayers = () =>
    onSettingsUpdate({ alertPlayers: !alertPlayers });
  const handleToggleMultipleChoice = () =>
    onSettingsUpdate({ multipleChoice: !multipleChoice });

  const handleAddOption = () => onChangeOptions([...currentOptions, '']);
  const handleRemoveOption = (optionIndex: number) =>
    onChangeOptions([
      ...currentOptions.slice(0, optionIndex),
      ...currentOptions.slice(optionIndex + 1),
    ]);
  const handleChangeOption = (optionIndex: number, value: string) => {
    const newOptions = [...currentOptions];
    newOptions[optionIndex] = value;
    onChangeOptions(newOptions);
  };
  const handleSwapOptions = (optionIndexA: number, optionIndexB: number) => {
    const newOptions = [...currentOptions];
    newOptions[optionIndexA] = currentOptions[optionIndexB];
    newOptions[optionIndexB] = currentOptions[optionIndexA];
    onChangeOptions(newOptions);
  };

  return (
    <>
      <Stack.Item>
        <Section title="Settings">
          <LabeledList>
            <LabeledList.Item label="Poll Title">
              <Input
                width="100%"
                placeholder="Title..."
                onChange={handleChangeTitle}
                value={title}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Expires" verticalAlign="middle">
              <ExpiryInput onChange={handleChangeExpiry} value={expiry} />
            </LabeledList.Item>
            <LabeledList.Item label="Server" verticalAlign="middle">
              <Dropdown
                options={serverOptions}
                selected={servers}
                key={servers}
                onSelected={handleChangeServer}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Multiple Choice">
              <Button.Checkbox
                checked={multipleChoice}
                onClick={handleToggleMultipleChoice}
              >
                {multipleChoice ? 'Yes' : 'No'}
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="Alert Players">
              <Button.Checkbox
                checked={alertPlayers}
                onClick={handleToggleAlertPlayers}
              >
                {alertPlayers ? 'Yes' : 'No'}
              </Button.Checkbox>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <PollOptionsSection
          onAddOption={handleAddOption}
          onChangeOption={handleChangeOption}
          onRemoveOption={handleRemoveOption}
          onSwapOptions={handleSwapOptions}
          options={currentOptions}
        />
      </Stack.Item>
    </>
  );
};
