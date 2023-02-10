#define CAM_RANGE 7

// If an emitter is updated withing X seconds, it will be put into the queue
#define CAM_UPDATE_COOLDOWN 1 SECONDS
// IF a turf is updated withing X seconds, it will be put into the queue
#define CAM_TURF_UPDATE_COOLDOWN 1 SECONDS

// Every X seconds that the queue will be updated
#define CAM_PROCESS_QUEUE_INTERVAL 2 SECONDS
// Every X seconds that the turf queue will be processed
#define CAM_PROCESS_QUEUE_TURF_INTERVAL 2 SECONDS
// Every X seconds all the cameras will be forced to update
#define CAM_PROCESS_ALL_INTERVAL 20 SECONDS
