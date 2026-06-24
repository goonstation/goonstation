/// Modes of operation for the RCD device.
CREATE_NAMESPACE(RCD_MODE)

/// Builds a floor on space tile, build wall on tile, renforce existing wall.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/FLOORSWALLS = 1)

/// Builds a door.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/AIRLOCK = 2)

/// Breaks stuff.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/DECONSTRUCT = 3)

/// Windows.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/WINDOWS = 4)

/// Control for pod doors. seemingly unused.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/PODDOORCONTROL = 5)

/// The pod doors that relate to the previous entry
ADD_TO_NAMESPACE(RCD_MODE)(var/const/PODDOOR = 6)

/// Round orbs of radiance.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/LIGHTBULBS = 7)

/// Long tubes of radiance.
ADD_TO_NAMESPACE(RCD_MODE)(var/const/LIGHTTUBES = 8)
