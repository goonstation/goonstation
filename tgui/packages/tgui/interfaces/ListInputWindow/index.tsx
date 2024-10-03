import { getCanvasFont, getTextWidth } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Loader } from '../common/Loader';
import { ListInputModal } from './ListInputModal';

type ListInputData = {
  init_value: string;
  items: string[];
  large_buttons: boolean;
  message: string;
  timeout: number;
  title: string;
  start_with_search: boolean;
  capitalize: boolean;
  theme: string | null;
};

export const ListInputWindow = () => {
  const { act, data } = useBackend<ListInputData>();
  const {
    items = [],
    message = '',
    init_value,
    large_buttons,
    timeout,
    title,
    start_with_search,
    capitalize,
    theme,
  } = data;

  // Dynamically changes the window height based on the message.
  const windowHeight =
    325 + Math.ceil(message.length / 3) + (large_buttons ? 5 : 0);

  // |goonstation-change| autoscaled width feature
  const [windowWidth, setWindowWidth] = useState<number | null>(null);
  if (windowWidth === null) {
    let biggestWidth = 325;
    const font = getCanvasFont();
    for (const item of items) {
      biggestWidth = Math.max(biggestWidth, getTextWidth(item, font) || 0);
    }
    setWindowWidth(biggestWidth);
  }

  // |goonstation-change| theme support
  return (
    <Window
      title={title}
      width={windowWidth || 325}
      height={windowHeight}
      theme={theme ?? 'nanotrasen'}
    >
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <ListInputModal
          items={items}
          default_item={init_value}
          message={message}
          on_selected={(entry) => act('submit', { entry })}
          on_cancel={() => act('cancel')}
          start_with_search={start_with_search}
          capitalize={capitalize}
        />
      </Window.Content>
    </Window>
  );
};
