import { useBackend } from '../backend';
import { Divider } from '../components';
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

  const handleSetTimer = () => {
    act("timer");
  };

  // avoids unnecessary re-renders of the entire window every update
  // compared to just using 'detonator' as key
  let detonatorView = !!(detonator);

  return (
    <Window
      resizable
      key={detonatorView}
      width={detonatorView ? 550 : 400}
      height={detonatorView ? 700 : 370}>
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
          onPrimeDetonator={handlePrimeDetonator}
          onTriggerActivate={handleTriggerActivate}
          onSetTimer={handleSetTimer} /> }
      </Window.Content>
    </Window>
  );
};
