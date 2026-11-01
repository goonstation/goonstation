/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatMoney } from '../../format';
import { SupplyConsoleData } from './type';

export const SupplyConsoleRequisitionsTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  const interference = data.signal_loss >= 75;
  return (
    <Section title="Open Requisition Contracts" scrollable fill>
      <Stack vertical fill>
        <Stack.Item>
          <RequisitionGuide />
        </Stack.Item>
        {interference && (
          <Stack.Item>
            <Divider />
            <Box
              textAlign="center"
              fontSize={2}
              p="10px"
              style={{ borderRadius: '4px' }}
              backgroundColor="red"
              textColor="white"
            >
              <Icon name="wifi" /> Severe signal interference is preventing a
              connection to requisition hub.
            </Box>
            <Divider />
          </Stack.Item>
        )}
        {!interference && (
          <Stack.Item>
            {data.requisition_data.map((requisition, index) => (
              <RequisitionEntry
                requisition={requisition}
                interference={interference}
                key={index}
              />
            ))}
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const RequisitionEntry = (props) => {
  const { act } = useBackend<SupplyConsoleData>();
  const { requisition } = props;
  return (
    <Section
      className="candystripe"
      title={requisition.name}
      buttons={[
        !requisition.urgent && (
          <Button
            key="pinbutton"
            icon={requisition.pinned ? 'thumbtack-slash' : 'thumbtack'}
            color={requisition.pinned ? 'bad' : 'good'}
            iconColor="white"
            tooltip={requisition.pinned ? 'Unpin Contract' : 'Pin Contract'}
            onClick={() => act('requisition_pin', { ref: requisition.ref })}
          />
        ),
        <Button
          key="listbutton"
          icon="print"
          tooltip={'Print List'}
          onClick={() => act('requisition_print', { ref: requisition.ref })}
        />,
        <Button
          key="barcodebutton"
          icon="barcode"
          tooltip={'Print Barcode'}
          onClick={() =>
            act('requisition_print', { ref: requisition.ref, type: 'barcode' })
          }
        />,
      ]}
    >
      <Stack vertical>
        {!!requisition.urgent && (
          <NoticeBox danger inline>
            <b>URGENT</b> - Cannot be reserved. <br />
            Contract leaves market{' '}
            {requisition.cycles_left
              ? `in ${requisition.cycles_left + 1} cycles.`
              : 'next cycle.'}
          </NoticeBox>
        )}
        <Stack.Item>
          <BlockQuote>
            <Box
              dangerouslySetInnerHTML={{
                __html: `${requisition.flavor_desc}`,
              }}
            />
          </BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item width="50%">
              <b>Requested Items:</b>
              <Box
                dangerouslySetInnerHTML={{
                  __html: `${requisition.desc}`,
                }}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <b>Requisition Code: </b>
              {requisition.req_code}
              <br />
              <b>Contract Reward: </b>
              {formatMoney(requisition.payout)}⪽<br />
              {!!requisition.item_rewards.length && <b>Item Rewards: </b>}
              <Table>
                {requisition.item_rewards.map((reward, index) => (
                  <Table.Row key={index} className="candystripe">
                    {(reward.count ?? 1) + 'x ' + reward.name}
                  </Table.Row>
                ))}
              </Table>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Divider />
    </Section>
  );
};

const RequisitionGuide = () => {
  return (
    <BlockQuote>
      To fulfill these contracts, send full requested complement of items with
      the contract&apos;s Requisitions tag.
      <br />
      Items packed for requisition can be validated with a standard cargo
      appraiser.
      <br />
      <b>
        Before shipping crate, ensure correct label is applied.
        <br />
      </b>
      Insufficient or extra items will be returned to you.
      <br /> Most contracts may be &quot;pinned&quot;, which reserves them for
      your use, even through market shifts.
      <br /> When fulfilling third-party contracts, you must send the included
      requisition sheet; please be aware third-party returns are at
      clients&apos; discretion and your shipment may not be returned if
      insufficient.
    </BlockQuote>
  );
};
