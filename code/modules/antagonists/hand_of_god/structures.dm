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
				Destroy()
