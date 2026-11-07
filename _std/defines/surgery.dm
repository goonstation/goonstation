#define SURGERY_NONE 0
/// surgery requires a scalpel or other cutting tool
#define SURGERY_CUTTING (1 << 1)
/// surgery requires a pair of scissors or other sniping tool
#define SURGERY_SNIPPING (1 << 2)
/// surgery requires a saw or other sawing tool
#define SURGERY_SAWING (1 << 3)

#define RIBS 0
#define SUBCOSTAL 1
#define ABDOMINAL 2
#define FLANKS 3

#define REGION_CLOSED 0
#define REGION_HALFWAY 1
#define REGION_OPENED 2

#define BACK_SURGERY_CLOSED 0
#define BACK_SURGERY_STEP_ONE 1
#define BACK_SURGERY_STEP_TWO 2
#define BACK_SURGERY_OPENED 3

#define LIMB_REMOVE_STAGE_SECURE 0 // The limb is secure and has not been cut
#define LIMB_REMOVE_STAGE_CUT 1	// Surgery has cut the limb but it is not loose
#define LIMB_REMOVE_STAGE_LOOSE 2 // The limb is loose (ie: could fall off!)
