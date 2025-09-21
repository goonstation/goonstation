/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useEffect, useRef } from 'react';
import type { Box } from 'tgui-core/components';
import { addScrollableNode, removeScrollableNode } from 'tgui-core/events';
import { classes } from 'tgui-core/react';
import { computeBoxClassName, computeBoxProps } from 'tgui-core/ui';

import { WindowMode } from '../backend'; // |GOONSTATION-ADD|

type BoxProps = React.ComponentProps<typeof Box>;

type Props = Partial<{
  theme: string;
  mode: WindowMode; // |GOONSTATION-ADD|
}> &
  BoxProps;

export function Layout(props: Props) {
  const {
    className,
    theme = 'nanotrasen',
    mode = 'dark', // |GOONSTATION-ADD|
    children,
    ...rest
  } = props;

  // |GOONSTATION-CHANGE|
  const styleClasses = `theme-${theme} mode-${mode}`;

  useEffect(() => {
    document.documentElement.className = styleClasses;
  }, [styleClasses]);

  return (
    <div className={styleClasses}>
      <div
        className={classes(['Layout', className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </div>
  );
}

type ContentProps = Partial<{
  scrollable: boolean;
}> &
  BoxProps;

function LayoutContent(props: ContentProps) {
  const { className, scrollable, children, ...rest } = props;
  const node = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const self = node.current;

    if (self && scrollable) {
      addScrollableNode(self);
    }
    return () => {
      if (self && scrollable) {
        removeScrollableNode(self);
      }
    };
  }, []);

  return (
    <div
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
        className,
        computeBoxClassName(rest),
      ])}
      ref={node}
      {...computeBoxProps(rest)}
    >
      {children}
    </div>
  );
}

Layout.Content = LayoutContent;
