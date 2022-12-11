/**
 * @file
 * @copyright 2022
 * @author Grokberg (https://github.com/ruben-svensson)
 * @license ISC
 */

import { Component } from 'inferno';
import { Button } from '..';

type ConfirmButtonProps = {
  icon?: string;
  color?: string;
  onConfirm?: () => void;
  tooltipContent?: string;
  confirmText?: string;
};

type ConfirmButtonState = {
  confirmState: boolean;
};

export class ConfirmButton extends Component<ConfirmButtonProps, ConfirmButtonState> {
  state = {
    confirmState: false,
  };

  setConfirmState = (b: boolean) => {
    this.setState({
      confirmState: b,
    });
  };

  render() {
    const { icon, color, onConfirm, tooltipContent, confirmText = 'Confirm', ...rest } = this.props;

    return (
      <Button
        icon={icon}
        color={this.state.confirmState ? 'orange' : color}
        tooltip={this.state.confirmState ? confirmText : tooltipContent}
        onMouseOut={() => this.setConfirmState(false)}
        onClick={() => {
          if (this.state.confirmState) {
            onConfirm();
            this.setConfirmState(false);
          } else {
            this.setConfirmState(true);
          }
        }}
        {...rest}
      />
    );
  }
}
