#define CTF_GAMEMODE_CAPTURE_THE_FLAG "CTF"
#define CTF_GAMEMODE_CONTROL_POINTS "CP"

//Todo comment this whole file
/datum/ctf_controller
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>"
	var/list/datum/ctf_team/teams = list()
	var/points_to_win = 3
	var/gamemode = CTF_GAMEMODE_CAPTURE_THE_FLAG

/datum/ctf_controller/New()
	. = ..()
	GLOB.ctf_games[game_id] = src

/datum/ctf_controller/Destroy(force, ...)
	. = ..()
	GLOB.ctf_games[game_id] = null

/datum/ctf_controller/proc/add_team(obj/machinery/capture_the_flag/spawner)
	if(!isnull(teams[spawner.team]))
		return
	teams[spawner.team] = new /datum/ctf_team(spawner)

/datum/ctf_controller/proc/add_player(team_color, client/new_team_member)
	teams[team_color].team_members[new_team_member.ckey] = new_team_member

/datum/ctf_controller/proc/get_players(team_color)
	return teams[team_color].team_members

/datum/ctf_controller/proc/get_all_players()
	var/list/players = list() //If no team_color value is provided all team's players will be returned
	for(var/team in teams)
		players += get_players(team)
	return players

/datum/ctf_controller/proc/team_valid_to_join(team_color, mob/user)
	var/list/friendly_team_members = get_players(team_color)
	for(var/team in teams)
		if(team == team_color)
			continue
		var/list/enemy_team_members = get_players(team)
		if(user.ckey in enemy_team_members)
			to_chat(user, span_warning("No switching teams while the round is going!"))
			return FALSE
		if(friendly_team_members.len > enemy_team_members.len)
			to_chat(user, span_warning("[team_color] has more team members than [team]! Try joining [team] team to even things up."))
			return FALSE
	return TRUE

/datum/ctf_controller/proc/score_point(team_color)
	teams[team_color].points++
	if(get_points(team_color) >= points_to_win)
		victory(team_color)

/datum/ctf_controller/proc/get_points(team_color)
	return teams[team_color].points

/datum/ctf_controller/proc/victory(winning_team)
	for(var/team in teams)
		teams[team].victory(winning_team)
	reset_game()

/datum/ctf_controller/proc/reset_game()
	for(var/team in teams)
		teams[team].reset_team()



//Todo: comment this, this seemed like a smart idea.
/datum/ctf_team
	var/obj/machinery/capture_the_flag/spawner
	var/team_color
	var/points = 0
	var/list/team_members = list()
	var/team_span = ""
	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>" //TEMP, REPLACE ON MEDI-CTF

/datum/ctf_team/New(obj/machinery/capture_the_flag/spawner)
	. = ..()
	src.spawner = spawner
	team_color = spawner.team
	team_span = spawner.team_span

/datum/ctf_team/proc/reset_team()
	points = 0
	team_members = list()

/datum/ctf_team/proc/victory(winning_team)
	for(var/player in team_members)
		var/client/team_member = team_members[player]
		to_chat(team_member, "<span class='narsie [team_span]'>[winning_team] team wins!</span>") //Rework this, it needs to use the winning team's span, not the current team
		to_chat(team_member, victory_rejoin_text)
		var/mob/living/living_player = team_member.mob
		if(!isnull(living_player) && istype(get_area(living_player), /area/centcom/ctf)) //Player is alive and currently playing CTF
			for(var/obj/item/ctf/flag in living_player)
				living_player.dropItemToGround(flag)
			living_player.dust()
	spawner.victory()

/proc/create_ctf_game()
	if(GLOB.ctf_games[CTF_GAMEMODE_CAPTURE_THE_FLAG])
		QDEL_NULL(GLOB.ctf_games[CTF_GAMEMODE_CAPTURE_THE_FLAG])
	var/datum/ctf_controller/CTF = new()
	return CTF
