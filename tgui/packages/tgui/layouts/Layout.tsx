/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { useEffect, useRef } from 'react';

import { WindowMode } from '../backend'; // |GOONSTATION-ADD|
import {
  BoxProps,
  computeBoxClassName,
  computeBoxProps,
} from '../components/Box';
import { addScrollableNode, removeScrollableNode } from '../events';

type Props = Partial<{
  theme: string;
  mode: WindowMode; // |GOONSTATION-ADD|
}> &
  BoxProps;

export function Layout(props: Props) {
  const {
    className,
    theme = 'nanotrasen',
    mode = 'dark',
    children,
    ...rest
  } = props;

  // |GOONSTATION-CHANGE|
  return (
    <div className={classes(['theme-' + theme, 'mode-' + mode])}>
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
