// camera coverage

///How far cameras can see
#define CAM_RANGE 7

///If an emitter is updated within X seconds, it will be put into the queue
#define CAM_UPDATE_COOLDOWN 1 SECONDS
///If a turf is updated within X seconds, it will be put into the queue
#define CAM_TURF_UPDATE_COOLDOWN 1 SECONDS

///Every X seconds that the queue will be updated
#define CAM_PROCESS_QUEUE_INTERVAL 2 SECONDS
///Every X seconds that the turf queue will be processed
#define CAM_PROCESS_QUEUE_TURF_INTERVAL 2 SECONDS
///Every X seconds all the cameras will be forced to update
#define CAM_PROCESS_ALL_INTERVAL 20 SECONDS

// camera networks

/// Station security cameras
#define CAMERA_NETWORK_STATION	"station"
/// Public cameras anyone can view
#define CAMERA_NETWORK_PUBLIC	"public"
/// Cameras inside robots
#define CAMERA_NETWORK_ROBOTS	"robots"
/// Rancher's cameras
#define CAMERA_NETWORK_RANCH	"ranch"
/// Mining outpost cameras (asteroid)
#define CAMERA_NETWORK_MINING	"mining"
/// Science outpost cameras
#define CAMERA_NETWORK_SCIENCE	"science"
/// Cameras in V-Space
#define CAMERA_NETWORK_VSPACE	"vspace"
/// Telesci exploration cameras
#define CAMERA_NETWORK_TELESCI	"telesci"
/// Spy sticker cameras
#define CAMERA_NETWORK_STICKERS	"stickers"
/// Cargo routing cameras
#define CAMERA_NETWORK_CARGO	"cargo"
/// AI-only cameras
#define CAMERA_NETWORK_AI_ONLY	"ai"
