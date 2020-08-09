import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Button, LabeledList, Section, NoticeBox, Box, Icon, ProgressBar, NumberInput, AnimatedNumber, LabeledControls, Flex, Divider } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReleaseValve } from './common/ReleaseValve';
import { FlexItem } from '../components/Flex';

export const GasCanister = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    holding,
    hasValve,
    valveIsOpen,
    pressure,
    maxPressure,
    releasePressure,
    minRelease,
    maxRelease,
    detonator,
  } = data;

  const handleSetPressure = releasePressure => {
    act("set-pressure", {
      releasePressure,
    });
  };

  const handleToggleValve = () => {
    act("toggle-valve");
  };

  const handleEjectTank = () => {
    act("eject-tank");
  };

  const handleWireInteract = (index, toolAction) => {
    act("wire-interact", {
      toolAction,
      index,
    });
  };

  const handleToggleAnchor = () => {
    act("anchor");
  };

  const handleToggleSafety = () => {
    act("safety");
  };

  const handlePrimeDetonator = () => {
    act("prime");
  };

  // avoids unnecessary re-renders of the entire window every update
  let detonatorView = !!(detonator);

  return (
    <Window
      resizable
      key={detonatorView}
      width={detonatorView ? 550 : 400}
      height={detonatorView ? 550 : 370}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}>
          <Divider />
          { hasValve && <ReleaseValve
            valveIsOpen={valveIsOpen}
            releasePressure={releasePressure}
            minRelease={minRelease}
            maxRelease={maxRelease}
            onToggleValve={handleToggleValve}
            onSetPressure={handleSetPressure} />}
        </PortableBasicInfo>
        { !detonator && <PortableHoldingTank
          holding={holding}
          onEjectTank={handleEjectTank} /> }
        { detonator && <Detonator
          detonator={detonator}
          onToggleAnchor={handleToggleAnchor}
          onToggleSafety={handleToggleSafety}
          onWireInteract={handleWireInteract}
          onPrimeDetonator={handlePrimeDetonator} /> }
      </Window.Content>
    </Window>
  );
};

const Detonator = props => {
  const {
    detonator: {
      time,
      isAnchored,
      trigger,
      safetyIsOn,
      isPrimed,
      wireNames,
      wireStatus,
    },
    onToggleAnchor,
    onToggleSafety,
    onWireInteract,
    onPrimeDetonator,
  } = props;

  return (
    <Section title="Detonator">
      <DetonatorWires
        wireNames={wireNames}
        wireStatus={wireStatus}
        time={time}
        onWireInteract={onWireInteract} />
      <Divider />
      <DetonatorUtility
        isAnchored={isAnchored}
        safetyIsOn={safetyIsOn}
        isPrimed={isPrimed}
        onToggleAnchor={onToggleAnchor}
        onToggleSafety={onToggleSafety}
        onPrimeDetonator={onPrimeDetonator} />
    </Section>
  );
};

const DetonatorWires = props => {
  const {
    wireNames,
    wireStatus,
    time,
    onWireInteract,
  } = props;

  return (
    <Flex>
      <Flex.Item>
        <LabeledList>
          { wireNames.map((entry, i) => (
            <LabeledList.Item
              key={entry + i}
              label={entry}>
              { (wireStatus && wireStatus[i]) ? (
                <Fragment>
                  <Button
                    onClick={() => onWireInteract(i, "cut")}>
                    Cut
                  </Button>
                  <Button
                    onClick={() => onWireInteract(i, "pulse")}>
                    Pulse
                  </Button>
                </Fragment>)
                : <Box color="average">Cut</Box> }
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Flex.Item>
      <Flex.Item mr={5} mt={2} >
        <DetonatorTimer time={time} />
      </Flex.Item>
    </Flex>
  );
};

const DetonatorTimer = props => {
  const { time } = props;

  const FormatTime = () => {
    let seconds = Math.floor(time % 60);
    let minutes = Math.floor((time - seconds) / 60);
    if (time <= 0) {
      return `BO:OM`;
    }
    if (seconds < 10) {
      seconds = `0${seconds}`;
    }
    if (minutes < 10) {
      minutes = `0${minutes}`;
    }

    return `${minutes}:${seconds}`;
  };

  const TimeColor = () => {
    if (time <= 0) {
      return "red";
    } else if (time < 15) {
      return "orange";
    } else {
      return "green";
    }
  };

  return (
    <Flex direction="column" align="center">
      <Flex.Item>
        <Box
          p={1}
          textAlign="center"
          backgroundColor="black"
          color={TimeColor()}
          maxWidth="100px"
          fontSize="19px">
          <AnimatedNumber
            value={time}
            format={() => FormatTime()} />
        </Box>
      </Flex.Item>
      <Flex.Item>
        <Button mt={1}>Set Timer</Button>
      </Flex.Item>
    </Flex>
  );
};

const DetonatorUtility = props => {
  const {
    isAnchored,
    trigger,
    safetyIsOn,
    isPrimed,
    onToggleAnchor,
    onToggleSafety,
    onPrimeDetonator,
  } = props;

  const armingStatus = () => {
    if (safetyIsOn) {
      return ("The safety is on, therefore, you cannot prime the bomb.");
    } else if (!safetyIsOn && !isPrimed) {
      return (
        <Button
          color="danger"
          content="Prime"
          onClick={() => onPrimeDetonator()} />);
    } else {
      return (
        <Box bold color="red">PRIMED</Box>);
    }
  };

  return (
    <LabeledList>
      <LabeledList.Item
        label="Anchor Status">
        { isAnchored
          ? "Anchored. There are no controls for undoing this."
          : <Button
            content="Anchor"
            onClick={() => onToggleAnchor()} />}
      </LabeledList.Item>
      <LabeledList.Item
        label="Trigger">
        put shit here
      </LabeledList.Item>
      <LabeledList.Item
        label="Safety">
        { safetyIsOn
          ? <Button
            color="average"
            content="Turn Off"
            onClick={() => onToggleSafety()} />
          : <Box color="average">Off</Box> }
      </LabeledList.Item>
      <LabeledList.Item
        label="Arming">
        { armingStatus() }
      </LabeledList.Item>
    </LabeledList>
  );
};
