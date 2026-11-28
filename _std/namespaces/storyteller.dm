// Storyteller Namespaces, to be expanded upon

CREATE_NAMESPACE(STORYTELLER)
CREATE_NAMESPACE(STORYTELLER, FLAGS)

/// Storyteller will try and keep antag count at/above an expected threshold
ADD_TO_NAMESPACE(STORYTELLER, FLAGS)(var/const/ANTAG_THRESHOLD = (1<<0))
/// Storyteller will try and balance security to antag ratio
ADD_TO_NAMESPACE(STORYTELLER, FLAGS)(var/const/SEC_CHECK = (1<<1))
