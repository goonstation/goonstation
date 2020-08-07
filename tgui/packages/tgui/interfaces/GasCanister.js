import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Button, LabeledList, Section, NoticeBox, Box, Icon, ProgressBar, NumberInput, AnimatedNumber, LabeledControls, Flex, Divider } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReleaseValve } from './common/ReleaseValve';

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
    act('set-pressure', {
      releasePressure,
    });
  };

  const handleToggleValve = () => {
    act('toggle-valve');
  };

  const handleEjectTank = () => {
    act('eject-tank');
  };

  return (
    <Window
      key={holding}
      width={holding ? 700 : 400}
      height={370}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure} />
        <Section>
          { hasValve
            && <ReleaseValve
              valveIsOpen={valveIsOpen}
              releasePressure={releasePressure}
              minRelease={minRelease}
              maxRelease={maxRelease}
              onToggleValve={handleToggleValve}
              onSetPressure={handleSetPressure} />}
        </Section>
        { !detonator && <PortableHoldingTank
          holding={holding}
          onEjectTank={handleEjectTank} /> }
        { detonator && <Detonator /> }
      </Window.Content>
    </Window>
  );
};

const Detonator = props => {
  const {
    isAnchored,
    trigger,
    safetyIsOn,
    isPrimed,
    wireColors,
  } = props;

  return (
    <DetonatorUtility />
  );
};


const DetonatorUtility = props => {
  const {
    isAnchored,
    trigger,
    safetyIsOn,
    isPrimed,
  } = props;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Anchor Status">
          d
        </LabeledList.Item>
        <LabeledList.Item label="Trigger">
          d
        </LabeledList.Item>
        <LabeledList.Item label="Safety">
          d
        </LabeledList.Item>
        <LabeledList.Item label="Arming">
          d
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
