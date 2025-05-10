#define APPLY_MOVEMENT_MODIFIER(target, modifier, source) \
	do { \
		var/list/_L = target.movement_modifiers; \
		if (_L[modifier]) { \
			_L[modifier] |= source; \
		} else { \
			_L[modifier] = list(source); \
		} \
		target.update_movement_modifiers(); \
	} while (0)

#define REMOVE_MOVEMENT_MODIFIER(target, modifier, sources) \
	do { \
		var/list/_L = target.movement_modifiers; \
		if (_L[modifier]) { \
			_L[modifier] -= sources; \
			if (!length(_L[modifier])) { \
				_L -= modifier \
			}; \
		} \
		target.update_movement_modifiers(); \
	} while (0)
