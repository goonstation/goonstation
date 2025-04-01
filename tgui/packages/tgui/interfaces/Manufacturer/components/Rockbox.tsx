import { useCallback } from 'react';
import { Box, Button, Divider, LabeledList } from 'tgui-core/components';

import { ErrorBoundary } from '../../common/ErrorBoundary';
import { RockboxStyle } from '../constant';
import type { OreData, RockboxData } from '../type';

interface RockboxProps {
  data: RockboxData;
  onPurchase: (rockboxRef: string, oreName: string) => void;
}

export const Rockbox = (props: RockboxProps) => {
  const { data, onPurchase } = props;
  const { area_name, byondRef, ores } = data;
  const handlePurchase = useCallback(
    (oreName: string) => onPurchase(byondRef, oreName),
    [byondRef, onPurchase],
  );
  return (
    <Box>
      <Box mt={RockboxStyle.MarginTop} textAlign="left" bold>
        {area_name}
        <Divider />
      </Box>

      <LabeledList>
        {ores?.length
          ? ores.map((ore) => (
              <ErrorBoundary
                key={ore.name}
                FallbackComponent={FallbackRockboxItem}
              >
                <RockboxItem ore={ore} onPurchase={handlePurchase} />
              </ErrorBoundary>
            ))
          : 'No Ores Loaded.'}
      </LabeledList>
    </Box>
  );
};

const formatAmount = (amount: number) =>
  amount.toString().padStart(5, '\u2007');

interface RockboxItemProps {
  onPurchase: (oreName: string) => void;
  ore: OreData;
}

const RockboxItem = (props: RockboxItemProps) => {
  const { onPurchase, ore } = props;
  return (
    <LabeledList.Item
      label={ore.name}
      textAlign="center"
      buttons={
        <Button
          key={ore.name}
          textAlign="center"
          onClick={() => onPurchase(ore.name)}
        >
          {ore.cost}⪽
        </Button>
      }
    >
      {formatAmount(ore.amount)}
    </LabeledList.Item>
  );
};

const FallbackRockboxItem = () => (
  <LabeledList.Item label="[Unknown]" textAlign="right">
    ???
  </LabeledList.Item>
);
