//Oh god the scope keeps creeping
/datum/component/ctf_player
	var/team

/datum/component/ctf_player/Initialize(team)
	src.team = team
	if(!istype(src, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	