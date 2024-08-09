/*
 * Copyright 2023 jlsnow301 (https://github.com/jlsnow301)
 * Licensed under MIT (https://choosealicense.com/licenses/mit/)
 */

import { Dimmer, Icon, Stack } from 'tgui-core/components';

/** Spinner that represents loading states.
 *
 * @usage
 * ```tsx
 * /// rest of the component
 * return (
 * ///... content to overlay
 * {!!loading && <LoadingScreen />}
 * /// ... content to overlay
 * );
 * ```
 * OR
 * ```tsx
 * return (
 * {loading ? <LoadingScreen /> : <ContentToHide />}
 * )
 * ```
 */
export const LoadingScreen = () => {
  return (
    <Dimmer>
      <Stack align="center" fill justify="center" vertical>
        <Stack.Item>
          <Icon color="blue" name="toolbox" spin size={4} />
        </Stack.Item>
        <Stack.Item>Please wait...</Stack.Item>
      </Stack>
    </Dimmer>
  );
};
