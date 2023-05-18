//For food that can be wrapped with a candy wrapper, disables decomposition upon being wrapped, re-enables it on unwrapping

/datum/component/wrappable
	var/wrapped = FALSE
	var/datum/component/edible/edible_component_ref
	var/datum/component/decomposition/decomposition_ref

/datum/component/wrappable/Initialize(...)
	if(!IsEdible(parent))
		return COMPONENT_INCOMPATIBLE
	edible_component_ref = parent.GetComponent(/datum/component/edible)
	decomposition_ref = parent.GetComponent(/datum/component/decomposition)
	RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(wrap))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(unwrap))
	
/datum/component/wrappable/proc/wrap(obj/target, obj/item/attacking_item, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(wrapped)
		return
	if(istype(attacking_item, /obj/item/stack/candy_wrapper))
		if(!proximity_flag)
			return
		var/obj/item/stack/candy_wrapper/wrapper = attacking_item
		if(!wrapper.use(1))
			return
		wrapped = TRUE
		edible_component_ref.inedible = TRUE
		//Todo - Visual changes
		if(isnull(decomposition_ref))
			return
		decomposition_ref.paused = TRUE
		decomposition_ref.remove_timer()

/datum/component/wrappable/proc/unwrap(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!wrapped)
		return
	wrapped = FALSE
	edible_component_ref.inedible = FALSE
	//Todo play a sound
	//Todo Visual changes
	if(isnull(decomposition_ref))
		return
	decomposition_ref.paused = FALSE
