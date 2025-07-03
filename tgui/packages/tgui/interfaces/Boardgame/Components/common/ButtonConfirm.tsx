import { Component } from 'react';

import { Button } from '../../../../components';

type ButtonConfirmProps = {
  icon?: string;
  color?: string;
  onConfirm?: () => void;
  tooltipContent?: string;
  confirmText?: string;
};

type ButtonConfirmState = {
  confirmState: boolean;
};

// I know there is Button.Confirm, but mine does what I want it to do better
export class ButtonConfirm extends Component<
  ButtonConfirmProps,
  ButtonConfirmState
> {
  state = {
    confirmState: false,
  };

  setConfirmState = (b: boolean) => {
    this.setState({
      confirmState: b,
    });
  };

  render() {
    const {
      icon,
      color,
      onConfirm,
      tooltipContent,
      confirmText = 'Confirm',
      ...rest
    } = this.props;

    return (
      <Button
        icon={icon}
        color={this.state.confirmState ? 'orange' : color}
        tooltip={this.state.confirmState ? confirmText : tooltipContent}
        onMouseOut={() => this.setConfirmState(false)}
        onClick={() => {
          if (this.state.confirmState) {
            onConfirm?.();
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
