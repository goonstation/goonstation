
export interface PaperSheetData {
  name?: string;
  editMode: number;
  sizeX: number;
  sizeY: number;
  text: string;
  paperColor: string;
  penColor: string;
  stampClass: string;
  stamps: [string, number, number, number]
}
