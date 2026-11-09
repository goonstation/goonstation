/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import {
  Collapsible,
  ColorBox,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { DisplayOccupiedProps } from './type';

type DisplayMiscellaneousDetailsProps = DisplayOccupiedProps & {
  age: number;
  blood_type: string;
  blood_color_value: string;
  blood_color_name: string;
};

export const DisplayMiscellaneousDetails = (
  props: DisplayMiscellaneousDetailsProps,
) => {
  const { occupied, age, blood_type, blood_color_value, blood_color_name } =
    props;

  return (
    <Collapsible
      open
      sideIcon="question"
      title="Miscellaneous Information"
      color={!occupied && 'grey'}
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <LabeledList>
            <LabeledList.Item label="Age">{age}</LabeledList.Item>
            <LabeledList.Item label="Blood Type">{blood_type}</LabeledList.Item>
            <LabeledList.Item label="Blood Color">
              <ColorBox color={blood_color_value} content=" " />{' '}
              <span>{blood_color_name}</span>
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </Collapsible>
  );
};
