/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Input, LabeledList, Section } from 'tgui-core/components';

// todo doesn't work

export const meta = {
  title: 'Themes',
  render: (
    theme: string,
    setTheme: (value: React.SetStateAction<string>) => void,
  ) => <Story theme={theme} setTheme={setTheme} />,
};

function Story(props: {
  readonly theme: string;
  readonly setTheme: (value: React.SetStateAction<string>) => void;
}) {
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={props.theme}
            onChange={(value) => props.setTheme(value)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}
