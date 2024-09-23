/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Box, Button, Divider, Knob, LabeledList } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../../backend';
import { Modal } from '../../../components';
import type { GeneTekData } from '../type';

export const BuyMaterialsModal = (props) => {
  const { data, act } = useBackend<GeneTekData>();
  const [buyMats, setBuyMats] = useSharedState('buymats', 0);
  const maxBuyMats = props.maxAmount;
  const { budget, costPerMaterial } = data;

  const resolvedBuyMats = Math.min(buyMats, maxBuyMats);

  return (
    <Modal full>
      <Box position="relative" width={18}>
        <Box position="absolute" right={1} top={0}>
          <Knob
            inline
            value={resolvedBuyMats}
            onChange={(_e, value) => setBuyMats(value)}
            minValue={1}
            maxValue={maxBuyMats}
          />
        </Box>
        <LabeledList>
          <LabeledList.Item label="Purchase">
            {resolvedBuyMats}
            {resolvedBuyMats === 1 ? ' Material' : ' Materials'}
          </LabeledList.Item>
          <LabeledList.Item label="Budget">
            {`${budget} Credits`}
          </LabeledList.Item>
          <LabeledList.Item label="Cost">
            {`${resolvedBuyMats * costPerMaterial} Credits`}
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Remainder">
            <Box
              inline
              color={budget - resolvedBuyMats * costPerMaterial < 0 && 'bad'}
            >
              {budget - resolvedBuyMats * costPerMaterial}
            </Box>
            {' Credits'}
          </LabeledList.Item>
        </LabeledList>
        <Divider hidden />
        <Box inline width="50%" textAlign="center">
          <Button
            color="good"
            icon="dollar-sign"
            disabled={resolvedBuyMats <= 0}
            onClick={() => {
              act('purchasematerial', { amount: resolvedBuyMats });
              setBuyMats(0);
            }}
          >
            Submit
          </Button>
        </Box>
        <Box inline width="50%" textAlign="center">
          <Button color="bad" icon="times" onClick={() => setBuyMats(0)}>
            Cancel
          </Button>
        </Box>
      </Box>
    </Modal>
  );
};
