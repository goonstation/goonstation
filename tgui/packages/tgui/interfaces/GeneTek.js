/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { useBackend, useSharedState } from "../backend";
import { Box, Button, Divider, Flex, Icon, LabeledList, NoticeBox, ProgressBar, Tabs, TimeDisplay } from "../components";
import { Window } from "../layouts";
import { BuyMaterialsModal, CombineGenesModal, MutationsTab, RecordTab, ResearchTab, ScannerTab, StorageTab } from "./GeneTek/index";

const formatSeconds = v => v > 0 ? (v / 10).toFixed(0) + "s" : "Ready";

export const GeneTek = (props, context) => {
  const { data, act } = useBackend(context);
  const [menu, setMenu] = useSharedState(context, "menu", "research");
  const [buyMats, setBuyMats] = useSharedState(context, "buymats", null);
  const [isCombining] = useSharedState(context, "iscombining", false);
  const {
    materialCur,
    materialMax,
    currentResearch,
    equipmentCooldown,
    subject,
    costPerMaterial,
    budget,
    record,
    scannerAlert,
    scannerError,
    allowed,
  } = data;

  const {
    name,
    stat,
    health,
    stability,
  } = subject || {};

  const maxBuyMats = Math.min(
    materialMax - materialCur,
    Math.floor(budget / costPerMaterial),
  );

  return (
    <Window
      theme={allowed ? "genetek" : "genetek-disabled"}
      width={730}
      height={415}>
      <Flex height="100%">
        <Flex.Item
          width="245px"
          height="100%"
          style={{ "padding": "5px 5px 5px 5px" }}>
          <Flex
            direction="column"
            height="100%">
            {!allowed && (
              <>
                <div style={{ "color": "#ff3333", "text-align": "center" }}>
                  Insufficient access to interact.
                </div>
                <Divider />
              </>
            )}
            <Flex>
              <ProgressBar
                value={materialCur}
                maxValue={materialMax}
                mb={1}>
                <Box position="absolute" bold>Materials</Box>
                {materialCur}
                {" / "}
                {materialMax}
              </ProgressBar>
              <Flex.Item grow={0} shrink={0} ml={1}>
                <Button
                  circular
                  compact
                  icon="dollar-sign"
                  disabled={maxBuyMats <= 0}
                  onClick={() => setBuyMats(1)} />
              </Flex.Item>
            </Flex>
            {subject && (
              <LabeledList>
                <LabeledList.Item label="Occupant">
                  {name}
                </LabeledList.Item>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    ranges={{
                      bad: [-Infinity, 0.15],
                      average: [0.15, 0.75],
                      good: [0.75, Infinity],
                    }}
                    value={health}>
                    {stat < 2 ? health <= 0 ? (
                      <Box color="bad">
                        <Icon name="exclamation-triangle" />
                        {" Critical"}
                      </Box>
                    ) : (health * 100).toFixed(0) + "%" : (
                      <Box>
                        <Icon name="skull" />
                        {" Deceased"}
                      </Box>
                    )}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Stability">
                  <ProgressBar
                    ranges={{
                      bad: [-Infinity, 15],
                      average: [15, 75],
                      good: [75, Infinity],
                    }}
                    value={stability}
                    maxValue={100} />
                </LabeledList.Item>
              </LabeledList>
            )}
            <Divider />
            <Flex.Item grow={1} style={{ overflow: "hidden" }}>
              {currentResearch.map(r => (
                <ProgressBar
                  key={r.ref}
                  value={r.total - r.current}
                  maxValue={r.total}
                  mb={1}>
                  <Box position="absolute">
                    {r.name}
                  </Box>
                  <TimeDisplay
                    timing
                    value={r.current}
                    format={formatSeconds}
                  />
                </ProgressBar>
              ))}
            </Flex.Item>
            {!!scannerAlert && (
              <NoticeBox info={!scannerError} danger={!!scannerError}>
                {scannerAlert}
              </NoticeBox>
            )}
            <Divider />
            <LabeledList>
              {equipmentCooldown.map(e => (
                <LabeledList.Item key={e.label} label={e.label}>
                  {e.cooldown < 0 ? "Ready" : (
                    <TimeDisplay
                      timing
                      value={e.cooldown}
                      format={formatSeconds}
                    />
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Flex>
        </Flex.Item>
        <Window.Content scrollable>
          <Flex.Item>
            <Box ml="250px">
              <Tabs>
                <Tabs.Tab
                  icon="flask"
                  selected={menu === "research"}
                  onClick={() => setMenu("research")}>
                  Research
                </Tabs.Tab>
                <Tabs.Tab
                  icon="radiation"
                  selected={menu === "mutations"}
                  onClick={() => setMenu("mutations")}>
                  Mutations
                </Tabs.Tab>
                <Tabs.Tab
                  icon="server"
                  selected={menu === "storage" || (!record && menu === "record")}
                  onClick={() => setMenu("storage")}>
                  Storage
                </Tabs.Tab>
                {!!record && (
                  <Tabs.Tab
                    icon="save"
                    selected={menu === "record"}
                    onClick={() => setMenu("record")}
                    rightSlot={menu === "record" && (
                      <Button
                        circular
                        compact
                        color="transparent"
                        icon="times"
                        onClick={() => act("clearrecord")} />
                    )}>
                    Record
                  </Tabs.Tab>
                )}
                {subject && (
                  <Tabs.Tab
                    icon="dna"
                    selected={menu === "scanner"}
                    onClick={() => setMenu("scanner")}>
                    Scanner
                  </Tabs.Tab>
                )}
              </Tabs>
              {buyMats !== null && <BuyMaterialsModal maxAmount={maxBuyMats} />}
              {!!isCombining && <CombineGenesModal />}
              {menu === "research" && <ResearchTab maxBuyMats={maxBuyMats} setBuyMats={setBuyMats} />}
              {menu === "mutations" && <MutationsTab />}
              {menu === "storage" && <StorageTab />}
              {menu === "record" && (record ? <RecordTab /> : <StorageTab />)}
              {menu === "scanner" && <ScannerTab />}
            </Box>
          </Flex.Item>
        </Window.Content>
      </Flex>
    </Window>
  );
};
