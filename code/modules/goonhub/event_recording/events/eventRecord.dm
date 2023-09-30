

/// Base eventCall type
/// Represents a predefined event we can send to the Goonhub event recorder
/// SECURITY: Sanitization occurs right before output
/datum/eventRecord
	/// The type of the event being recorded, for example `death`
	var/eventType = null
	/// Body of the event
	var/datum/eventRecordBody/body = null
