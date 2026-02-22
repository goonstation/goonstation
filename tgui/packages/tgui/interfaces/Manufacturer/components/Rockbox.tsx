import { Box, Button, Divider, LabeledList } from 'tgui-core/components';

import { RockboxStyle } from '../constant';
import type { RockboxData } from '../type';

interface RockboxProps {
  data: RockboxData;
  onPurchase: (rockboxRef: string, oreName: string) => void;
}

export const Rockbox = (props: RockboxProps) => {
  const { data, onPurchase } = props;
  const { area_name, byondRef, ores } = data;
  return (
    <Box>
      <Box mt={RockboxStyle.MarginTop} textAlign="left" bold>
        {area_name}
        <Divider />
      </Box>

      <LabeledList>
        {ores?.length
          ? ores.map((ore) => (
              <LabeledList.Item
                key={ore.name}
                label={ore.name}
                textAlign="center"
                buttons={
                  <Button
                    key={ore.name}
                    textAlign="center"
                    onClick={() => onPurchase(byondRef, ore.name)}
                  >
                    {ore.cost}⪽
                  </Button>
                }
              >
                {ore.amount.toString().padStart(5, '\u2007')}
              </LabeledList.Item>
            ))
          : 'No Ores Loaded.'}
      </LabeledList>
    </Box>
  );
};
