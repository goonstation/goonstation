#define MOB_PROPERTY_ACTIVE_VALUE 1
#define MOB_PROPERTY_SOURCES_LIST 2

#define PROP_CANTMOVE "cantmove"

#define APPLY_MOB_PROPERTY(target, property, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
			if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _V) { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _V; \
			}; \
		} else { \
			_L[property] = list(_V, list(_S = _V)); \
		}; \
	} while (0)

#define GET_MOB_PROPERTY(target, property) (target.mob_properties[property] ? target.mob_properties[property][MOB_PROPERTY_ACTIVE_VALUE] : null)

// sliiiiiiiightly faster if you don't care about the value
#define HAS_MOB_PROPERTY(target, property) (target.mob_properties[property] ? TRUE : FALSE)

#define REMOVE_MOB_PROPERTY(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} else { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = 0; \
				for(var/_S in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
						_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
					} \
				} \
			} \
		} \
	} while (0)
