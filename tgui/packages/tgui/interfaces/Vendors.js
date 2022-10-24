import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Section, Table } from 'tgui/components';
import { Collapsible, Divider, Flex, LabeledList, Stack } from '../components';

export const Vendors = (props, context) => {
  const { act, data } = useBackend(context);
  const wiresList = data.wiresList || [];
  const productList = data.productList || [];
  const indicators = data.lightColors || [];

  const {
    windowName,
    wiresOpen,
    cash,
    bankMoney,
    requiresMoney,
    cardname,
    playerBuilt,
    name,
    owner,
    unlocked,
    loading,
  } = data;

  const canVend = (a) => (
    ((((a.cost <= cash) || (a.cost <= bankMoney)) || !requiresMoney) && (a.amount > 0))
  );
  const getCost = (a) => (
    (((a.cost) && requiresMoney) ? `$${a.cost}` : "Free")
  );

  return (
    <Window
      title={windowName}
      width="350"
      fontFamily="Consolas"
      font-size="10pt"
      height="400">
      <Window.Content>
        <Stack vertical fill minHeight="1%" maxHeight="100%">

          {wiresOpen && (
            <Stack.Item>

              <Collapsible
                mb="1%"
                title="Wire Panel">

                {wiresOpen && wiresList.map(wire => {
                  return (
                    <Flex key={wire.name} textColor={wire.color}>
                      <Flex.Item grow bold>
                        {wire.name}
                      </Flex.Item>
                      <Flex.Item mr="5%">
                        <Button
                          ml="10%"
                          my="1%"
                          content="Pulse"
                          onClick={() => act('pulsewire', {
                            wire: wire.name })}
                        />
                      </Flex.Item>
                      <Flex.Item>
                        <Button
                          m="1%"
                          content={wire.uncut ? "Cut" : "Mend"}
                          onClick={() => act(wire.uncut ? 'cutwire' : "mendwire", {
                            wire: wire.name })}
                        />
                      </Flex.Item>
                    </Flex>
                  );
                })}

                <Divider />
                {playerBuilt && (
                  <>
                    <Button content={`Owner: ${owner} (${unlocked ? "Unlocked" : "Locked"})`} onClick={() => act("togglelock")} />
                    <Button content="Loading Chute" disabled={!unlocked} color={loading ? "green" : "red"} onClick={() => act("togglechute")} />
                    <Button.Input content={name} defaultValue={name} onCommit={(e, value) => act("rename", { name: value })} />
                  </>
                )}
                <Flex justify="space-between" align="stretch">
                  <Flex.Item direction="row">
                    <LabeledList>
                      <LabeledList.Item
                        label="AI Control">
                        {indicators.ai_control ? "Enabled" : "Disabled"}
                      </LabeledList.Item>
                      <LabeledList.Item
                        label="Electrification">
                        {indicators.electrified ? "Yes" : "No"}
                      </LabeledList.Item>
                    </LabeledList>
                  </Flex.Item>
                  <Flex.Item direction="row">
                    <LabeledList.Item
                      label="Inventory">
                      {indicators.extendedinventory ? "Expanded" : "Standard"}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Safety Light">
                      {indicators.shootinventory ? "On" : "Off"}
                    </LabeledList.Item>
                  </Flex.Item>
                </Flex>
              </Collapsible>

            </Stack.Item>
          )}

          <Stack.Item grow minHeight="1%" maxHeight="100%">
            <Section fill scrollable height="100%">
              {productList.map(product => {
                return (
                  <>
                    <Table direction="row" align="center" key={product}>
                      <Table.Row>
                        <Table.Cell collapsing>
                          {product.img && (<img
                            src={`data:image/png;base64,${product.img}`}
                            style={{
                              'vertical-align': 'middle',
                              'horizontal-align': 'middle',
                            }}
                          />)}
                        </Table.Cell>
                        <Table.Cell>
                          <Box bold>
                            {product.name}
                            {(playerBuilt && wiresOpen) && <Button
                              ml="1%"
                              color="green"
                              icon="images"
                              onClick={() => act('setIcon', { target: product.path })}
                            />}
                          </Box>
                          <Box italic>
                            {`Quantity: ${product.amount}`}
                          </Box>
                        </Table.Cell>
                        <Table.Cell bold textAlign="right">
                          {(playerBuilt && unlocked) ? <Button.Input
                            color={canVend(product) ? "green" : "grey"}
                            content={getCost(product)}
                            onCommit={(e, value) => act('setPrice', { target: product.path, cost: value })}
                          /> : <Button
                            color={canVend(product) ? "green" : "grey"}
                            content={getCost(product)}
                            disabled={canVend(product) ? false : true}
                            onClick={() => act('vend', {
                              target: product.path, cost: product.cost, amount: product.amount })}
                          />}
                        </Table.Cell>
                      </Table.Row>
                    </Table>
                    <Divider />
                  </>
                );
              })}
            </Section>
          </Stack.Item>
          {requiresMoney > 0 && (
            <Stack.Item>
              <Table font-size="9pt" direction="row">
                <Table.Row>
                  <Table.Cell bold>
                    {cardname && (
                      <Button icon="id-card"
                        mr="100%"
                        content={cardname ? cardname : ""}
                        onClick={() => act('logout')}
                      />
                    )}
                    {(cardname && bankMoney >= 0) && ("Money on account: $" + bankMoney)}
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold direction="row">
                    {(cash > 0) && ("Cash: $" + cash)}
                    {(cash > 0 && cash) && (
                      <Button icon="eject"
                        ml="1%"
                        content={"eject"}
                        onClick={() => act('returncash')} />
                    )}
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );

};
