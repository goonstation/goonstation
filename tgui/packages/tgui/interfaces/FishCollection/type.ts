/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

export interface FishCollectionData {
  fish_data: FishData[];
  collected: string[];
}

export enum CollectionType {
  Never = 0,
  Normal = 1,
  Secret = 2,
}

export interface FishData {
  name: string;
  image: string;
  silhouette: string;
  collection: CollectionType;
}
