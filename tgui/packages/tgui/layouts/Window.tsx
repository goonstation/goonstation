/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  type ComponentProps,
  type PropsWithChildren,
  type ReactNode,
  useEffect,
  useLayoutEffect,
  useState,
} from 'react';
import type { Box } from 'tgui-core/components';
import { UI_DISABLED, UI_INTERACTIVE } from 'tgui-core/constants';
import { globalEvents } from 'tgui-core/events';
import { type BooleanLike, classes } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import {
  dragStartHandler,
  recallWindowGeometry,
  resizeStartHandler,
  setWindowKey,
} from '../drag';
import { suspendStart } from '../events/handlers/suspense';
import { createLogger } from '../logging';
import { Layout } from './Layout';
import { TitleBar } from './TitleBar';

const logger = createLogger('Window');
const DEFAULT_SIZE: [number, number] = [400, 600];

type Props = Partial<{
  buttons: ReactNode;
  canClose: BooleanLike;
  height: number;
  theme: string;
  title: string;
  width: number;
}> &
  PropsWithChildren;

export const Window = (props: Props) => {
  const {
    canClose = true,
    theme,
    title,
    children,
    buttons,
    width,
    height,
  } = props;

  const { config, suspended, debug } = useBackend();
  const [isReadyToRender, setIsReadyToRender] = useState(false);

  // We need to set the window to be invisible before we can set its geometry
  // Otherwise, we get a flicker effect when the window is first rendered
  useLayoutEffect(() => {
    Byond.winset(Byond.windowId, {
      'is-visible': false,
    });
    setIsReadyToRender(true);
  }, []);

  const scale = config?.window?.scale;

  useEffect(() => {
    let cancelled = false;

    if (!suspended && isReadyToRender) {
      const updateGeometry = async () => {
        const options = {
          ...config?.window,
          size: DEFAULT_SIZE,
        };

        if (width && height) {
          options.size = [width, height];
        }
        if (config?.window?.key) {
          setWindowKey(config.window.key);
        }
        await recallWindowGeometry(options);
        if (cancelled) {
          return;
        }
        Byond.winset(Byond.windowId, {
          'is-visible': true,
        });
        Byond.sendMessage('visible');
        globalEvents.emit('window-geometry-finished');
        logger.log('set to visible');
      };

      Byond.winset(Byond.windowId, {
        'can-close': Boolean(canClose),
      });
      logger.log('mounting');
      updateGeometry();

      return () => {
        cancelled = true;
        logger.log('unmounting');
      };
    }
  }, [isReadyToRender, suspended, width, height, scale]);

  const fancy = config?.window?.fancy;
  const mode = config?.window?.mode; /* |GOONSTATION-ADD| */

  // Determine when to show dimmer
  const showDimmer =
    config?.user &&
    (config.user.observer
      ? config.status < UI_DISABLED
      : config.status < UI_INTERACTIVE);

  return suspended ? null : (
    <Layout className="Window" theme={theme} mode={mode}>
      <TitleBar
        title={title || decodeHtmlEntities(config?.title ?? '')}
        status={config?.status}
        fancy={fancy}
        refreshing={!!config?.refreshing} /* |GOONSTATION-ADD| */
        onDragStart={dragStartHandler}
        onClose={suspendStart}
        canClose={canClose}
      >
        {buttons}
      </TitleBar>
      <div
        className={classes([
          'Window__rest',
          debug.debugLayout && 'debug-layout',
        ])}
      >
        {!suspended && children}
        {showDimmer && <div className="Window__dimmer" />}
      </div>
      {fancy && (
        <>
          <div
            className="Window__resizeHandle__e"
            onMouseDown={resizeStartHandler(1, 0) as any}
          />
          <div
            className="Window__resizeHandle__s"
            onMouseDown={resizeStartHandler(0, 1) as any}
          />
          <div
            className="Window__resizeHandle__se"
            onMouseDown={resizeStartHandler(1, 1) as any}
          />
        </>
      )}
    </Layout>
  );
};

type ContentProps = Partial<{
  className: string;
  fitted: boolean;
  scrollable: boolean;
  vertical: boolean;
}> &
  ComponentProps<typeof Box> &
  PropsWithChildren;

const WindowContent = (props: ContentProps) => {
  const { className, fitted, children, ...rest } = props;

  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;
