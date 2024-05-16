/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { shallowDiffers } from 'common/react';
import { Component, createRef } from 'inferno';
import { Button } from 'tgui/components';
import { chatRenderer } from './renderer';
import { ContextMenu } from '../context/ChatContext';

export class ChatPanel extends Component {
  constructor() {
    super();
    this.ref = createRef();
    this.state = {
      scrollTracking: true,
      showContext: false,
    };
    this.handleScrollTrackingChange = value => this.setState({
      scrollTracking: value,
    });
    this.handleContext = value => {
      this.setState({ showContext: value });
      if (value === true) {
        window.addEventListener('click', e => {
          this.handleContext(false);
        });
      } else window.removeEventListener('click');
    };
  }

  componentDidMount() {
    chatRenderer.mount(this.ref.current);
    chatRenderer.events.on('scrollTrackingChanged',
      this.handleScrollTrackingChange);
    chatRenderer.events.on('contextShow',
      this.handleContext);
    this.componentDidUpdate();
  }

  componentWillUnmount() {
    chatRenderer.events.off('scrollTrackingChanged',
      this.handleScrollTrackingChange);
    chatRenderer.events.off('contextShow',
      this.handleContext);
  }

  componentDidUpdate(prevProps) {
    requestAnimationFrame(() => {
      chatRenderer.ensureScrollTracking();
    });
    const shouldUpdateStyle = (
      !prevProps || shallowDiffers(this.props, prevProps)
    );
    if (shouldUpdateStyle) {
      chatRenderer.assignStyle({
        'width': '100%',
        'white-space': 'normal',
        'font-size': this.props.fontSize,
        'line-height': this.props.lineHeight,
      });
    }
  }

  render() {
    const {
      scrollTracking,
      showContext,
    } = this.state;
    return (
      <>
        <div className="Chat" ref={this.ref} />
        {!scrollTracking && (
          <Button
            className="Chat__scrollButton"
            icon="arrow-down"
            onClick={() => chatRenderer.scrollToBottom()}>
            Scroll to bottom
          </Button>
        )}
        {showContext && (
          <ContextMenu
            ref={this.ref}
          />
        )}
      </>
    );
  }
}
