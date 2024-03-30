/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';
import { KEY_DOWN, KEY_ENTER, KEY_ESCAPE, KEY_UP } from 'common/keycodes';

export const toInputValue = value => (
  typeof value !== 'number' && typeof value !== 'string'
    ? ''
    : String(value)
);

export class Input extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
      history: [],
      historyIndex: 0,
    };
    this.handleInput = e => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleFocus = e => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = e => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };

    this.navigateHistory = (direction, e) => {
      const newIndex = this.state.historyIndex + direction;
      let hasMoreHistory = false;
      if (direction > 0 && newIndex < this.state.history.length) {
        hasMoreHistory = true;
      } else if (direction < 0 && newIndex >= 0) {
        hasMoreHistory = true;
      }
      if (hasMoreHistory) {
        e.target.value = this.state.history[newIndex];
        this.state.historyIndex = newIndex;
      } else if (direction > 0) {
        // The last down arrow should clear the text field
        e.target.value = "";
        this.state.historyIndex = this.state.history.length;
      }
    };

    this.appendHistory = function (newText) {
      if (this.state.history[this.state.history.length - 1] !== newText) {
        this.state.history.push(newText);
      }
      this.state.historyIndex = this.state.history.length;
    };

    this.handleKeyDown = e => {
      const { onInput, onChange, onEnter, history } = this.props;
      if (e.keyCode === KEY_ENTER) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
        if (onInput) {
          onInput(e, e.target.value);
        }
        if (onEnter) {
          onEnter(e, e.target.value);
        }
        if (history) {
          this.appendHistory(e.target.value);
        }
        if (this.props.selfClear) {
          e.target.value = '';
        } else {
          e.target.blur();
        }
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        if (this.props.onEscape) {
          this.props.onEscape(e);
          return;
        }

        this.setEditing(false);
        e.target.value = toInputValue(this.props.value);
        e.target.blur();
        return;
      }

      if (history) {
        if (e.keyCode === KEY_UP) {
          this.navigateHistory(-1, e);
        } else if (e.keyCode === KEY_DOWN) {
          this.navigateHistory(1, e);
        }
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }

    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input.focus();

        if (this.props.autoSelect) {
          input.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    // Input only props
    const {
      selfClear,
      onInput,
      onChange,
      onEnter,
      value,
      maxLength,
      placeholder,
      ...boxProps
    } = props;
    // Box props
    const {
      className,
      fluid,
      monospace,
      ...rest
    } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}>
        <div className="Input__baseline">
          .
        </div>
        <input
          ref={this.inputRef}
          className="Input__input"
          placeholder={placeholder}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          maxLength={maxLength} />
      </Box>
    );
  }
}
