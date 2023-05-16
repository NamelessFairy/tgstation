//For food that can be wrapped with a candy wrapper, disables decomposition upon being wrapped

/datum/component/wrappable

/datum/component/wrappable/Initialize(...)
	if(!IsEdible(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(after_attack_by))
	
/datum/component/wrappable/proc/after_attack_by(obj/target)
	if(istype(target, ))
