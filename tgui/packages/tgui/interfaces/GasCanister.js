import { useBackend } from '../backend';
import { Divider, Box } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReleaseValve } from './common/ReleaseValve';
import { Detonator } from './GasCanister/Detonator';

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
    detonatorAttachments,
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

  const handleWireInteract = (toolAction, index) => {
    act("wire-interact", {
      index,
      toolAction,
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

  const handleTriggerActivate = () => {
    act("trigger");
  };

  const handleSetTimer = newTime => {
    act("timer", {
      newTime,
    });
  };

  const hasDetonator = !!(detonator);

  return (
    <Window
      resizable
      width={hasDetonator ? 550 : 400}
      height={hasDetonator ? 680 : 370}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}>
          <Divider />
          {
            hasValve
              ? (
                <ReleaseValve
                  valveIsOpen={valveIsOpen}
                  releasePressure={releasePressure}
                  minRelease={minRelease}
                  maxRelease={maxRelease}
                  onToggleValve={handleToggleValve}
                  onSetPressure={handleSetPressure} />
              )
              : (
                <Box
                  color="average">The release valve is missing.
                </Box>
              )
          }
        </PortableBasicInfo>
        {
          detonator
            ? (
              <Detonator
                detonator={detonator}
                detonatorAttachments={detonatorAttachments}
                onToggleAnchor={handleToggleAnchor}
                onToggleSafety={handleToggleSafety}
                onWireInteract={handleWireInteract}
                onPrimeDetonator={handlePrimeDetonator}
                onTriggerActivate={handleTriggerActivate}
                onSetTimer={handleSetTimer} />
            )
            : (
              <PortableHoldingTank
                holding={holding}
                onEjectTank={handleEjectTank} />
            )
        }
      </Window.Content>
    </Window>
  );
};
