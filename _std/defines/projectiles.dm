
//pass flags
#define PROJ_PASSNONE			0x000
#define PROJ_PASSWALL			0x001
#define PROJ_PASSOBJ			0x002

//pass flags on hit thing take priotity if they exist
#define PROJ_ATOM_PASSTHROGH	0x100
#define PROJ_ATOM_CANNOT_PASS	0x200
#define PROJ_OBJ_HIT_OTHER_OBJS	0x400




//Projectile damage type defines
#define D_KINETIC 1
#define D_PIERCING 2
#define D_SLASHING 4
#define D_ENERGY 8
#define D_BURNING 16
#define D_RADIOACTIVE 32
#define D_TOXIC 48
#define D_SPECIAL 128

//Projectile reflection defines
#define PROJ_NO_HEADON_BOUNCE 1
#define PROJ_HEADON_BOUNCE 2
#define PROJ_RAPID_HEADON_BOUNCE 3

//default max range for 'unlimited' range projectiles
#define PROJ_INFINITE_RANGE 500
