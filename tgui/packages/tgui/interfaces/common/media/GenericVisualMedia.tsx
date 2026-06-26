/**
 * @file
 * @copyright 2026
 * @author ANNmagedon (https://github.com/Annmagedon)
 * @license MIT
 */
import { GenericVisualMediaProps } from './types';
import { UninteractableVideoPlayer } from './UninteractableVideo';

const VIDEO_EXTENSIONS: Set<string> = new Set([
  'mp4',
  'm4v',
  'webm',
  'ogv',
  'mov',
  'mkv',
  'wmv',
  'avi',
  'flv',
  '3gp',
  'ts',
  'mts',
  'm2ts',
  'asf',
  'apng',
] as const);

// (?:         # begin non-capturing group
//   \.        #   a dot
//   (         #   begin capturing group (captures the actual extension)
//     [^.]+   #     anything except a dot, multiple times
//   )         #   end capturing group
// )?          # end non-capturing group, make it optional
// $           # anchor to the end of the string
// courtesy of https://stackoverflow.com/users/18771/tomalak
const FILE_EXTENTION_REGEX = /(?:\.([^.]+))?$/;

export const GenericVisualMedia: React.FC<
  React.HTMLAttributes<HTMLElement> & GenericVisualMediaProps
> = ({ src, ...rest }) => {
  return isVideo(src) ? (
    <UninteractableVideoPlayer src={src} {...rest} />
  ) : (
    <img src={src} {...rest} />
  );
};

const isVideo = (source: string): boolean => {
  const normalizedExtention = FILE_EXTENTION_REGEX.exec(source)?.pop();

  return normalizedExtention
    ? VIDEO_EXTENSIONS.has(normalizedExtention)
    : false;
};
