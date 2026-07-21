/**
 * @file
 * @copyright 2026
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */
import { Collapsible, LabeledList, Section } from 'tgui-core/components';

import { DisplayOccupiedProps, ImplantData } from './type';

type DisplayImplantsProps = DisplayOccupiedProps & {
  implants: ImplantData[] | null;
};

export const DisplayImplants = (props: DisplayImplantsProps) => {
  const { occupied, implants } = props;
  return (
    <Collapsible
      title="Embedded Implants"
      open
      color={!occupied && 'grey'}
      sideIcon="thermometer"
    >
      <Section>
        {!occupied && 'No Patient Detected.'}
        {!!occupied && (
          <>
            {!implants && 'No Implants Detected.'}
            {!!implants && implants.length === 0 && 'No Implants Detected.'}
            {!!implants && implants.length > 0 && (
              <LabeledList>
                {implants.map((implant_data: ImplantData, index) => {
                  return <DisplayImplant key={index} implant={implant_data} />;
                })}
              </LabeledList>
            )}
          </>
        )}
      </Section>
    </Collapsible>
  );
};

interface DisplayImplantProps {
  implant: ImplantData;
}

export const DisplayImplant = (props: DisplayImplantProps) => {
  const { implant } = props;
  return (
    <LabeledList.Item label={implant.implant_name}>
      {implant.implant_count}
    </LabeledList.Item>
  );
};
