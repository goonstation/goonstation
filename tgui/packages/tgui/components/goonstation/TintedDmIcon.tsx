import { type ComponentProps, useId } from 'react';
import { hexToRgba } from 'tgui-core/color';
import { DmIcon } from 'tgui-core/components';

type TintedDmIconProps = ComponentProps<typeof DmIcon> & {
  /** Hex color (`#RGBA` or `#RRGGBBAA`, optional alpha), see `ICON_MULTIPLY` */
  tint?: string | null;
};

/** A color-tinted `DmIcon` */
export const TintedDmIcon = (props: TintedDmIconProps) => {
  const { tint, style, ...rest } = props;
  const filterId = useId();
  if (!tint) {
    return <DmIcon style={style} {...rest} />;
  }
  const { r, g, b, a } = hexToRgba(tint);
  return (
    <>
      {/* SVG filter to keep pixelated edges */}
      <svg width="0" height="0" style={{ position: 'absolute' }}>
        {/* sRGB 💀 */}
        <filter id={filterId} colorInterpolationFilters="sRGB">
          <feColorMatrix
            type="matrix"
            values={`${r / 255} 0 0 0 0 0 ${g / 255} 0 0 0 0 0 ${b / 255} 0 0 0 0 0 ${a} 0`}
          />
        </filter>
      </svg>
      <DmIcon style={{ ...style, filter: `url(#${filterId})` }} {...rest} />
    </>
  );
};
