/obj/structure/conduit
	name = "God Conduit"
	desc = "Important stuff"
	anchored = TRUE
	max_integrity = 1000
	
	var/influence_radius = 2
	var/list/influences_list = list()

/obj/structure/conduit/Initialize(mapload)
	. = ..()
	for(var/turf/tile in range(influence_radius, src))
		if(!check_influence(tile))
			influences_list.Add(new /obj/effect/god_influence(tile))

/obj/structure/conduit/proc/check_influence(turf/tile)
	for(var/obj/effect/god_influence/influence in tile)
		return TRUE
	return FALSE

/obj/structure/conduit/Destroy()
	for(var/obj/effect/god_influence/influence in influences_list)
		qdel(influence)
	return ..()

/obj/structure/conduit/nexus
	name = "God Nexus"
	desc = "Important stuff"
	max_integrity = 10000

	influence_radius = 5

/obj/effect/god_influence
	name = "Influence"
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "generic_camera"

/obj/structure/blueprint
	name = "Toilet of the gods blueprint"
	desc = "for 5 gold you can assemble a toilet"
	anchored = TRUE
	var/result = /obj/structure/toilet
	var/list/requirements = list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/mineral/plasma)

	icon = 'icons/obj/cult/structures.dmi'
	icon_state = "tomealtar"

/obj/structure/blueprint/attackby(obj/item/I, mob/user)
	for(var/i in requirements)
		if(istype(I, i))
			if(!user.transferItemToLoc(I, src))
				return
			requirements.Remove(I.type)
			to_chat(user, span_notice("You insert [I] into the [src]"))
			if (requirements.len == 0)
				new result(loc)
				to_chat(user, span_notice("You completed the toilet summoning ritual"))
				qdel(src)
