#define CAM_RANGE 7

// If an emitter ix updated withing X seconds, it will be put into the queue
#define CAM_UPDATE_COOLDOWN 1 SECONDS

// Every X seconds that the queue will be updated, if anything is in it
#define CAM_PROCESS_QUEUE_INTERVAL 5 SECONDS
// Every X seconds all the cameras will be forced to update
#define CAM_PROCESS_ALL_INTERVAL 60 SECONDS
