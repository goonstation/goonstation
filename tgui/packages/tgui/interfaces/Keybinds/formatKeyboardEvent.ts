import { isEscape, KEY } from 'tgui-core/keys';

const DOM_KEY_LOCATION_NUMPAD = 3;
const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  SPACEBAR: 'Space',
  UP: 'North',
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

  if (event.altKey) {
    text += 'Alt+';
  }

  if (event.ctrlKey) {
    text += 'Ctrl+';
  }

  if (event.shiftKey) {
    text += 'Shift+';
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
