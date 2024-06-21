/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { canRender, classes } from 'common/react';
import { addScrollableNode, removeScrollableNode } from '../events';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type Props = Partial<{
  /** Buttons to render aside the section title. */
  buttons: InfernoNode;
  /** If true, fills all available vertical space. */
  fill: boolean;
  /** If true, removes all section padding. */
  fitted: boolean;
  /** Shows or hides the scrollbar. */
  scrollable: boolean;
  /** Shows or hides the horizontal scrollbar. */
  scrollableHorizontal: boolean;
  /** Title of the section. */
  title: InfernoNode;
  /** @member Callback function for the `scroll` event */
  onScroll: ((this: GlobalEventHandlers, ev: Event) => any) | null;
}> &
  BoxProps;

export class Section extends Component<Props> {
  scrollableRef: RefObject<HTMLDivElement>;
  scrollable: boolean;

  constructor(props) {
    super(props);
    this.scrollableRef = createRef();
    this.scrollable = props.scrollable;
  }

  componentDidMount() {
    if (this.scrollable) {
      addScrollableNode(this.scrollableRef.current);
    }
  }

  componentWillUnmount() {
    if (this.scrollable) {
      removeScrollableNode(this.scrollableRef.current);
    }
  }

  render() {
    const {
      buttons,
      children,
      className,
      fill,
      fitted,
      onScroll,
      scrollable,
      scrollableHorizontal,
      title,
      ...rest
    } = this.props;
    const hasTitle = canRender(title) || canRender(buttons);
    return (
      <div
        className={classes([
          'Section',
          fill && 'Section--fill',
          fitted && 'Section--fitted',
          scrollable && 'Section--scrollable',
          scrollableHorizontal && 'Section--scrollableHorizontal',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {hasTitle && (
          <div className="Section__title">
            <span className="Section__titleText">{title}</span>
            <div className="Section__buttons">{buttons}</div>
          </div>
        )}
        <div className="Section__rest">
          <div onScroll={onScroll} ref={this.scrollableRef} className="Section__content">
            {children}
          </div>
        </div>
      </div>
    );
  }
}
