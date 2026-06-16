import { useBackend } from 'tgui/backend';
import { resource } from 'tgui/goonstation/cdn';
import { Window } from 'tgui/layouts';
import { Image } from 'tgui-core/components';

import { ResourceImageProps } from './type';

export const ResourceImage = () => {
  const { data } = useBackend<ResourceImageProps>();
  const { title, fixed_size, path, scaled } = data;
  const scale_style = scaled ? { width: '100%', height: 'auto' } : {};
  return (
    <Window
      title={title}
      width={fixed_size.width}
      height={fixed_size.height + (scaled ? 0 : 32)}
      theme="paper"
    >
      <Window.Content>
        <Image
          fixBlur={!scaled}
          style={{ position: 'absolute', top: 0, left: 0, ...scale_style }}
          src={resource(path)}
        />
      </Window.Content>
    </Window>
  );
};
