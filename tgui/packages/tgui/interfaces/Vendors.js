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
    acceptCard,
    requiresMoney,
    cardname,
    playerBuilt,
  } = data;

  return (
    <Window
      title={windowName}
      width="400"
      fontFamily="Consolas"
      font-size="10pt"
      height="600">
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
                          content="Pulse"
                          onClick={() => act('pulsewire', {
                            wire: wire.name })}
                        />
                      </Flex.Item>
                      <Flex.Item>
                        <Button
                          ml="1%"
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
                    <Button content={"Owner: "+ownerID} onClick={() => act("togglelock")} />
                    <Button content="Unlock" onClick={() => act("togglelock")} />
                    <Button content="Loading Chute" onClick={() => act("togglechute")} />
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
                          </Box>
                          <Box italic>
                            {`Quantity: ${product.amount}`}
                          </Box>
                        </Table.Cell>
                        <Table.Cell bold textAlign="right">
                          <Button
                            color={product.amount > 0 && ((product.cost <= cash) || (product.cost <= bankMoney)) ? "green" : "grey"}
                            content={(product.cost ? "$" + product.cost : "Free")}
                            disabled={(product.amount < 1) || ((product.cost > cash) && (product.cost > bankMoney))}
                            onClick={() => act('vend', {
                              target: product.path, cost: product.cost, amount: product.amount })}
                          />
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
                      <Button icon="cash"
                        ml="1%"
                        content={"eject cash"}
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
