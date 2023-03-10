// Component defines for datums.

// --- datum signals ---

	/// when a component is added to a datum: (/datum/component)
	#define COMSIG_COMPONENT_ADDED "component_added"
	/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
	#define COMSIG_COMPONENT_REMOVING "component_removing"
	/// just before a datum's disposing()
	#define COMSIG_PARENT_PRE_DISPOSING "parent_pre_disposing"

// ---- mind signals ----

	/// when a mind attaches to a mob (mind, mob)
	#define COMSIG_MIND_ATTACH_TO_MOB "mind_attach_to_mob"
	/// when a mind detaches from a mob (mind, mob)
	#define COMSIG_MIND_DETACH_FROM_MOB "mind_detach_from_mob"
	/// when a mind should update the contents of its memory
	#define COMSIG_MIND_UPDATE_MEMORY "update_dynamic_player_memory"

// ---- area signals ----

	/// area's active var set to true (when a client enters)
	#define COMSIG_AREA_ACTIVATED "area_activated"
	/// area's active var set to false (when all clients leave)
	#define COMSIG_AREA_DEACTIVATED "area_deactivated"

// ---- TGUI signals ----
	/// A TGUI window was opened by a user (receives tgui datum)
	#define COMSIG_TGUI_WINDOW_OPEN "tgui_window_open"

// ---- reagents signals ----
	/// When reagent scanned
	#define COMSIG_REAGENTS_ANALYZED "reagents_analyzed"
