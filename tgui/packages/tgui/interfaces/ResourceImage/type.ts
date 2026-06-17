import { BooleanLike } from 'tgui-core/react';

export interface ResourceImageProps {
  title: string;
  path: string;
  fixed_size: ImgSize;
  scaled?: BooleanLike;
}

export interface ImgSize {
  width: number;
  height: number;
}
