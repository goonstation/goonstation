import { isEscape, KEY } from 'tgui-core/keys';

const DOM_KEY_LOCATION_NUMPAD = 3;
const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  ARROWDOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  ARROWLEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  ARROWRIGHT: 'East',
  ' ': 'Space',
  ARROWUP: 'North',
};
export const isStandardKey = (event: React.KeyboardEvent): boolean => {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
};

export const formatKeyboardEvent = (event: React.KeyboardEvent): string => {
  let text = '';
  let isModifier = false;

  if (event.altKey) {
    text += 'Alt';
    isModifier = true;
  }

  if (event.ctrlKey) {
    text += 'Ctrl';
    isModifier = true;
  }

  if (event.shiftKey) {
    text += 'Shift';
    isModifier = true;
  }

  if (isStandardKey(event) && isModifier) {
    text += '+';
  }

  if (event.location === DOM_KEY_LOCATION_NUMPAD) {
    text += 'Numpad';
  }

  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }

  return text;
};
