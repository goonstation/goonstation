/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
import { Component } from 'inferno';
import { classes } from 'common/react';
import { computeBoxProps } from './Box';

export const Tooltip = props => {
  const {
    content,
    overrideLong = false,
    position = 'bottom',
  } = props;
  // Empirically calculated length of the string,
  // at which tooltip text starts to overflow.
  const long = typeof content === 'string'
  && (content.length > 35 && !overrideLong);
  return (
    <div
      className={classes([
        'Tooltip',
        long && 'Tooltip--long',
        position && 'Tooltip--' + position,
      ])}
      data-tooltip={content} />
  );
};

class TooltipOverflow extends Component {
  constructor(props) {
    super(props);
    this.overflowed = false;
  }

  isEllipsisActive(e) {
    return e.offsetHeight < e.scrollHeight || e.offsetWidth < e.scrollWidth;
  }

  componentDidUpdate() {
    this.overflowed = this.isEllipsisActive(this.span);
  }

  componentDidMount() {
    this.overflowed = this.isEllipsisActive(this.span);
  }

  render() {
    const {
      className,
      content,
      children,
      ...rest
    } = this.props;
    const boxProps = computeBoxProps(rest);
    return (
      <span
        ref={ref => (this.span = ref)}
        className="TooltipOverflow"
        {...boxProps}>
        {!!this.overflowed && (
          <Tooltip
            content={content} />
        )}
        {children}
      </span>
    );
  }
}


Tooltip.Overflow = TooltipOverflow;
