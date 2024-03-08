/// Base eventCall type
/// Represents a predefined event we can send to the Goonhub event recorder
/// SECURITY: Sanitization occurs right before output
/datum/eventRecord
	/// The type of the event being recorded, for example `death`
	var/eventType = null
	/// Body of the event
	var/datum/eventRecordBody/body = null

	/// Shortcut method to send this event to the event recorder
	proc/send(list/fieldValues)
		if (!eventRecorder) return
		try
			src.body = new src.body(fieldValues)
			eventRecorder.add(src)
		catch (var/exception/e)
			var/logMsg = "Failed to send data to Goonhub Event Recording service. Reason: [e.name]. Type: [eventType]. Values: [json_encode(fieldValues)]"
			logTheThing(LOG_DEBUG, null, " <b>Event Recorder:</b> [logMsg]")
			logTheThing(LOG_DIARY, null, "Event Recorder: [logMsg]", "debug")

	/// Override to build event parameters
	proc/buildAndSend()
		return
