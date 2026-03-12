import {
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { DetonatorTimer } from './DetonatorTimer';

export const Detonator = (props) => {
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
    <Section title="Detonator">
      <DetonatorWires
        detonator={detonator}
        onWireInteract={onWireInteract}
        onSetTimer={onSetTimer}
      />
      <Divider />
      <DetonatorUtility
        detonator={detonator}
        detonatorAttachments={detonatorAttachments}
        onToggleAnchor={onToggleAnchor}
        onToggleSafety={onToggleSafety}
        onPrimeDetonator={onPrimeDetonator}
        onTriggerActivate={onTriggerActivate}
      />
    </Section>
  );
};

interface DetonatorWireProps {
  detonator;
  onWireInteract;
  onSetTimer;
}

const DetonatorWires = (props: DetonatorWireProps) => {
  const {
    detonator: { wireNames, wireStatus, time, isPrimed } = {},
    onWireInteract,
    onSetTimer,
  } = props;

  return (
    <Flex>
      <Flex.Item>
        <LabeledList>
          {wireNames.map((entry, i) => (
            <LabeledList.Item key={entry + i} label={entry}>
              <Box height={1.7}>
                {wireStatus && wireStatus[i] ? (
                  <>
                    <Button icon="cut" onClick={() => onWireInteract('cut', i)}>
                      Cut
                    </Button>
                    <Button
                      icon="bolt"
                      onClick={() => onWireInteract('pulse', i)}
                    >
                      Pulse
                    </Button>
                  </>
                ) : (
                  <Box color="average" minHeight={1.4}>
                    Cut
                  </Box>
                )}
              </Box>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Flex.Item>
      <Flex.Item mr={2} mt={2}>
        <Flex direction="column" align="center">
          <Flex.Item>
            <DetonatorTimer time={time} isPrimed={isPrimed} />
          </Flex.Item>
          <Flex.Item>
            <Button
              mt={1}
              disabled={isPrimed}
              icon="fast-backward"
              onClick={() => onSetTimer(time - 300)}
            />
            <Button
              mt={1}
              disabled={isPrimed}
              icon="backward"
              onClick={() => onSetTimer(time - 10)}
            />
            <Button
              mt={1}
              disabled={isPrimed}
              icon="forward"
              onClick={() => onSetTimer(time + 10)}
            />
            <Button
              mt={1}
              disabled={isPrimed}
              icon="fast-forward"
              onClick={() => onSetTimer(time + 300)}
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

interface DetonatorUtilityProps {
  detonator;
  detonatorAttachments;
  onToggleAnchor;
  onToggleSafety;
  onPrimeDetonator;
  onTriggerActivate;
}

const DetonatorUtility = (props: DetonatorUtilityProps) => {
  const {
    detonator: { isAnchored, trigger, safetyIsOn, isPrimed } = {},
    detonatorAttachments,
    onToggleAnchor,
    onToggleSafety,
    onPrimeDetonator,
    onTriggerActivate,
  } = props;

  const renderArmingStatus = () => {
    if (safetyIsOn) {
      return 'The safety is on, therefore, you cannot prime the bomb.';
    } else if (!isPrimed) {
      return (
        <Button color="danger" icon="bomb" onClick={onPrimeDetonator}>
          Prime
        </Button>
      );
    } else {
      return (
        <Box bold color="red">
          PRIMED
        </Box>
      );
    }
  };

  return (
    <LabeledList>
      <LabeledList.Item
        className="gas-canister-detonator-utility__list-item"
        label="Anchor Status"
      >
        {isAnchored ? (
          'Anchored. There are no controls for undoing this.'
        ) : (
          <Button icon="anchor" onClick={onToggleAnchor}>
            Anchor
          </Button>
        )}
      </LabeledList.Item>
      <LabeledList.Item
        className="gas-canister-detonator-utility__list-item"
        label="Trigger"
      >
        {trigger ? (
          <Button onClick={onTriggerActivate}>{trigger}</Button>
        ) : (
          'There is no trigger attached.'
        )}
      </LabeledList.Item>
      <LabeledList.Item
        className="gas-canister-detonator-utility__list-item"
        label="Safety"
      >
        {safetyIsOn ? (
          <Button color="average" icon="power-off" onClick={onToggleSafety}>
            Turn Off
          </Button>
        ) : (
          <Box color="average">Off</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item
        className="gas-canister-detonator-utility__list-item"
        label="Arming"
      >
        {renderArmingStatus()}
      </LabeledList.Item>
      <LabeledList.Item
        label="Attachments"
        className="gas-canister-detonator-utility__list-item"
      >
        {detonatorAttachments && detonatorAttachments.length > 0
          ? detonatorAttachments.map((entry, i) => (
              <Box
                className="gas-canister-detonator-utility__attachment-item"
                key={entry + i}
              >
                {detonatorAttachments[i]}
              </Box>
            ))
          : 'There are no additional attachments to the detonator.'}
      </LabeledList.Item>
    </LabeledList>
  );
};
