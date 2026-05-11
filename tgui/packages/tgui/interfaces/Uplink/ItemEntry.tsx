/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  Box,
  Button,
  Dimmer,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, pluralize } from 'tgui-core/string';

import { useBackend, useSharedState } from '../../backend';
import type { EnvironmentProps, ItemData, UplinkData } from './type';

const THUMBNAIL_SIZE = '32px';

const buildPurchaseText = (
  purchased: boolean,
  cost: number,
  currency_amount: number,
  currency_name: string,
) => {
  if (purchased) {
    return 'Purchased';
  } else if (cost > currency_amount) {
    return `Not enough ${currency_name}s`;
  }
  return `Purchase for ${cost} ${pluralize(capitalizeAll(currency_name), cost)}`;
};

interface ItemProps extends EnvironmentProps {
  item: ItemData;
}

// needed to standardize a button within the `title` prop of a `Section` component
const titleButtonResetProps = {
  style: { fontWeight: 'normal' },
};

export const ItemEntry = (props: ItemProps) => {
  const { act } = useBackend<UplinkData>();
  const { item, isVr, currency_amount, currency_name } = props;
  const { name, desc, cooldown, cost, icon, vr_allowed } = item;
  const [purchased, setPurchased] = useSharedState(name + '-purchased', false);

  const title = (
    <Stack align="center">
      {!!icon && (
        <Stack.Item height={THUMBNAIL_SIZE}>
          <Image
            height={THUMBNAIL_SIZE}
            width={THUMBNAIL_SIZE}
            src={`data:image/png;base64,${icon}`}
          />
        </Stack.Item>
      )}
      <Stack.Item grow>{name}</Stack.Item>
      <Stack.Item>
        <Button
          {...titleButtonResetProps}
          color="good"
          disabled={currency_amount < cost || purchased}
          onClick={() => {
            setPurchased(true);
            act('purchase', { item: name });
          }}
        >
          {buildPurchaseText(purchased, cost, currency_amount, currency_name)}
        </Button>
      </Stack.Item>
    </Stack>
  );
  return (
    <Stack.Item position="relative">
      {isVr && !vr_allowed && (
        <Dimmer>
          <Box fontSize={1.5} backgroundColor="#384e68">
            Unavailable in VR
          </Box>
        </Dimmer>
      )}
      <Section title={title}>
        <LabeledList>
          {cooldown && (
            <LabeledList.Item label="Cooldown">{`${cooldown} seconds`}</LabeledList.Item>
          )}
          <LabeledList.Item label="Description">{desc}</LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};
