/obj/effect/powerup
	name = "power-up"
	icon = 'icons/effects/effects.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	/// How long in deciseconds it will take for the powerup to respawn, if no value it won't respawn
	var/respawn_time
	/// How long the powerup stays on the ground, if no value it will stay forever
	var/lifetime
	/// Message given when powerup is picked up
	var/pickup_message
	/// Sound played when powerup is picked up
	var/pickup_sound
	/// Cooldown for the powerup to respawn after it's been used
	COOLDOWN_DECLARE(respawn_cooldown)

/obj/effect/powerup/Initialize(mapload)
	. = ..()
	if(lifetime)
		QDEL_IN(src, lifetime)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/powerup/proc/on_entered(datum/source, atom/movable/movable_atom)
	SIGNAL_HANDLER
	trigger(movable_atom)

/obj/effect/powerup/Bump(atom/bumped_atom)
	trigger(bumped_atom)

/obj/effect/powerup/Bumped(atom/movable/movable_atom)
	trigger(movable_atom)

/// Triggers the effect of the powerup on the target, returns FALSE if the target is not /mob/living, is dead or the cooldown hasn't finished, returns TRUE otherwise
/obj/effect/powerup/proc/trigger(mob/living/target)
	if(!istype(target) || target.stat == DEAD)
		return FALSE
	if(respawn_time)
		if(!COOLDOWN_FINISHED(src, respawn_cooldown))
			return FALSE
		COOLDOWN_START(src, respawn_cooldown, respawn_time)
		alpha = 100
		addtimer(VARSET_CALLBACK(src, alpha, initial(alpha)), respawn_time)
	else
		qdel(src)
	if(pickup_message)
		to_chat(target, span_notice("[pickup_message]"))
	if(pickup_sound)
		playsound(get_turf(target), pickup_sound, 50, TRUE, -1)
	return TRUE

/obj/effect/powerup/health
	name = "health pickup"
	desc = "Blessing from the havens."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "backpack-medical"
	respawn_time = 30 SECONDS
	pickup_message = "Health restored!"
	pickup_sound = 'sound/magic/staff_healing.ogg'
	/// How much the pickup heals when picked up
	var/heal_amount = 50
	/// Does this pickup fully heal when picked up
	var/full_heal = FALSE
	/// If full heal, what flags do we pass?
	var/heal_flags = HEAL_ALL

/obj/effect/powerup/health/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	if(full_heal)
		target.fully_heal(heal_flags)
	else if(heal_amount)
		target.heal_ordered_damage(heal_amount, list(BRUTE, BURN))

/obj/effect/powerup/health/full
	name = "mega health pickup"
	desc = "Now this is what I'm talking about."
	icon_state = "duffel-medical"
	full_heal = TRUE

/obj/effect/powerup/ammo
	name = "ammo pickup"
	desc = "You like revenge, right? Everybody likes revenge! Well, let's go get some!"
	icon = 'icons/obj/storage/toolbox.dmi'
	icon_state = "ammobox"
	respawn_time = 30 SECONDS
	pickup_message = "Ammunition reloaded!"
	pickup_sound = 'sound/weapons/gun/shotgun/rack.ogg'

/obj/effect/powerup/ammo/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun in target.get_all_contents())
		if(!isgun(gun) && !istype(gun, /obj/item/flamethrower))
			continue
		SEND_SIGNAL(gun, COMSIG_ITEM_RECHARGED)

/obj/effect/powerup/ammo/ctf
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"
	respawn_time = FALSE
	lifetime = 30 SECONDS

/obj/effect/powerup/speed
	name = "Lightning Orb"
	desc = "You feel faster just looking at it."
	icon_state = "speed"
	pickup_sound = 'sound/magic/lightningshock.ogg'

/obj/effect/powerup/speed/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	target.apply_status_effect(/datum/status_effect/lightningorb)

/obj/effect/powerup/mayhem
	name = "Orb of Mayhem"
	desc = "You feel angry just looking at it."
	icon_state = "impact_laser"

/obj/effect/powerup/mayhem/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	target.apply_status_effect(/datum/status_effect/mayhem)

/obj/effect/powerup/bomberman
	pickup_sound = 'sound/magic/lightningshock.ogg' //Pick something better
	icon_state = "speed" //Temp for testing

/obj/effect/powerup/bomberman/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	target.balloon_alert_to_viewers(name)

/obj/effect/powerup/bomberman/speed
	name = "speed up"
	desc = "Makes you slightly faster."

/obj/effect/powerup/bomberman/speed/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	if (target.has_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/fourth)) 
		return
	if (target.has_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/third))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/third)
		target.add_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/fourth)
		return
	if (target.has_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/second))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/second)
		target.add_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/third)
		return
	if (target.has_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/first))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/first)
		target.add_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/second)
		return
	target.add_movespeed_modifier(/datum/movespeed_modifier/bomberman_speed/first)//WHO ON EARTH LET ME COOK
	
/datum/movespeed_modifier/bomberman_speed

/datum/movespeed_modifier/bomberman_speed/first //Turning tracking how many boosts you have into a component would be better but too bad.
	multiplicative_slowdown = -0.15

/datum/movespeed_modifier/bomberman_speed/second
	multiplicative_slowdown = -0.3

/datum/movespeed_modifier/bomberman_speed/third
	multiplicative_slowdown = -0.45

/datum/movespeed_modifier/bomberman_speed/fourth
	multiplicative_slowdown = -0.6

/obj/effect/powerup/bomberman/fire
	name = "robustness up"
	desc = "Makes your toolboxes stronger."

/obj/effect/powerup/bomberman/fire/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	for(var/obj/item/storage/toolbox in target)
		if(toolbox.force < 16)
			toolbox.force++
			//Visual effect
		
/obj/effect/powerup/bomberman/bomb
	name = "toolbox up"
	desc = "Gives you another toolbox."

/obj/effect/powerup/bomberman/bomb/trigger(mob/living/target)
	. = ..()
	if(!.)
		return
	var/toolbox = new /obj/item/storage/toolbox(target.loc)
	target.put_in_hands(toolbox)
	
	