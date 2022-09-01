/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Box, Button, ColorBox, Flex, LabeledList, ProgressBar, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CyborgDockingStationData } from './type';

export const CyborgDockingStation = (props, context) => {
  const { act, data } = useBackend<CyborgDockingStationData>(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);


  return (
    <Window
      width={500}
      height={640}
      title="Cyborg Docking Station"
      theme={data.occupant.kind === "human" && data.conversion_chamber ? "syndicate" : "neutral"}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item>
            <Tabs vertical width="100px">
              <Tabs.Tab
                selected={tabIndex===1}
                onClick={() => setTabIndex(1)}>
                Occupant
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex===2}
                onClick={() => setTabIndex(2)}>
                Supplies
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            <DockingTabView data={data} act={act} tabIndex={tabIndex} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
const OccupantTab = (props) => {
  const { occupant, fuel, wire, act } = props;
  return (
    <Section title="Occupant">
      <Stack>
        <Stack.Item grow={1}><OccupantTabContents occupant={occupant} act={act} fuel={fuel} wire={wire} /></Stack.Item>
      </Stack>
    </Section>
  );
};
const OccupantTabContents = (props) => {
  const { occupant, fuel, wire, act } = props;
  if (occupant.name) {
    return (
      <>
        <LabeledList>
          <LabeledList.Item label="Name" buttons={(
            <>
              {occupant.kind ==="robot" && <Button onClick={() => act("occupant-rename")} icon="edit" tooltip="Change the occupant's designation" />}
              {<Button onClick={() => act("occupant-eject")} icon="eject" tooltip="Eject the occupant" />}
            </>
          )}>
            {occupant.name}
          </LabeledList.Item>
          <LabeledList.Item label="Type"><OccupantType kind={occupant.kind} user={occupant.user} /></LabeledList.Item>
        </LabeledList>
        <Section title="Status">
          {occupant.kind === "robot" && <OccupantStatusRobot occupant={occupant} fuel={fuel} wire={wire} act={act} />}
          {occupant.kind === "human" && <OccupantStatusHuman occupant={occupant} />}
          {occupant.kind === "eyebot" && <OccupantStatusEyebot occupant={occupant} />}
        </Section>
      </>
    );
  } else {
    return (<div>No occupant</div>);
  }
};
const OccupantStatusRobot = (props) => {
  const { occupant, fuel, wire, act } = props;
  return (
    <>
      <LabeledList>
        <OccupantCellDisplay cellData={occupant.cell} act={act} />
        <LabeledList.Item label="Module" buttons={
          <Button
            onClick={() => act("module-remove")}
            icon="minus"
            tooltip="Remove the occupant's module"
            disabled={!occupant.module} />
        }>
          {occupant.module || <Box as="span" color="red">No Module Installed</Box>}
        </LabeledList.Item>
      </LabeledList>
      <DamageReport parts={occupant.parts} fuel={fuel} wire={wire} act={act} />
      <OccupantUpgradeDisplay
        upgrades={occupant.upgrades}
        upgrades_max={occupant.upgrades_max}
        act={act} />
      <DecorationReport cosmetics={occupant.cosmetics} act={act} />
      <ClothingReport clothes={occupant.clothing} act={act} />
    </>);
};
const OccupantStatusHuman = (props) => {
  const { occupant } = props;
  return (
    <LabeledList>
      <LabeledList.Item label="Converting">
        <ProgressBar
          value={(occupant.max_health - occupant.health) / occupant.max_health}
          ranges={{
            good: [0.5, Infinity],
            average: [0.25, 0.5],
            bad: [-Infinity, 0.25],
          }}
        >
          {Math.floor((occupant.max_health - occupant.health) / occupant.max_health*100)}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );

};
const OccupantStatusEyebot = (props) => {
  const { occupant } = props;
  return (
    <LabeledList>
      <LabeledList.Item label={occupant.cell.name}>{occupant.cell.current} / {occupant.cell.max}</LabeledList.Item>
    </LabeledList>
  );
};
const OccupantType = (props) => {
  const { kind, user } = props;
  switch (kind) {
    case "robot":
      if (user === "brain") return <>Mk.2-Type Cyborg</>;
      if (user === "ai") return <>Mk.2-Type AI Shell</>;
      break;
    case "human":
      return <>Mk.2-Type Carbon</>;
    case "eyebot":
      return <>Mk.1-Type Eyebot</>;
    default:
      return <>Unknown type</>;
  }
};
const ClothingReport = (props) => {
  const { clothes, act } = props;
  return (
    <Section title="Clothing">
      {
        clothes.length > 0
          ?(
            clothes.map(cloth => {
              return (
                <Box key={cloth.ref}>
                  {cloth.name} <Button onClick={() => act("clothing-remove", { clothingRef: cloth.ref })} icon="minus-circle" color="transparent" tooltip="Remove from occupant" />
                </Box>
              );
            })
          )
          :(
            <Box>No Clothing</Box>
          )
      }
    </Section>
  );
};
const DecorationReport = (props) => {
  const { cosmetics, act } = props;
  return (
    <Section title="Decoration">
      <LabeledList>
        <LabeledList.Item label="Head" buttons={
          <Button icon="sync-alt" tooltip="Change head decoration" onClick={() => act("cosmetic-change-head")} />
        }>
          {cosmetics.head || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Chest" buttons={
          <Button icon="sync-alt" tooltip="Change chest decoration" onClick={() => act("cosmetic-change-chest")} />
        }>
          {cosmetics.chest || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Arms" buttons={
          <Button icon="sync-alt" tooltip="Change arms decoration" onClick={() => act("cosmetic-change-arms")} />
        }>{cosmetics.arms || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Legs" buttons={
          <Button icon="sync-alt" tooltip="Change legs decoration" onClick={() => act("cosmetic-change-legs")} />
        }>{cosmetics.legs || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Paint" buttons={
          <>
            {!cosmetics.paint && <Button icon="plus" tooltip="Add paint" onClick={() => act("occupant-paint-add")} />}
            {cosmetics.paint && <Button icon="tint" tooltip="Change colour" onClick={() => act("occupant-paint-change")} />}
            {cosmetics.paint && <Button icon="minus" tooltip="Remove paint" onClick={() => act("occupant-paint-remove")} />}
          </>
        }>
          {cosmetics.paint ? <ColorBox color={cosmetics.paint} /> : "No paint applied"}
        </LabeledList.Item>
        <LabeledList.Item label="Eyes" buttons={
          <Button icon="tint" tooltip="Change eye glow" onClick={() => act("occupant-fx")} />
        }>
          <ColorBox color={"rgb(" + cosmetics.fx[0] + "," + cosmetics.fx[1] + "," + cosmetics.fx[2] + ")"} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
const DamageReport = (props) => {
  const { parts, fuel, wire, act } = props;
  return (
    <Section title="Damage Report" buttons={
      <>
        <Button disabled={fuel < 1} icon="wrench" color="red" tooltip="Fix structural damage" onClick={() => act("repair-fuel")} />
        <Button disabled={wire < 1} icon="fire" color="yellow" tooltip="Fix wiring damage" onClick={() => act("repair-wiring")} />
      </>
    }>
      <LabeledList>
        <PartDisplay label="Head" partData={parts.head} />
        <PartDisplay label="Chest" partData={parts.chest} />
        <PartDisplay label="Left Arm" partData={parts.arm_l} />
        <PartDisplay label="Right Arm" partData={parts.arm_r} />
        <PartDisplay label="Left Leg" partData={parts.leg_l} />
        <PartDisplay label="Right Leg" partData={parts.leg_r} />
      </LabeledList>
    </Section>
  );
};
const PartDisplay = (props) => {
  const {
    label, partData,
  } = props;
  if (partData.exists === 0) {
    return <LabeledList.Item color="red" label={label}><Box bold>MISSING!</Box></LabeledList.Item>;
  } else {
    const partBluntPercent = Math.floor(partData.dmg_blunt/partData.max_health*100);
    const partBurnsPercent = Math.floor(partData.dmg_burns/partData.max_health*100);
    if (partBluntPercent || partBurnsPercent) {
      return (
        <LabeledList.Item label={label}>
          <Flex>
            <Flex.Item grow={1}>
              <Flex>
                <Flex.Item backgroundColor={"#990000"} width={partBluntPercent + "%"} />
                <Flex.Item backgroundColor={"#cc9900"} width={partBurnsPercent + "%"} />
                <Flex.Item grow={1} backgroundColor={"#000000"} stretch >&nbsp;</Flex.Item>
              </Flex>
            </Flex.Item>
            <Flex.Item shrink>
              <Flex>
                <Flex.Item shrink width="25px" backgroundColor={"#330000"} color={"#ff0000"} bold><Box textAlign={"center"}>{partBluntPercent > 0 ? partBluntPercent : "--"}</Box></Flex.Item>
                <Flex.Item shrink width="25px" backgroundColor={"#331100"} color={"#ffcc00"} bold><Box textAlign={"center"}>{partBurnsPercent > 0 ? partBurnsPercent : "--" }</Box></Flex.Item>
              </Flex>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      );
    }
  }
};
const AvailableCellsDisplay = (props) => {
  const { cells, act } = props;
  return (
    <Section title="Power Cells">
      {
        cells.length > 0
          ?(
            <LabeledList> {
              cells.map(cell => {
                return (
                  <div key={cell.ref}>
                    <LabeledList.Item label={cell.name}
                      buttons={
                        <>
                          <Button onClick={() => act("cell-install", { cellRef: cell.ref })} icon="plus" tooltip="Add to occpuant" />
                          <Button onClick={() => act("cell-eject", { cellRef: cell.ref })} icon="eject" tooltip="Eject from station" />
                        </>
                      }
                    >
                      {cell.current} / {cell.max}
                    </LabeledList.Item>
                  </div>);
              })
            }
            </LabeledList>
          )
          :(
            <Box as="div">None Stored</Box>
          )

      }
    </Section>);
};
const AvailableModulesDisplay = (props) => {
  const { modules, act } = props;
  return (
    <Section title="Modules"> {
      modules.length > 0
        ?(
          modules.map(modu => {
            return (
              <div key={modu.ref}>{modu.name}
                <Button onClick={() => act("module-install", { moduleRef: modu.ref })} icon="plus-circle" color="transparent" tooltip="Add to occpuant" />
                <Button onClick={() => act("module-eject", { moduleRef: modu.ref })} icon="eject" color="transparent" tooltip="Eject from station" />
              </div>
            );
          })
        )
        :(
          <Box as="div">None Stored</Box>
        )
    }
    </Section>
  );
};
const AvailableUpgradesDisplay = (props) => {
  const { upgrades, act } = props;
  return (
    <Section title="Upgrades"> {
      upgrades.length > 0
        ?(
          upgrades.map(upgrade => {
            return (
              <div key={upgrade.ref}>{upgrade.name}
                <Button onClick={() => act("upgrade-install", { upgradeRef: upgrade.ref })} icon="plus-circle" color="transparent" tooltip="Add to occpuant" />
                <Button onClick={() => act("upgrade-eject", { upgradeRef: upgrade.ref })} icon="eject" color="transparent" tooltip="Eject from station" />
              </div>
            );
          })
        ) :(
          <Box as="div">None Stored</Box>
        )
    }
    </Section>
  );
};
const AvailableClothingDisplay = (props) => {
  const { clothes, act } = props;
  return (
    <Section title="Clothing"> {
      clothes.length > 0
        ?(
          clothes.map(cloth => {
            return (
              <Box key={cloth.ref}>{cloth.name}
                <Button onClick={() => act("clothing-install", { clothingRef: cloth.ref })} icon="plus-circle" color="transparent" tooltip="Add to occpuant" />
                <Button onClick={() => act("clothing-eject", { clothingRef: cloth.ref })} icon="eject" color="transparent" tooltip="Eject from station" />
              </Box>
            );
          })
        )
        :(
          <Box as="div">None Stored</Box>
        )
    }
    </Section>
  );
};
const OccupantCellDisplay = (props) => {
  const { cellData, act } = props;
  return (
    <LabeledList.Item
      label="Power Cell"
      color={cellData ? "white" : "red"}
      buttons={
        <Button
          onClick={() => act("cell-remove")}
          icon="minus"
          tooltip="Remove the occpuant's power cell"
          disabled={cellData ? false : true} />
      }>
      { cellData
        ? <span>{cellData.name} ({cellData.current} / {cellData.max})</span>
        : <span>No Power Cell Installed</span>}
    </LabeledList.Item>
  );
};
const OccupantUpgradeDisplay = (props) => {
  const { upgrades, upgrades_max, act } = props;
  const upgrade_count = "Upgrades (" + upgrades.length + " / " + upgrades_max + " installed)";
  return (
    <Section title={upgrade_count}>
      <div>
        {
          upgrades.map(upgrade => {
            return (
              <Stack key={upgrade.ref}>
                <Stack.Item>{upgrade.name}</Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    icon="minus-circle"
                    color="transparent"
                    tooltip={`Remove ${upgrade.name}`}
                    onClick={() => act("upgrade-remove", { upgradeRef: upgrade.ref })}
                  />
                </Stack.Item>
              </Stack>
            );
          })
        }
      </div>
    </Section>);
};
const DockingTabView = (props) => {
  const { tabIndex, data, act } = props;
  switch (tabIndex) {
    case 1:
      return (
        <OccupantTab occupant={data.occupant} wire={data.wire} fuel={data.fuel} act={act} />
      );
    case 2:
      return (
        <Section title="Supplies">
          <LabeledList>
            <LabeledList.Item label="Welding Fuel">
              {data.fuel}
            </LabeledList.Item>
            <LabeledList.Item label="Wire Cabling">
              {data.wire}
            </LabeledList.Item>
          </LabeledList>
          <AvailableModulesDisplay modules={data.modules} act={act} />
          <AvailableUpgradesDisplay upgrades={data.upgrades} act={act} />
          <AvailableCellsDisplay cells={data.cells} act={act} />
          <AvailableClothingDisplay clothes={data.clothes} act={act} />
        </Section>);
  }
};
