/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Input, LabeledList, Section } from 'tgui-core/components';

import { useSharedState } from '../backend';

export const meta = {
  title: 'Themes',
  render: () => <Story />,
};

const Story = () => {
  const [theme, setTheme] = useSharedState<string | undefined>(
    'kitchenSinkTheme',
    undefined,
  );
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={theme}
            onInput={(_e, value) => setTheme(value)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
