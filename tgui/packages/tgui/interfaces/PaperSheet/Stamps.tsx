import { useEffect, useMemo, useState } from 'react';
import { Box } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';

const WINDOW_TITLEBAR_HEIGHT = 30;

interface PaperSheetStamperProps {
  value: string;
  stampClass: string;
  stamps: Array<Array<string>>;
}

export const PaperSheetStamper: React.FC<PaperSheetStamperProps> = ({
  value,
  stampClass,
  stamps,
}) => {
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [rotate, setRotate] = useState(0);

  const findStampPosition = (e: MouseEvent) => {
    const windowRef = document.querySelector('.Layout__content');
    if (!windowRef) {
      return;
    }
    let rotating = false;
    if (e.shiftKey) {
      rotating = true;
    }

    const stamp = document.getElementById('stamp');
    if (stamp) {
      const stampHeight = stamp.clientHeight;
      const stampWidth = stamp.clientWidth;

      const currentHeight = rotating
        ? y
        : e.pageY + windowRef.scrollTop - stampHeight;
      const currentWidth = rotating ? x : e.pageX - stampWidth / 2;

      const widthMin = 0;
      const heightMin = 0;

      const widthMax = windowRef.clientWidth - stampWidth;
      const heightMax =
        windowRef.clientHeight + windowRef.scrollTop - stampHeight;

      const radians = Math.atan2(
        e.pageX - currentWidth,
        e.pageY - currentHeight,
      );

      const newRotate = rotating ? radians * (180 / Math.PI) * -1 : rotate;

      return [
        clamp(currentWidth, widthMin, widthMax),
        clamp(currentHeight, heightMin, heightMax),
        newRotate,
      ];
    }
  };

  const handleMouseMove = (e: MouseEvent) => {
    const pos = findStampPosition(e);
    if (!pos) {
      return;
    }
    // center offset of stamp & rotate
    pauseEvent(e);
    setX(pos[0]);
    setY(pos[1]);
    setRotate(pos[2]);
  };

  const handleMouseClick = (e: MouseEvent) => {
    if (e.pageY <= WINDOW_TITLEBAR_HEIGHT) {
      return;
    }
    const { act } = useBackend();
    const stampObj = {
      x,
      y,
      r: rotate,
    };
    act('stamp', stampObj);
  };

  useEffect(() => {
    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('click', handleMouseClick);

    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('click', handleMouseClick);
    };
  }, [x, y, rotate]);

  const stampList = stamps || [];
  const currentPos = {
    sprite: stampClass,
    x,
    y,
    rotate,
  };

  return (
    <>
      <PaperSheetView readOnly value={value} stamps={stampList} />
      <Stamp activeStamp opacity={0.5} image={currentPos} />
    </>
  );
};

interface StampProps {
  image: {
    x: number;
    y: number;
    rotate: number;
    sprite: string;
  };
  opacity?: number;
  activeStamp?: boolean;
}

const Stamp: React.FC<StampProps> = (props) => {
  const stampTransform = {
    left: props.image.x + 'px',
    top: props.image.y + 'px',
    transform: 'rotate(' + props.image.rotate + 'deg)',
    opacity: props.opacity || 1.0,
  };
  return props.image.sprite.match('stamp-.*') ? (
    <img
      id={props.activeStamp ? 'stamp' : undefined}
      style={stampTransform}
      className="paper__stamp"
      src={resolveAsset(props.image.sprite)}
    />
  ) : (
    <Box
      id={props.activeStamp ? 'stamp' : undefined}
      style={stampTransform}
      className="paper__stamp-text"
    >
      {props.image.sprite}
    </Box>
  );
};

const pauseEvent = (e: MouseEvent) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

const setInputReadonly = (text, readonly) => {
  return readonly
    ? text.replace(/<input\s[^d]/g, '<input disabled ')
    : text.replace(/<input\sdisabled\s/g, '<input ');
};

export const PaperSheetView = (props) => {
  const { value = '', stamps = [], backgroundColor, readOnly } = props;
  const stampList = stamps || [];
  const textHtml = useMemo(
    () => ({
      __html: `<span class="paper-text">${setInputReadonly(value, readOnly)}</span>`,
    }),
    [readOnly, value],
  );
  return (
    <Box
      className="paper__page"
      position="relative"
      backgroundColor={backgroundColor}
      width="100%"
      height="100%"
    >
      <Box
        color="black"
        backgroundColor={backgroundColor}
        fillPositionedParent
        width="100%"
        height="100%"
        dangerouslySetInnerHTML={textHtml}
        p="10px"
      />
      {stampList.map((o, i) => (
        <Stamp
          key={o[0] + i}
          image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3] }}
        />
      ))}
    </Box>
  );
};
