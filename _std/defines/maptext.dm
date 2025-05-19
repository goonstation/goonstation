//------------ Primary Macros ------------//
/// A constructor macro for `/image/maptext`.
#define NEW_MAPTEXT(PATH, ARGS...)	(new PATH):init(##ARGS)

/// Displays the provided maptext type on the `ORIGIN` atom to each client in the `RECIPIENTS` list.
#define DISPLAY_MAPTEXT(ORIGIN, RECIPIENTS, RECIPIENT_FUNCTION, MAPTEXT_TYPE, MAPTEXT_ARGS...) \
	var/atom/_ORIGIN = ORIGIN; \
	RECIPIENT_FUNCTION(RECIPIENTS) \
	if (length(_RECIPIENTS)) { \
		_ORIGIN.maptext_manager ||= new /atom/movable/maptext_manager(_ORIGIN); \
		for (var/client/_C as anything in _RECIPIENTS) { \
			_ORIGIN.maptext_manager.add_maptext(_C, NEW_MAPTEXT(MAPTEXT_TYPE, ##MAPTEXT_ARGS)); \
		} \
	}


//------------ Recipient Functions ------------//
/// Do not manipulate the `RECIPIENTS` list, and iterate throught it as is.
#define MAPTEXT_CLIENT_RECIPIENTS_ONLY(RECIPIENTS) \
	var/list/client/_RECIPIENTS = RECIPIENTS;

/// If any clients in the `RECIPIENTS` list have observers, add them to the list too.
#define MAPTEXT_CLIENT_RECIPIENTS_WITH_OBSERVERS(RECIPIENTS) \
	var/list/client/_RECIPIENTS = RECIPIENTS; \
	for (var/client/_C as anything in RECIPIENTS) { \
		for (var/mob/dead/target_observer/_O as anything in _C.mob.observers) { \
			if (!_O.client) { \
				continue; \
			} \
			_RECIPIENTS += _O.client; \
		} \
	}

/// Create a new `RECIPIENTS` list with the clients of the passed mobs and their observers.
#define MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS(RECIPIENTS) \
	var/list/client/_RECIPIENTS = list(); \
	for (var/mob/_M as anything in RECIPIENTS) { \
		if (_M.client) { \
			_RECIPIENTS += _M.client; \
		} \
		for (var/mob/dead/target_observer/_O as anything in _M.observers) { \
			if (_O.client) { \
				_RECIPIENTS += _O.client; \
			} \
		} \
	}

/// Create a new `RECIPIENTS` list with the clients of the passed minds and their observers.
#define MAPTEXT_MIND_RECIPIENTS_WITH_OBSERVERS(RECIPIENTS) \
	var/list/client/_RECIPIENTS = list(); \
	for (var/datum/mind/_M as anything in RECIPIENTS) { \
		if (!_M.current) { \
			continue; \
		} \
		if (_M.current.client) { \
			_RECIPIENTS += _M.current.client; \
		} \
		for (var/mob/dead/target_observer/_O as anything in _M.current.observers) { \
			if (_O.client) { \
				_RECIPIENTS += _O.client; \
			} \
		} \
	}
