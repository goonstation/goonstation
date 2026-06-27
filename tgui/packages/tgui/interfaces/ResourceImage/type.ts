export interface ResourceImageProps {
  title: string;
  path: string;
  fixed_size: ImgSize;
  scale_dir: number;
}

export interface ImgSize {
  width: number;
  height: number;
}
