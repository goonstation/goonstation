import { Fragment } from 'inferno';
import { Button, LabeledList, Section, Box, Flex, Divider } from '../../components';
import { DetonatorTimer } from './DetonatorTimer';

export const Detonator = props => {
  const {
    detonator,
    onToggleAnchor,
    onToggleSafety,
    onWireInteract,
    onPrimeDetonator,
    onTriggerActivate,
    onSetTimer,
  } = props;

  return (
    <Section
      title="Detonator">
      <DetonatorWires
        detonator={detonator}
        onWireInteract={onWireInteract}
        onSetTimer={onSetTimer} />
      <Divider />
      <DetonatorUtility
        detonator={detonator}
        onToggleAnchor={onToggleAnchor}
        onToggleSafety={onToggleSafety}
        onPrimeDetonator={onPrimeDetonator}
        onTriggerActivate={onTriggerActivate} />
    </Section>
  );
};

const DetonatorWires = props => {
  const {
    detonator: {
      wireNames,
      wireStatus,
      time,
    },
    onWireInteract,
    onSetTimer,
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
                    onClick={() => onWireInteract("cut", i)}>
                    Cut
                  </Button>
                  <Button
                    onClick={() => onWireInteract("pulse", i)}>
                    Pulse
                  </Button>
                </Fragment>)
                : <Box color="average">Cut</Box> }
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Flex.Item>
      <Flex.Item
        mr={5}
        mt={2} >
        <DetonatorTimer
          time={time} />
        <Button
          mt={1}
          onClick={() => onSetTimer()}>
          Set Timer
        </Button>
      </Flex.Item>
    </Flex>
  );
};

const DetonatorUtility = props => {
  const {
    detonator: {
      isAnchored,
      trigger,
      safetyIsOn,
      isPrimed,
      attachments,
    },
    onToggleAnchor,
    onToggleSafety,
    onPrimeDetonator,
    onTriggerActivate,
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
        <Box
          bold
          color="red">
          PRIMED
        </Box>);
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
        {trigger ? <Button
          content={trigger}
          onClick={() => onTriggerActivate()} />
          : "There is no trigger attached."}

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
      <LabeledList.Item label="Attachments">
        {attachments.length > 0 ? (
          attachments.map((entry, i) => (
            <Fragment key={entry + i}>
              { attachments[i] }
              <br />
            </Fragment>
          )))
          : "There are no additional attachments to the detonator."}
      </LabeledList.Item>
    </LabeledList>
  );
};
