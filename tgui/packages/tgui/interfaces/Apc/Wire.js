import { useBackend } from "../../backend";
import {
  Box,
  Button,
  LabeledList,
} from '../../components';


export const WIRE_ORANGE = 1;
export const WIRE_DARK_RED = 2;
export const WIRE_WHITE = 3;
export const WIRE_YELLOW = 4;


export const Wire = (props, context) => {
  const {
    wire,
  } = props;
  const { act, data } = useBackend(context);
  const {
    orange_cut,
    dark_red_cut,
    white_cut,
    yellow_cut,
  } = data;

  const wireColorToString = (wire) => {
    switch (wire) {
      case WIRE_ORANGE:
        return "Orange";
      case WIRE_DARK_RED:
        return "Dark red";
      case WIRE_WHITE:
        return "White";
      case WIRE_YELLOW:
        return "Yellow";
      default:
        return "unknown";
    }
  };

  const color = wireColorToString(wire);

  // ------------ Events ------------
  const onMend = (e) => {
    act("onMendWire", { wire });
  };

  const onCut = (e) => {
    act("onCutWire", { wire });
  };

  const onPulse = (e) => {
    act("onPulseWire", { wire });
  };

  const onBite = (e) => {
    act("onBiteWire", { wire });
  };
  // ------------ End Events ------------

  const isCut = (wire) => {
    // Logic is slightly different since dm doesn't 0 index for some reason
    switch (wire) {
      case WIRE_ORANGE:
        return orange_cut;
      case WIRE_DARK_RED:
        return dark_red_cut;
      case WIRE_WHITE:
        return white_cut;
      case WIRE_YELLOW:
        return yellow_cut;
    }
  };

  const toggleCutButton = () => {
    if (isCut(wire)) {
      return <Button content="mend" onClick={onMend} align="center" />;
    } else {
      return <Button content="cut" icon="cut" onClick={onCut} />;
    }
  };

  const actionsDisplay = () => {
    if (isCut(wire)) {
      return (
        <Box height={1.8}>
          <Button content="Mend" onClick={onMend} selected />
        </Box>
      );
    } else {
      return (
        <Box height={1.8}>
          <Button content="Cut" icon="cut" onClick={onCut} />
          <Button content="Pulse" icon="bolt" onClick={onPulse} />
          <Button content="Bite" icon="tooth" onClick={onBite} />
        </Box>
      );
    }
  };

  return (
    <LabeledList.Item key={wire} label={color} labelColor={color.toLowerCase().replace(' ', '')} >
      {actionsDisplay()}
    </LabeledList.Item>
  );
};
