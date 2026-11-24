/// Powersink states
CREATE_NAMESPACE(POWERSINK)

/// Not operating, not connected
ADD_TO_NAMESPACE(POWERSINK)(var/const/OFF = 0)
/// Not operating, connected
ADD_TO_NAMESPACE(POWERSINK)(var/const/CLAMPED = 1)
/// Operating, connected
ADD_TO_NAMESPACE(POWERSINK)(var/const/OPERATING = 2)
