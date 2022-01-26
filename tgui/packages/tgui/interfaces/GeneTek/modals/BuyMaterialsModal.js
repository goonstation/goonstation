/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { useBackend, useSharedState } from "../../../backend";
import { Box, Button, Divider, Knob, LabeledList, Modal } from "../../../components";

export const BuyMaterialsModal = (props, context) => {
  const { data, act } = useBackend(context);
  const [buyMats, setBuyMats] = useSharedState(context, "buymats", null);
  const maxBuyMats = props.maxAmount;
  const {
    budget,
    costPerMaterial,
  } = data;

  const resolvedBuyMats = Math.min(buyMats, maxBuyMats);

  return (
    <Modal full>
      <Box
        position="relative"
        width={18}>
        <Box
          position="absolute"
          right={1}
          top={0}>
          <Knob
            inline
            value={resolvedBuyMats}
            onChange={(e, value) => setBuyMats(value)}
            minValue={1}
            maxValue={maxBuyMats} />
        </Box>
        <LabeledList>
          <LabeledList.Item label="Purchase">
            {resolvedBuyMats}
            {resolvedBuyMats === 1 ? " Material" : " Materials"}
          </LabeledList.Item>
          <LabeledList.Item label="Budget">
            {`${budget} Credits`}
          </LabeledList.Item>
          <LabeledList.Item label="Cost">
            {`${resolvedBuyMats * costPerMaterial} Credits`}
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Remainder">
            <Box inline color={budget - resolvedBuyMats * costPerMaterial < 0 && "bad"}>
              {budget - resolvedBuyMats * costPerMaterial}
            </Box>
            {" Credits"}
          </LabeledList.Item>
        </LabeledList>
        <Divider hidden />
        <Box inline width="50%" textAlign="center">
          <Button
            color="good"
            icon="dollar-sign"
            disabled={resolvedBuyMats <= 0}
            onClick={() => {
              act("purchasematerial", { amount: resolvedBuyMats });
              setBuyMats(null);
            }}>
            Submit
          </Button>
        </Box>
        <Box inline width="50%" textAlign="center">
          <Button
            color="bad"
            icon="times"
            onClick={() => setBuyMats(null)}>
            Cancel
          </Button>
        </Box>
      </Box>
    </Modal>
  );
};
