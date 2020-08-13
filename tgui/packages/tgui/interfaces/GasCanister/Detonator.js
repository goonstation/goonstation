import { Fragment } from 'inferno';
import { Button, LabeledList, Section, Box, Flex, Divider, Icon } from '../../components';
import { DetonatorTimer } from './DetonatorTimer';

export const Detonator = props => {
  const {
    detonator,
    detonatorAttachments,
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
        detonatorAttachments={detonatorAttachments}
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
      isPrimed,
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
              <Box
                height={1.7}>
                { (wireStatus && wireStatus[i]) ? (
                  <Fragment>
                    <Button
                      onClick={() => onWireInteract("cut", i)}>
                      <Icon name="cut" />
                      Cut
                    </Button>
                    <Button
                      onClick={() => onWireInteract("pulse", i)}>
                      <Icon name="bolt" />
                      Pulse
                    </Button>
                  </Fragment>)
                  : (
                    <Box
                      color="average"
                      minHeight={1.4}>
                      Cut
                    </Box>) }
              </Box>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Flex.Item>
      <Flex.Item
        mr={5}
        mt={2} >
        <Flex
          direction="column"
          align="center">
          <Flex.Item>
            <DetonatorTimer
              time={time} />
          </Flex.Item>
          <Flex.Item>
            <Button
              mt={1}
              disabled={isPrimed}
              onClick={() => onSetTimer()}>
              <Icon name="clock" />Timer
            </Button>
          </Flex.Item>
        </Flex>
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
    },
    detonatorAttachments,
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
          onClick={() => onPrimeDetonator()} >
          <Icon name="bomb" />Prime
        </Button>);
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
          : (
            <Button
              onClick={() => onToggleAnchor()} >
              <Icon name="anchor" />Anchor
            </Button>)}
      </LabeledList.Item>
      <LabeledList.Item
        label="Trigger">
        {trigger ? (
          <Button
            onClick={() => onTriggerActivate()} >
            {trigger}
          </Button>)
          : "There is no trigger attached."}

      </LabeledList.Item>
      <LabeledList.Item
        label="Safety">
        { safetyIsOn
          ? (
            <Button
              color="average"
              onClick={() => onToggleSafety()} >
              <Icon name="power-off" />Turn Off
            </Button>)
          : <Box color="average">Off</Box> }
      </LabeledList.Item>
      <LabeledList.Item
        label="Arming">
        { armingStatus() }
      </LabeledList.Item>
      <LabeledList.Item label="Attachments">
        {detonatorAttachments && detonatorAttachments.length > 0 ? (
          detonatorAttachments.map((entry, i) => (
            <Fragment key={entry + i}>
              { detonatorAttachments[i] }
              <br />
            </Fragment>
          )))
          : "There are no additional attachments to the detonator."}
      </LabeledList.Item>
    </LabeledList>
  );
};
