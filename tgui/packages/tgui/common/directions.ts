export enum ByondDir {
  None = 0,
  North = 1,
  South = 2,
  East = 4,
  West = 8,
  Northeast = 5,
  Northwest = 9,
  Southeast = 6,
  Southwest = 10,
  Up = 16,
  Down = 32,
}

/** /proc/dir2angle - keep in mind NORTH is 0deg! */
export const DIR_TO_ANGLE: Record<ByondDir, number> = {
  [ByondDir.None]: 0,
  [ByondDir.North]: 0,
  [ByondDir.South]: 180,
  [ByondDir.East]: 90,
  [ByondDir.West]: 270,
  [ByondDir.Northeast]: 45,
  [ByondDir.Northwest]: 315,
  [ByondDir.Southeast]: 135,
  [ByondDir.Southwest]: 225,
  [ByondDir.Up]: 0, // Not applicable for 2D rotations
  [ByondDir.Down]: 180, // Not applicable for 2D rotations
};
