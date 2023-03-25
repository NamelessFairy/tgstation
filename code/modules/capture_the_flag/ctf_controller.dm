#define CTF_GAMEMODE_CAPTURE_THE_FLAG "CTF"
#define CTF_GAMEMODE_CONTROL_POINTS "CP"

//Todo comment this whole file
/datum/ctf_controller
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>"
	var/list/points = list()
	var/points_to_win = 3
	var/gamemode = CTF_GAMEMODE_CAPTURE_THE_FLAG

/datum/ctf_controller/New()
	. = ..()
	GLOB.ctf_game = src

/datum/ctf_controller/Destroy(force, ...)
	. = ..()
	GLOB.ctf_game = null

/datum/ctf_controller/proc/add_team(team_color)
	points[team_color] = 0

/datum/ctf_controller/proc/score_point(team_color)
	points[team_color]++

/datum/ctf_controller/proc/get_points(team_color)
	return points[team_color]

/datum/ctf_controller/proc/reset_game()
	for(var/team in points)
		points[team] = 0

/proc/create_ctf_game()
	if(GLOB.ctf_game)
		QDEL_NULL(GLOB.ctf_game)
	var/datum/ctf_controller/CTF = new()
	return CTF
