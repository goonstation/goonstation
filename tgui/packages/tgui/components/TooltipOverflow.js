import React from 'common/react';
import { Box, Tooltip } from "../components";
import { Component, createRef } from 'inferno';
import { createLogger } from 'common/logging.js';

const logger = createLogger('TooltipOverflow');

const findNearestScrollableParent = startingNode => {
  const body = document.body;
  let node = startingNode;
  while (node && node !== body) {
    logger.log('hi');
    // This definitely has a vertical scrollbar, because it reduces
    // scrollWidth of the element. Might not work if element uses
    // overflow: hidden.
    if (node.scrollWidth < node.offsetWidth) {
      return node;
    }
    node = node.parentNode;
  }
  return window;
};

export class TooltipOverflow extends Component {
  constructor(props) {
    super(props);
    this.refBox = createRef();
    this.rootNode = null;
    this.scrollNode = null;
    this.overflowed = false;
  }

  componentDidMount() {
    logger.log('hi');
    this.scrollNode = findNearestScrollableParent(this);
  }

  handleMouseMove(e) {
    logger.log('hi');
  }

  render() {
    const {
      className,
      content,
      ...rest
    } = this.props;
    return (
      <Box
        onClick={this.handleMouseMove.bind(this)}
        inline
        ref={this.refBox}
        className="TooltipOverflow">
        {!!this.overflowed && (
          <Tooltip
            content={content}
            {...rest} />
        )}
        {"aaaaaaaaaaaaaaaaaaaaaaaaa"}
      </Box>
    );
  }
}
