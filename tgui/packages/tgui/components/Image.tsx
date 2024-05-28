import { InfernoNode } from 'inferno';
import { BoxProps, computeBoxProps } from './Box';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  fixBlur: boolean; // true is default, this is an ie thing
  objectFit: 'contain' | 'cover'; // fill is default
  tooltip: InfernoNode;
}> &
  IconUnion &
  BoxProps;

// at least one of these is required
type IconUnion =
  | {
      className?: string;
      src: string;
    }
  | {
      className: string;
      src?: string;
    };

/** Image component. Use this instead of Box as="img". */
export const Image = (props: Props) => {
  const { className, fixBlur = true, objectFit = 'fill', src, tooltip, ...rest } = props;

  const computedStyle = {
    ...computeBoxProps(rest).style,
    '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
    objectFit,
  };

  let content = <img className={className} src={src} style={computedStyle} />;

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  return content;
};
