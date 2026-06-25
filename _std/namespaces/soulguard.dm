/// Used to track the state of the soulguard spell inside a living mob
CREATE_NAMESPACE(SOULGUARD)

/// No soulguard.
ADD_TO_NAMESPACE(SOULGUARD)(var/const/INACTIVE = 0)

/// Soulguard from a wizard's ability.
ADD_TO_NAMESPACE(SOULGUARD)(var/const/SPELL = 1)

/// Soulguard from a wizard ring.
ADD_TO_NAMESPACE(SOULGUARD)(var/const/RING = 2)

