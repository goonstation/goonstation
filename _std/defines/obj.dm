//object_flags
#define BOTS_DIRBLOCK 			 (1<<0)	//bot considers this solid object that can be opened with a Bump() in pathfinding DirBlockedWithAccess
#define NO_ARM_ATTACH 			 (1<<1)	//illegal for arm attaching
#define CAN_REPROGRAM_ACCESS (1<<2)	//access gun can reprog

//materials
#define MATERIAL_CRYSTAL 1 //Crystals, Minerals
#define MATERIAL_METAL 2   //Metals
#define MATERIAL_CLOTH 4   //Cloth or cloth-like
#define MATERIAL_ORGANIC 8 //Coal, meat and whatnot.
#define MATERIAL_ENERGY 16 //Is energy or outputs energy.
#define MATERIAL_RUBBER 32 //Rubber , latex etc

#define MATERIAL_ALPHA_OPACITY 190 //At which alpha do opague objects become see-through?

