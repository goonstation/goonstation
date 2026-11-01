/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import type {
  ExpiryOptions,
  ExpiryType,
  PollSettings,
} from './common/forms/PollEditorForm';
import { PollEditorForm } from './common/forms/PollEditorForm';

interface PollEditorPanelData {
  lastError: string | null;
  serverOptions: string[];
}

interface PollEditorPanelState {
  currentSettings: PollSettings;
  currentOptions: string[];
  validationWarning: string | undefined;
}

interface SavePayload {
  alertPlayers: boolean;
  expiryType: ExpiryType;
  expiryValue: string;
  multipleChoice: boolean;
  options: string[];
  servers: string;
  title: string;
}

const createNewOptions = () => ['', ''];

const processExpiry = (expiry: ExpiryOptions): ExpiryOptions => ({
  ...expiry,
  expiryValue: expiry.expiryValue?.trim(),
});
const processSettings = (settings: PollSettings) => {
  const { expiry, title } = settings;
  const processedExpiry = processExpiry(expiry);
  return {
    ...settings,
    title: title.trim(),
    expiry: processedExpiry,
  };
};
const processOptions = (options: string[]) =>
  options.map((option) => option.trim()).filter((option) => !!option);

// rough yyyy-mm-dd checker, does not check for out-of-range days in shorter months
const timestampRegex = /^\d{4}-[01]\d-[0-3]\d$/;
const validateTimestamp = (timestamp: string) => {
  if (!timestamp.match(timestampRegex)) {
    return 'yyyy-mm-dd format required.';
  }
  return undefined;
};
const validate = (settings: PollSettings, options: string[]) => {
  if (!settings.title) {
    return 'Poll title is required.';
  }
  if (!settings.expiry?.expiryType) {
    return 'Expiry setting is required.';
  }
  if (settings.expiry.expiryType !== 'never') {
    if (settings.expiry.expiryValue === '') {
      return 'Additional expiry information is required.';
    }
    if (settings.expiry.expiryType === 'timestamp') {
      const timestampValidation = validateTimestamp(
        settings.expiry.expiryValue,
      );
      if (timestampValidation) {
        return timestampValidation;
      }
    } else if (settings.expiry.expiryValue === '0') {
      return 'Non-zero expiry time is required.';
    }
  }
  if (!settings.servers) {
    return 'Server setting is required.';
  }
  if (options.length < 2) {
    return 'At least 2 options are required.';
  }
  return undefined;
};

/*
 * N.B. On creation, this form was built to handle creating polls, with intent to expand
 * to editing them at a later date.
 *
 * In its initial state it is only wired up for creating polls.
 */

export const PollEditorPanel = () => {
  const { act, data } = useBackend<PollEditorPanelData>();
  const { lastError, serverOptions } = data;

  // TODO: pull from data for edit
  const initialSettings: PollSettings = {
    expiry: { expiryType: undefined, expiryValue: '' },
    multipleChoice: false,
    alertPlayers: false,
    servers: undefined,
    title: '',
  };
  const initialOptions = createNewOptions();

  const [state, setState] = useLocalState<PollEditorPanelState>('state', {
    currentOptions: initialOptions,
    currentSettings: initialSettings,
    validationWarning: undefined,
  });
  const { currentOptions, currentSettings, validationWarning } = state;

  const handleOptionsChange = (newOptions: string[]) =>
    setState({
      ...state,
      currentOptions: newOptions,
      validationWarning: undefined,
    });

  const handleSettingsUpdate = (update: Partial<PollSettings>) =>
    setState({
      ...state,
      currentSettings: {
        ...state.currentSettings,
        ...update,
      },
      validationWarning: undefined,
    });

  const handleReset = () =>
    setState({
      ...state,
      currentOptions: initialOptions,
      currentSettings: initialSettings,
      validationWarning: undefined,
    });

  const handleSave = () => {
    const processedSettings = processSettings(currentSettings);
    const processedOptions = processOptions(currentOptions);
    const newValidationWarning = validate(processedSettings, processedOptions);
    setState({
      ...state,
      validationWarning: newValidationWarning,
    });
    if (!newValidationWarning) {
      const payload: SavePayload = {
        alertPlayers: processedSettings.alertPlayers,
        expiryType: processedSettings.expiry.expiryType!,
        expiryValue: processedSettings.expiry.expiryValue,
        multipleChoice: processedSettings.multipleChoice,
        options: processedOptions,
        servers: processedSettings.servers!,
        title: processedSettings.title,
      };
      act('save', payload);
    }
  };

  return (
    <Window title="Create Poll" width={440} height={440}>
      <Window.Content>
        <Stack fill vertical>
          <PollEditorForm
            currentSettings={currentSettings}
            currentOptions={currentOptions}
            onChangeOptions={handleOptionsChange}
            onSettingsUpdate={handleSettingsUpdate}
            serverOptions={serverOptions}
          />
          <Stack.Item>
            <Section title="Actions">
              <Stack vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button icon="refresh" color="bad" onClick={handleReset}>
                        Reset
                      </Button>
                    </Stack.Item>
                    <Stack.Item
                      grow
                      textAlign="right"
                      textColor={validationWarning ? 'average' : 'bad'}
                    >
                      {validationWarning || lastError}
                    </Stack.Item>
                    <Stack.Item>
                      <Button icon="save" color="good" onClick={handleSave}>
                        Create Poll
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
