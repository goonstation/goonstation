/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { KEY } from 'common/keys';
import { Input } from 'tgui-core/components';

export const TerminalInput = (props) => {
  const {
    autoFocus,
    autoSelect,
    children,
    className,
    disabled,
    expensive,
    fluid,
    maxLength,
    monospace,
    onChange,
    onEnter,
    onKeyUp,
    onKeyDown,
    onKey,
    onEscape,
    onInput,
    placeholder,
    selfClear,
    value,
    ...rest
  } = props;

  const checkArrows = (e) => {
    const e_value = e.key;
    if (e_value === KEY.Up) {
      onKeyUp?.(e, e_value);
    } else if (e_value === KEY.Down) {
      onKeyDown?.(e, e_value);
    } else {
      onKey?.(e, e_value);
    }
  };

  return (
    <Input
      autoFocus={autoFocus}
      autoSelect={autoSelect}
      className={className}
      disabled={disabled}
      expensive={expensive}
      fluid={fluid}
      maxLength={maxLength}
      monospace={monospace}
      onChange={onChange}
      onEnter={onEnter}
      onEscape={onEscape}
      onInput={onInput}
      onKeyDown={checkArrows}
      placeholder={placeholder}
      selfClear={selfClear}
      value={value}
      {...rest}
    />
  );
};
