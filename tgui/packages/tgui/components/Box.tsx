/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { createVNode, InfernoNode, KeyboardEventHandler, MouseEventHandler, UIEventHandler } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';
import { CSS_COLORS } from '../constants';
import { logger } from '../logging';

type BooleanProps = Partial<Record<keyof typeof booleanStyleMap, boolean>>;
type StringProps = Partial<Record<keyof typeof stringStyleMap, string | BooleanLike>>;

export type EventHandlers = Partial<{
  onClick: MouseEventHandler<HTMLDivElement>;
  onContextMenu: MouseEventHandler<HTMLDivElement>;
  onDoubleClick: MouseEventHandler<HTMLDivElement>;
  onKeyDown: KeyboardEventHandler<HTMLDivElement>;
  onKeyUp: KeyboardEventHandler<HTMLDivElement>;
  onMouseDown: MouseEventHandler<HTMLDivElement>;
  onMouseMove: MouseEventHandler<HTMLDivElement>;
  onMouseOver: MouseEventHandler<HTMLDivElement>;
  onMouseUp: MouseEventHandler<HTMLDivElement>;
  onScroll: UIEventHandler<HTMLDivElement>;
}>;

export type BoxProps = { [key: string]: any } /* |GOONSTATION-ADD| */ & Partial<{
  as: string;
  children: InfernoNode;
  className: string | BooleanLike;
  style: Record<string, string>; // |GOONSTATION-CHANGE| (Partial<CSSStyleDeclaration> -> Record<string, string>)
}> &
  BooleanProps &
  StringProps &
  EventHandlers;

// Don't you dare put this elsewhere
type DangerDoNotUse = {
  dangerouslySetInnerHTML?: {
    __html: any;
  };
};

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = (value: unknown) => {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px')) {
      return parseFloat(value) / 12 + 'rem';
    }
    return value;
  }
  if (typeof value === 'number') {
    return value + 'rem';
  }
};

/**
 * Same as `unit`, but half the size for integers numbers.
 */
export const halfUnit = (value: unknown) => {
  if (typeof value === 'string') {
    return unit(value);
  }
  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

const isColorCode = (str: unknown) => !isColorClass(str);

const isColorClass = (str: unknown): boolean => {
  return typeof str === 'string' && CSS_COLORS.includes(str as any);
};

const mapRawPropTo = (attrName) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = value;
  }
};

const mapUnitPropTo = (attrName, unit) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = unit(value);
  }
};

const mapBooleanPropTo = (attrName, attrValue) => (style, value) => {
  if (value) {
    style[attrName] = attrValue;
  }
};

const mapDirectionalUnitPropTo = (attrName, unit, dirs) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    for (let i = 0; i < dirs.length; i++) {
      style[attrName + '-' + dirs[i]] = unit(value);
    }
  }
};

const mapColorPropTo = (attrName) => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

// String / number props
// |GOONSTATION-CHANGE| camelCase -> kebab-case
const stringStyleMap = {
  align: mapRawPropTo('text-align'),
  bottom: mapUnitPropTo('bottom', unit),
  fontFamily: mapRawPropTo('font-family'),
  fontSize: mapUnitPropTo('font-size', unit),
  fontWeight: mapRawPropTo('fontweight'),
  height: mapUnitPropTo('height', unit),
  left: mapUnitPropTo('left', unit),
  maxHeight: mapUnitPropTo('max-height', unit),
  maxWidth: mapUnitPropTo('max-width', unit),
  minHeight: mapUnitPropTo('min-height', unit),
  minWidth: mapUnitPropTo('min-width', unit),
  opacity: mapRawPropTo('opacity'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflow-x'),
  overflowY: mapRawPropTo('overflow-y'),
  position: mapRawPropTo('position'),
  right: mapUnitPropTo('right', unit),
  textAlign: mapRawPropTo('text-align'),
  top: mapUnitPropTo('top', unit),
  verticalAlign: mapRawPropTo('vertical-align'),
  width: mapUnitPropTo('width', unit),

  lineHeight: (style, value) => {
    if (typeof value === 'number') {
      style['line-height'] = value; // |GOONSTATION-CHANGE| (lineHeight -> line-height)
    } else if (typeof value === 'string') {
      style['line-height'] = unit(value); // |GOONSTATION-CHANGE| (lineHeight -> line-height)
    }
  },
  // Margin
  m: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom', 'Left', 'Right']),
  mb: mapUnitPropTo('margin-bottom', halfUnit),
  ml: mapUnitPropTo('margin-left', halfUnit),
  mr: mapUnitPropTo('margin-right', halfUnit),
  mt: mapUnitPropTo('margin-top', halfUnit),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['Left', 'Right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom']),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom', 'Left', 'Right']),
  pb: mapUnitPropTo('padding-bottom', halfUnit),
  pl: mapUnitPropTo('padding-left', halfUnit),
  pr: mapUnitPropTo('padding-right', halfUnit),
  pt: mapUnitPropTo('padding-top', halfUnit),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['Left', 'Right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom']),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('background-color'),
} as const;

// Boolean props
// |GOONSTATION-CHANGE| camelCase -> kebab-case
const booleanStyleMap = {
  bold: mapBooleanPropTo('font-weight', 'bold'),
  fillPositionedParent: (style, value) => {
    if (value) {
      style['position'] = 'absolute';
      style['top'] = 0;
      style['bottom'] = 0;
      style['left'] = 0;
      style['right'] = 0;
    }
  },
  inline: mapBooleanPropTo('display', 'inline-block'),
  italic: mapBooleanPropTo('font-style', 'italic'),
  nowrap: mapBooleanPropTo('white-space', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('white-space', 'pre-wrap'),
} as const;

export const computeBoxProps = (props) => {
  const computedProps: Record<string, any> = {};
  const computedStyles: Record<string, string | number> = {};

  // Compute props
  for (let propName of Object.keys(props)) {
    if (propName === 'style') {
      continue;
    }

    const propValue = props[propName];

    const mapPropToStyle = stringStyleMap[propName] || booleanStyleMap[propName];

    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  }

  // Merge computed styles and any directly provided styles
  computedProps.style = { ...computedStyles, ...props.style };

  return computedProps;
};

export const computeBoxClassName = (props: BoxProps) => {
  const color = props.textColor || props.color;
  const backgroundColor = props.backgroundColor;
  return classes([
    isColorClass(color) && 'color-' + color,
    isColorClass(backgroundColor) && 'color-bg-' + backgroundColor,
  ]);
};

export const Box = (props: BoxProps & DangerDoNotUse) => {
  const { as = 'div', className, children, ...rest } = props;

  // |GOONSTATION-CHANGE| Special handling for function children, Inferno/React difference
  if (typeof children === 'function') {
    return children(computeBoxProps(rest));
  }

  // Compute class name and styles
  const computedClassName = className ? `${className} ${computeBoxClassName(rest)}` : computeBoxClassName(rest);
  const computedProps = computeBoxProps(rest);

  if (as === 'img') {
    logger.error('Box component cannot be used as an image. Use Image component instead.');
  }

  // Render a wrapper element
  // |GOONSTATION-CHANGE| createElement -> createVNode
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    computedClassName,
    children,
    ChildFlags.UnknownChildren,
    computedProps,
    undefined
  );
};

Box.defaultHooks = pureComponentHooks;
