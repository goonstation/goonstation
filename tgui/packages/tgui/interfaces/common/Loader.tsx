/**
 * @file
 * @copyright 2022
 * @author jlsnow301 (https://github.com/jlsnow301)
 * @license ISC
 */
import { Box } from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';

export const Loader = (props) => {
  const { value } = props;

  return (
    <div className="AlertModal__Loader">
      <Box
        className="AlertModal__LoaderProgress"
        style={{ width: clamp01(value) * 100 + '%' }}
      />
    </div>
  );
};
