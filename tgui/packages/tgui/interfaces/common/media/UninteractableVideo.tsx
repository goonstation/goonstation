/**
 * @file
 * @copyright 2026
 * @author ANNmagedon (https://github.com/Annmagedon)
 * @license MIT
 */

import { GenericVisualMediaProps } from './types';

export const UninteractableVideoPlayer: React.FC<
  GenericVisualMediaProps & React.VideoHTMLAttributes<HTMLVideoElement>
> = ({ src, style, ...rest }) => {
  return (
    <video
      src={src}
      muted
      loop
      autoPlay
      playsInline
      style={{ ...style, pointerEvents: 'none' }}
      tabIndex={-1}
      {...rest}
    />
  );
};
