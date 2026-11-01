/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

// Modal is made to resemble the modal of SeedFabricator.js
// Mostly custom code to properly align the modal box with the screen while applying the dimmer to a specific element

import { classes } from 'common/react';
import { Blink, Flex, Icon } from 'tgui-core/components';

type PowerAlertModalProps = {
  width: string | number;
  height: string | number;
};

export const PowerAlertModal = (props: PowerAlertModalProps) => {
  const { width, height } = props;
  return (
    <Flex
      width={width}
      height={height}
      justify="center"
      position="absolute"
      align="center"
      inline
    >
      <Flex.Item
        textAlign="center"
        width={35}
        height={10}
        fontSize={3}
        fontFamily="Courier"
        color="red"
        className={classes(['Modal'])}
        style={{
          'z-index': 2,
        }}
      >
        <Blink time={500}>
          <Icon name="exclamation-triangle" pr={1.5} />
          MALFUNCTION
          <Icon name="exclamation-triangle" pl={1.5} />
        </Blink>
        CHECK WIRES
      </Flex.Item>
    </Flex>
  );
};
