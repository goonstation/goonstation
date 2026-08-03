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

import { useBackend } from '../../backend';
import type { EnvironmentProps, ItemData, UplinkData } from './type';

const THUMBNAIL_SIZE = '32px';

const buildPurchaseText = (
  purchased: number,
  purchase_limit: number,
  cost: number,
  currency_amount: number,
  currency_name: string,
) => {
  if (purchased > 0 && purchase_limit === 1) {
    return 'Purchased';
  } else if (purchase_limit < Infinity && purchased >= purchase_limit) {
    return `Purchase limit reached`;
  } else if (cost > currency_amount) {
    return `Not enough ${currency_name}s`;
  }
  return `Purchase for ${cost} ${pluralize(capitalizeAll(currency_name), cost)}`;
};

interface ItemProps extends EnvironmentProps {
  item: ItemData;
  purchased: number;
}

// needed to standardize a button within the `title` prop of a `Section` component
const titleButtonResetProps = {
  style: { fontWeight: 'normal' },
};

export const ItemEntry = (props: ItemProps) => {
  const { act } = useBackend<UplinkData>();
  const { item, isVr, currency_amount, currency_name, purchased } = props;
  const { name, desc, cooldown, cost, icon, vr_allowed, ref, purchase_limit } =
    item;

  const title = (
    <Stack align="center">
      {!!icon && (
        <Stack.Item height={THUMBNAIL_SIZE}>
          <Image height={THUMBNAIL_SIZE} width={THUMBNAIL_SIZE} src={icon} />
        </Stack.Item>
      )}
      <Stack.Item grow>{name}</Stack.Item>
      <Stack.Item>
        <Button
          {...titleButtonResetProps}
          color="good"
          disabled={
            currency_amount < cost ||
            (purchase_limit < Infinity && purchased >= purchase_limit)
          }
          onClick={() => {
            act('purchase', { item_ref: ref });
          }}
        >
          {buildPurchaseText(
            purchased,
            purchase_limit,
            cost,
            currency_amount,
            currency_name,
          )}
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
          {purchase_limit < Infinity && (
            <LabeledList.Item label="Purchase Limit">{`${purchased}/${purchase_limit}`}</LabeledList.Item>
          )}
          <LabeledList.Item label="Description">
            <Box dangerouslySetInnerHTML={{ __html: desc }} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};
