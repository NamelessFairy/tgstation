#define WHITE_TEAM "White"
#define RED_TEAM "Red"
#define BLUE_TEAM "Blue"
#define GREEN_TEAM "Green"
#define YELLOW_TEAM "Yellow"
#define FLAG_RETURN_TIME 200 // 20 seconds
#define INSTAGIB_RESPAWN 50 //5 seconds
#define DEFAULT_RESPAWN 150 //15 seconds

//ToDo comment whatever vars I leave behind (btw maintainers I'm guarateed to forget to do this 🐈)
//ITS ATTEMPT TWO TIME
/obj/machinery/capture_the_flag
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/game_id = CTF_GHOST_CTF_GAME_ID
	//Todo Comment this
	var/datum/ctf_controller/ctf_game

/obj/machinery/capture_the_flag/Initialize(mapload)
	. = ..()
	ctf_game = GLOB.ctf_games[game_id]

/obj/machinery/capture_the_flag/spawner
	var/team = WHITE_TEAM
	var/team_span = ""
	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>"
	var/respawn_cooldown = DEFAULT_RESPAWN
	///assoc list for classes. If there's only one, it'll just equip. Otherwise, it lets you pick which outfit!
	var/list/ctf_gear = list("Rifleman" = /datum/outfit/ctf, "Assaulter" = /datum/outfit/ctf/assault, "Marksman" = /datum/outfit/ctf/marksman)
	var/list/instagib_gear = list("Instagib" = /datum/outfit/ctf/instagib)
	var/list/default_gear
	var/ammo_type = /obj/effect/powerup/ammo/ctf
	// Fast paced gameplay, no real time for burn infections.
	var/player_traits = list(TRAIT_NEVER_WOUNDED)

/obj/machinery/capture_the_flag/spawner/Initialize(mapload)
	. = ..()
//	ctf_game.add_team(src)
	GLOB.ctf_panel.ctf_machines += src
	SSpoints_of_interest.make_point_of_interest(src)
	default_gear = ctf_gear

/obj/machinery/capture_the_flag/spawner/Destroy()
	GLOB.ctf_panel.ctf_machines -= src
	return ..()

/obj/machinery/capture_the_flag/spawner/red
	name = "Red CTF Controller"
	icon_state = "syndbeacon"
	team = RED_TEAM
	team_span = "redteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/red, "Assaulter" = /datum/outfit/ctf/assault/red, "Marksman" = /datum/outfit/ctf/marksman/red)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/red/instagib)

/obj/machinery/capture_the_flag/spawner/blue
	name = "Blue CTF Controller"
	icon_state = "bluebeacon"
	team = BLUE_TEAM
	team_span = "blueteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/blue, "Assaulter" = /datum/outfit/ctf/assault/blue, "Marksman" = /datum/outfit/ctf/marksman/blue)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/blue/instagib)

//Green and yellow teams here

/obj/machinery/capture_the_flag/spawner/attack_ghost(mob/user)
	if(ctf_game.ctf_enabled == FALSE)
		if(user.client && user.client.holder)
			var/response = tgui_alert(user, "Enable this CTF game?", "CTF", list("Yes", "No"))
			if(response == "Yes")
				//Toggle CTF code here
			return
		
		if(!(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME))
			to_chat(user, span_warning("CTF has been temporarily disabled by admins."))
			return
		get_ctf_voting_controller(game_id).vote(user)
		return
	if(!SSticker.HasRoundStarted())
		return

	var/datum/component/ctf_player/ctf_player = user?.mind.GetComponent(/datum/component/ctf_player)
	//Insert code to check if spawning is valid here
	var/client/new_team_member = user.client
	//if(user.mind && user.mind.current)  Todo: Check what this does
	//		ctf_dust_old(user.mind.current)
	spawn_team_member(new_team_member)

/obj/machinery/capture_the_flag/spawner/Topic(href, href_list)
	if(href_list["join"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/capture_the_flag/spawner/proc/spawn_team_member(client/new_team_member)
	var/datum/outfit/chosen_class

	if(ctf_gear.len == 1) //no choices to make
		for(var/key in ctf_gear)
			chosen_class = ctf_gear[key]
	
	else //There's a choice to make, present a radial menu
		var/list/display_classes = list()

		for(var/key in ctf_gear)
			var/datum/outfit/ctf/class = ctf_gear[key]
			var/datum/radial_menu_choice/option = new
			option.image  = image(icon = initial(class.icon), icon_state = initial(class.icon_state))
			option.info = "<span class='boldnotice'>[initial(class.class_description)]</span>"
			display_classes[key] = option
		
		sort_list(display_classes)
		var/choice = show_radial_menu(new_team_member.mob, src, display_classes, radius = 38)
		if(!choice || !(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME) || !isobserver(new_team_member.mob) || ctf_game.ctf_enabled == FALSE)
			return
		
		chosen_class = ctf_gear[choice]

	var/turf/spawn_point = pick(get_adjacent_open_turfs(get_turf(src)))
	var/mob/living/carbon/human/player_mob = new(spawn_point)
	new_team_member.prefs.safe_transfer_prefs_to(player_mob, is_antag = TRUE)
	if(player_mob.dna.species.outfit_important_for_life)
		player_mob.set_species(/datum/species/human)
	player_mob.key = new_team_member.key
	player_mob.faction += team
	player_mob.equipOutfit(chosen_class)
	RegisterSignal(player_mob, COMSIG_PARENT_QDELETING, PROC_REF(ctf_qdelled_player)) //just in case CTF has some map hazards (read: chasms). bit shorter than dust
	player_mob.add_traits(player_traits, CAPTURE_THE_FLAG_TRAIT)

/obj/machinery/capture_the_flag/spawner/proc/ctf_qdelled_player(mob/living/body)
	SIGNAL_HANDLER

	//Respawn code?

	




/*
/obj/item/ctf
	name = "banner"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	inhand_icon_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A banner with Nanotrasen's logo on it."
	slowdown = 2
	throw_speed = 0
	throw_range = 1
	force = 200
	armour_penetration = 1000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	item_flags = SLOWS_WHILE_IN_HAND
	var/team = WHITE_TEAM
	var/reset_cooldown = 0
	var/anyonecanpickup = TRUE
	var/obj/effect/ctf/flag_reset/reset
	var/reset_path = /obj/effect/ctf/flag_reset
	/// Which area we announce updates on the flag to. Should just generally be the area of the arena.
	var/game_area = /area/centcom/ctf //Delete later (Maintainers please yell at me if I forget)
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/datum/ctf_controller/ctf_game

/obj/item/ctf/Destroy()
	QDEL_NULL(reset)
	return ..()

/obj/item/ctf/Initialize(mapload)
	. = ..()
	if(!reset)
		reset = new reset_path(get_turf(src))
		reset.flag = src
	ctf_game = GLOB.ctf_games[game_id]

/obj/item/ctf/process()
	if(is_ctf_target(loc)) //pickup code calls temporary drops to test things out, we need to make sure the flag doesn't reset from
		return PROCESS_KILL
	if(world.time > reset_cooldown)
		reset_flag()

/obj/item/ctf/proc/reset_flag(capture = FALSE)
	STOP_PROCESSING(SSobj, src)

	var/turf/our_turf = get_turf(src.reset)
	if(!our_turf)
		return TRUE
	forceMove(our_turf)
	if(!capture)
		ctf_game.message_all_teams("[src] has been returned to the base!")

//working with attack hand feels like taking my brain and putting it through an industrial pill press so i'm gonna be a bit liberal with the comments
/obj/item/ctf/attack_hand(mob/living/user, list/modifiers)
	//pre normal check item stuff, this is for our special flag checks
	if(!is_ctf_target(user) && !anyonecanpickup)
		to_chat(user, span_warning("Non-players shouldn't be moving the flag!"))
		return
	if(team in user.faction)
		to_chat(user, span_warning("You can't move your own flag!"))
		return
	if(loc == user)
		if(!user.dropItemToGround(src))
			return
	ctf_game.message_all_teams(span_userdanger("\The [initial(src.name)] has been taken!"))
	STOP_PROCESSING(SSobj, src)
	anchored = FALSE // Hacky usage that bypasses set_anchored(), because normal checks need this to be FALSE to pass
	. = ..() //this is the actual normal item checks
	if(.) //only apply these flag passives
		anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.
		return
	//passing means the user picked up the flag so we can now apply this
	user.set_anchored(TRUE)
	user.status_flags &= ~CANPUSH

/obj/item/ctf/dropped(mob/user)
	..()
	user.anchored = FALSE // Hacky usage that bypasses set_anchored()
	user.status_flags |= CANPUSH
	reset_cooldown = world.time + 20 SECONDS
	START_PROCESSING(SSobj, src)
	ctf_game.message_all_teams(span_userdanger("\The [initial(name)] has been dropped!"))
	anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.


/obj/item/ctf/red
	name = "red flag"
	icon_state = "banner-red"
	inhand_icon_state = "banner-red"
	desc = "A red banner used to play capture the flag."
	team = RED_TEAM
	reset_path = /obj/effect/ctf/flag_reset/red


/obj/item/ctf/blue
	name = "blue flag"
	icon_state = "banner-blue"
	inhand_icon_state = "banner-blue"
	desc = "A blue banner used to play capture the flag."
	team = BLUE_TEAM
	reset_path = /obj/effect/ctf/flag_reset/blue

/obj/item/ctf/green
	name = "green flag"
	icon_state = "banner-green"
	inhand_icon_state = "banner-green"
	desc = "A green banner used to play capture the flag."
	team = GREEN_TEAM
	reset_path = /obj/effect/ctf/flag_reset/green


/obj/item/ctf/yellow
	name = "yellow flag"
	icon_state = "banner-yellow"
	inhand_icon_state = "banner-yellow"
	desc = "A yellow banner used to play capture the flag."
	team = YELLOW_TEAM
	reset_path = /obj/effect/ctf/flag_reset/yellow

/obj/effect/ctf/flag_reset
	name = "banner landmark"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	desc = "This is where a banner with Nanotrasen's logo on it would go."
	layer = LOW_ITEM_LAYER
	var/obj/item/ctf/flag

/obj/effect/ctf/flag_reset/Destroy()
	if(flag)
		flag.reset = null
		flag = null
	return ..()

/obj/effect/ctf/flag_reset/red
	name = "red flag landmark"
	icon_state = "banner-red"
	desc = "This is where a red banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/blue
	name = "blue flag landmark"
	icon_state = "banner-blue"
	desc = "This is where a blue banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/green
	name = "green flag landmark"
	icon_state = "banner"
	desc = "This is where a green banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/yellow
	name = "yellow flag landmark"
	icon_state = "banner"
	desc = "This is where a yellow banner used to play capture the flag \
		would go."

//Control Points here
*/
#define CTF_LOADING_UNLOADED 0
#define CTF_LOADING_LOADING 1
#define CTF_LOADING_LOADED 2

/proc/toggle_id_ctf(user, activated_id, automated = FALSE, unload = FALSE)
	var/static/loading = CTF_LOADING_UNLOADED
	if(unload == TRUE)
		log_admin("[key_name_admin(user)] is attempting to unload CTF.")
		message_admins("[key_name_admin(user)] is attempting to unload CTF.")
		if(loading == CTF_LOADING_UNLOADED)
			to_chat(user, span_warning("CTF cannot be unloaded if it was not loaded in the first place"))
			return
		to_chat(user, span_warning("CTF is being unloaded"))
		for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
			CTF.unload()
		log_admin("[key_name_admin(user)] has unloaded CTF.")
		message_admins("[key_name_admin(user)] has unloaded CTF.")
		loading = CTF_LOADING_UNLOADED
		return
	switch (loading)
		if (CTF_LOADING_UNLOADED)
			if (isnull(GLOB.ctf_spawner))
				to_chat(user, span_boldwarning("Couldn't find a CTF spawner. Call a maintainer!"))
				return

			to_chat(user, span_notice("Loading CTF..."))

			loading = CTF_LOADING_LOADING
			if(!GLOB.ctf_spawner.load_map(user))
				to_chat(user, span_warning("CTF loading was cancelled"))
				loading = CTF_LOADING_UNLOADED
				return
			loading = CTF_LOADING_LOADED
		if (CTF_LOADING_LOADING)
			to_chat(user, span_warning("CTF is loading!"))

			return

	var/ctf_enabled = FALSE
	var/area/A
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(activated_id != CTF.game_id)
			continue
		ctf_enabled = CTF.toggle_ctf()
		A = get_area(CTF)
	for(var/obj/machinery/power/emitter/E in A)
		E.active = ctf_enabled
	if(user)
		message_admins("[key_name_admin(user)] has [ctf_enabled ? "enabled" : "disabled"] CTF!")
	else if(automated)
		message_admins("CTF has finished a round and automatically restarted.")
		notify_ghosts("CTF has automatically restarted after a round finished in [A]!",'sound/effects/ghost2.ogg')
	else
		message_admins("The players have spoken! Voting has enabled CTF!")
	if(!automated)
		notify_ghosts("CTF has been [ctf_enabled? "enabled" : "disabled"] in [A]!",'sound/effects/ghost2.ogg')

#undef CTF_LOADING_UNLOADED
#undef CTF_LOADING_LOADING
#undef CTF_LOADING_LOADED
/*

/obj/structure/trap/ctf
	name = "Spawn protection"
	desc = "Stay outta the enemy spawn!"
	icon_state = "trap"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/team = WHITE_TEAM
	time_between_triggers = 1
	anchored = TRUE
	alpha = 255

/obj/structure/trap/ctf/examine(mob/user)
	return

/obj/structure/trap/ctf/trap_effect(mob/living/L)
	if(!is_ctf_target(L))
		return
	if(!(src.team in L.faction))
		to_chat(L, span_danger("<B>Stay out of the enemy spawn!</B>"))
		L.investigate_log("has died from entering the enemy spawn in CTF.", INVESTIGATE_DEATHS)
		L.death()

/obj/structure/trap/ctf/red
	team = RED_TEAM
	icon_state = "trap-fire"

/obj/structure/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "trap-frost"

/obj/structure/trap/ctf/green
	team = GREEN_TEAM
	icon_state = "trap-earth"

/obj/structure/trap/ctf/yellow
	team = YELLOW_TEAM
	icon_state = "trap-shock"

/obj/structure/barricade/security/ctf
	name = "barrier"
	desc = "A barrier. Provides cover in fire fights."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/ctf/make_debris()
	new /obj/effect/ctf/dead_barricade(get_turf(src))

/obj/structure/table/reinforced/ctf
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1

/obj/effect/ctf
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	resistance_flags = INDESTRUCTIBLE

/obj/effect/ctf/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	var/game_id = "centcom"

/obj/effect/ctf/dead_barricade/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.dead_barricades += src

/obj/effect/ctf/dead_barricade/Destroy()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.dead_barricades -= src
	return ..()

/obj/effect/ctf/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/ctf(get_turf(src))
		qdel(src)
*/

/proc/is_ctf_target(atom/target)
	. = FALSE
	if(istype(target, /obj/structure/barricade/security/ctf))
		. = TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		var/datum/mind/target_mind = human.mind
		if(target_mind?.GetComponent(/datum/component/ctf_player))
			. = TRUE



#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef GREEN_TEAM
#undef YELLOW_TEAM
#undef FLAG_RETURN_TIME
#undef INSTAGIB_RESPAWN
#undef DEFAULT_RESPAWN
