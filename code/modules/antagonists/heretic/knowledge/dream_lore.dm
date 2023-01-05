/**
 * # The path of Dreams.
 *
 * Goes as follows:
 */

/datum/heretic_knowledge/limited_amount/starting/base_dream
	name = "Placeholder Toilet Thing"
	desc = "Opens up the path of placeholder toilets to you. \
		Allows you to transmute a knife with a toilet to create a loaf of bread. \
		You can create up to thirty seven at a time."
	gain_text = "Our great ancestors forged swords and practiced sparring on the eve of great battles."
	next_knowledge = list(/datum/heretic_knowledge/dream_grasp)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/structure/toilet = 1,
	)
	result_atoms = list(/obj/item/food/bread/plain)
	limit = 37
	route = PATH_DREAM

/datum/heretic_knowledge/dream_grasp
	name = "Grasp of Dreams"
	desc = "Your Mansus Grasp will cause a short stun when used on someone lying down or facing away from you."
	gain_text = "The story of the footsoldier has been told since antiquity. It is one of blood and valor, \
		and is championed by sword, steel and silver."
//	next_knowledge = list(/datum/heretic_knowledge/blade_dance)
	cost = 1
	route = PATH_DREAM

/datum/heretic_knowledge/dream_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/dream_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/dream_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

//	target.set_eye_blur_if_lower(0.5 SECONDS)

	var/datum/client_colour/colour = target.add_client_colour(/datum/client_colour/dreams)
	QDEL_IN(colour, 20.1 SECONDS)

	target.cause_hallucination( \
		/datum/hallucination/delusion/custom, \
		"Grasp of Dreams", \
		duration = 30 SECONDS, \
		affects_us = TRUE, \
		affects_others = TRUE, \
		skip_nearby = FALSE, \
		play_wabbajack = FALSE, \
	)

//	to_chat(target, span_danger("A bright green light burns your eyes horrifically!"))
