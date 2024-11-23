import { Placement } from '@popperjs/core';
import { KEY } from 'common/keys';
import { BooleanLike, classes } from 'common/react';
import {
  ChangeEvent,
  MouseEvent,
  ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Icon, Tooltip } from 'tgui-core/components';

import { Box, BoxProps, computeBoxClassName, computeBoxProps } from './Box';

/**
 * Getting ellipses to work requires that you use:
 * 1. A string rather than a node
 * 2. A fixed width here or in a parent
 * 3. Children prop rather than content
 */
type EllipsisUnion =
  | {
      children: string;
      /** @deprecated use children instead */
      content?: never;
      /** Cuts off text with an ellipsis */
      ellipsis: true;
    }
  | Partial<{
      children: ReactNode;
      /** @deprecated use children instead */
      content: ReactNode;
      ellipsis: undefined;
    }>;

export type ButtonProps = Partial<{
  /** Captures keyboard events */
  captureKeys: boolean;
  /** Makes the button circular */
  circular: boolean;
  /** Reduces the padding of the button */
  compact: boolean;
  /** Disables and greys out the button */
  disabled: BooleanLike;
  /** Fill all available horizontal space */
  fluid: boolean;
  /** Adds an icon to the button */
  icon: string | false;
  /** Icon color */
  iconColor: string;
  /** Icon position */
  iconPosition: string;
  /** Icon rotation */
  iconRotation: number;
  /** Makes the icon spin */
  iconSpin: BooleanLike;
  /** Called when element is clicked */
  onClick: (e: any) => void;
  /** Activates the button (gives it a green color) */
  selected: BooleanLike;
  /** A fancy, boxy tooltip, which appears when hovering over the button */
  tooltip: ReactNode;
  /** Position of the tooltip. See [`Popper`](#Popper) for valid options. */
  tooltipPosition: Placement;
  /** Align content vertically using flex. Use lineHeight if the height is static. */
  verticalAlignContent: string;
}> &
  EllipsisUnion &
  BoxProps;

/** Clickable button. Comes with variants. Read more in the documentation. */
export function Button(props: ButtonProps) {
  const {
    captureKeys = true,
    children,
    circular,
    className,
    color,
    compact,
    content,
    disabled,
    ellipsis,
    fluid,
    icon,
    iconColor,
    iconPosition,
    iconRotation,
    iconSpin,
    onClick,
    selected,
    tooltip,
    tooltipPosition,
    verticalAlignContent,
    ...rest
  } = props;

  const toDisplay: ReactNode = content || children;

  let buttonContent = (
    <div
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        content && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        circular && 'Button--circular',
        compact && 'Button--compact',
        iconPosition && 'Button--iconPosition--' + iconPosition,
        verticalAlignContent && 'Button--flex',
        verticalAlignContent && fluid && 'Button--flex--fluid',
        verticalAlignContent &&
          'Button--verticalAlignContent--' + verticalAlignContent,
        color && typeof color === 'string'
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled ? 0 : undefined}
      onClick={(event) => {
        if (!disabled && onClick) {
          onClick(event);
        }
      }}
      onKeyDown={(event) => {
        if (!captureKeys) {
          return;
        }

        // Simulate a click when pressing space or enter.
        if (event.key === KEY.Space || event.key === KEY.Enter) {
          event.preventDefault();
          if (!disabled && onClick) {
            onClick(event);
          }
          return;
        }

        // Refocus layout on pressing escape.
        if (event.key === KEY.Escape) {
          event.preventDefault();
        }
      }}
      {...computeBoxProps(rest)}
    >
      <div className="Button__content">
        {icon && iconPosition !== 'right' && (
          <Icon
            mr={toDisplay ? 1 : 0}
            name={icon}
            color={iconColor}
            rotation={iconRotation}
            spin={iconSpin}
          />
        )}
        {!ellipsis ? (
          toDisplay
        ) : (
          <span
            className={classes([
              'Button--ellipsis',
              icon && 'Button__textMargin',
            ])}
          >
            {toDisplay}
          </span>
        )}
        {icon && iconPosition === 'right' && (
          <Icon
            ml={toDisplay ? 1 : 0}
            name={icon}
            color={iconColor}
            rotation={iconRotation}
            spin={iconSpin}
          />
        )}
      </div>
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
}

type CheckProps = Partial<{
  checked: BooleanLike;
}> &
  ButtonProps;

/** Visually toggles between checked and unchecked states. */
export function ButtonCheckbox(props: CheckProps) {
  const { checked, ...rest } = props;

  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest}
    />
  );
}

Button.Checkbox = ButtonCheckbox;

type ConfirmProps = Partial<{
  confirmColor: string;
  confirmContent: ReactNode;
  confirmIcon: string;
}> &
  ButtonProps;

/**  Requires user confirmation before triggering its action. */
function ButtonConfirm(props: ConfirmProps) {
  const {
    children,
    color,
    confirmColor = 'bad',
    confirmContent = 'Confirm?',
    confirmIcon,
    ellipsis = true,
    icon,
    onClick,
    ...rest
  } = props;
  const [clickedOnce, setClickedOnce] = useState(false);

  function handleClick(event: MouseEvent<HTMLDivElement>) {
    if (!clickedOnce) {
      setClickedOnce(true);
      return;
    }

    onClick?.(event);
    setClickedOnce(false);
  }

  return (
    <Button
      icon={clickedOnce ? confirmIcon : icon}
      color={clickedOnce ? confirmColor : color}
      onClick={handleClick}
      {...rest}
    >
      {clickedOnce ? confirmContent : children}
    </Button>
  );
}

Button.Confirm = ButtonConfirm;

type InputProps = Partial<{
  currentValue: string;
  defaultValue: string;
  fluid: boolean;
  maxLength: number;
  onCommit: (e: any, value: string) => void;
  placeholder: string;
}> &
  ButtonProps;

/** Accepts and handles user input. */
function ButtonInput(props: InputProps) {
  const {
    children,
    color = 'default',
    content,
    currentValue,
    defaultValue,
    disabled,
    fluid,
    icon,
    iconRotation,
    iconSpin,
    maxLength,
    onCommit = () => null,
    placeholder,
    tooltip,
    tooltipPosition,
    ...rest
  } = props;
  const [inInput, setInInput] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const toDisplay = content || children;

  function commitResult(e) {
    const input = inputRef.current;
    if (!input) return;

    const hasValue = input.value !== '';
    if (hasValue) {
      onCommit(e, input.value);
    } else {
      if (defaultValue) {
        onCommit(e, defaultValue);
      }
    }
  }

  useEffect(() => {
    const input = inputRef.current;
    if (!input) return;

    if (inInput) {
      input.value = currentValue || '';
      try {
        input.focus();
        input.select();
      } catch {
        // Ignore errors
      }
    }
  }, [inInput, currentValue]);

  let buttonContent = (
    <Box
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        'Button--color--' + color,
      ])}
      {...rest}
      onClick={() => setInInput(true)}
    >
      {icon && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
      <div>{toDisplay}</div>
      <input
        disabled={!!disabled}
        ref={inputRef}
        className="NumberInput__input"
        style={{
          display: !inInput ? 'none' : '',
          textAlign: 'left',
        }}
        onBlur={(event) => {
          if (!inInput) {
            return;
          }
          setInInput(false);
          commitResult(event);
        }}
        onKeyDown={(event) => {
          if (event.key === KEY.Enter) {
            setInInput(false);
            commitResult(event);
            return;
          }
          if (event.key === KEY.Escape) {
            setInInput(false);
          }
        }}
      />
    </Box>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
}

Button.Input = ButtonInput;

type FileProps = {
  accept: string;
  multiple?: boolean;
  onSelectFiles: (files: string | string[]) => void;
} & ButtonProps;

/**  Accepts file input */
function ButtonFile(props: FileProps) {
  const { accept, multiple, onSelectFiles, ...rest } = props;

  const inputRef = useRef<HTMLInputElement>(null);

  async function read(files: FileList) {
    const promises = Array.from(files).map((file) => {
      const reader = new FileReader();

      return new Promise<string>((resolve) => {
        reader.onload = () => resolve(reader.result as string);
        reader.readAsText(file);
      });
    });

    return await Promise.all(promises);
  }

  async function handleChange(event: ChangeEvent<HTMLInputElement>) {
    const files = event.target.files;
    if (files?.length) {
      const readFiles = await read(files);
      onSelectFiles(multiple ? readFiles : readFiles[0]);
    }
  }

  return (
    <>
      <Button onClick={() => inputRef.current?.click()} {...rest} />
      <input
        hidden
        type="file"
        ref={inputRef}
        accept={accept}
        multiple={multiple}
        onChange={handleChange}
      />
    </>
  );
}

Button.File = ButtonFile;
