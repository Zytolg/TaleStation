#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding

/****************************************************
				BLOOD SYSTEM
****************************************************/

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(seconds_per_tick, times_fired)

	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		return

	if(bodytemperature < BLOOD_STOP_TEMP || (HAS_TRAIT(src, TRAIT_HUSK))) //cold or husked people do not pump the blood.
		return

	//Blood regeneration if there is some space
	if(blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))
	// NON-MODULAR CHANGES: Lizards
		var/blood_multiplier = dna.species.blood_gain_multiplier
		var/nutrition_ratio = 0
		switch(nutrition)
			if(0 to NUTRITION_LEVEL_STARVING)
				nutrition_ratio = 0.2
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				nutrition_ratio = 0.4
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				nutrition_ratio = 0.6
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				nutrition_ratio = 0.8
			else
				nutrition_ratio = 1
		if(satiety > 80)
			nutrition_ratio *= 1.25
		adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * seconds_per_tick)
		// NON-MODULAR CHANGES: Lizards
		blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * blood_multiplier * seconds_per_tick), BLOOD_VOLUME_NORMAL)

	// we call lose_blood() here rather than quirk/process() to make sure that the blood loss happens in sync with life()
	if(HAS_TRAIT(src, TRAIT_BLOOD_DEFICIENCY))
		var/datum/quirk/blooddeficiency/blooddeficiency = get_quirk(/datum/quirk/blooddeficiency)
		if(!isnull(blooddeficiency))
			blooddeficiency.lose_blood(seconds_per_tick)

	//Effects of bloodloss
	var/word = pick("dizzy","woozy","faint")
	switch(blood_volume)
		if(BLOOD_VOLUME_MAX_LETHAL to INFINITY)
			if(SPT_PROB(7.5, seconds_per_tick))
				to_chat(src, span_userdanger("Blood starts to tear your skin apart. You're going to burst!"))
				investigate_log("has been gibbed by having too much blood.", INVESTIGATE_DEATHS)
				inflate_gib()
		if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(src, span_warning("You feel your skin swelling."))
		if(BLOOD_VOLUME_MAXIMUM to BLOOD_VOLUME_EXCESS)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(src, span_warning("You feel terribly bloated."))
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(src, span_warning("You feel [word]."))
			adjustOxyLoss(round(0.005 * (BLOOD_VOLUME_NORMAL - blood_volume) * seconds_per_tick, 1))
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			adjustOxyLoss(round(0.01 * (BLOOD_VOLUME_NORMAL - blood_volume) * seconds_per_tick, 1))
			if(SPT_PROB(2.5, seconds_per_tick))
				set_eye_blur_if_lower(12 SECONDS)
				to_chat(src, span_warning("You feel very [word]."))
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			adjustOxyLoss(2.5 * seconds_per_tick)
			if(SPT_PROB(7.5, seconds_per_tick))
				Unconscious(rand(20,60))
				to_chat(src, span_warning("You feel extremely [word]."))
		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			if(!HAS_TRAIT(src, TRAIT_NODEATH))
				investigate_log("has died of bloodloss.", INVESTIGATE_DEATHS)
				death()

	var/temp_bleed = 0
	//Bleeding out
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		var/iter_bleed_rate = iter_part.get_modified_bleed_rate()
		temp_bleed += iter_bleed_rate * seconds_per_tick

		if(iter_part.generic_bleedstacks) // If you don't have any bleedstacks, don't try and heal them
			iter_part.adjustBleedStacks(-1, 0)

	if(temp_bleed)
		bleed(temp_bleed)
		bleed_warn(temp_bleed)

/// Has each bodypart update its bleed/wound overlay icon states
/mob/living/carbon/proc/update_bodypart_bleed_overlays()
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		iter_part.update_part_wound_overlay()

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt)
	if(!blood_volume || (status_flags & GODMODE))
		return
	blood_volume = max(blood_volume - amt, 0)

	//Blood loss still happens in locker, floor stays clean
	if(isturf(loc) && prob(sqrt(amt)*BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, (amt <= 10))

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
		..()

/// A helper to see how much blood we're losing per tick
/mob/living/carbon/proc/get_bleed_rate()
	if(!blood_volume)
		return
	var/bleed_amt = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/iter_bodypart = X
		bleed_amt += iter_bodypart.get_modified_bleed_rate()
	return bleed_amt

/mob/living/carbon/human/get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	. = ..()
	. *= physiology.bleed_mod

/**
 * bleed_warn() is used to for carbons with an active client to occasionally receive messages warning them about their bleeding status (if applicable)
 *
 * Arguments:
 * * bleed_amt- When we run this from [/mob/living/carbon/human/proc/handle_blood] we already know how much blood we're losing this tick, so we can skip tallying it again with this
 * * forced-
 */
/mob/living/carbon/proc/bleed_warn(bleed_amt = 0, forced = FALSE)
	if(!blood_volume || !client)
		return
	if(!COOLDOWN_FINISHED(src, bleeding_message_cd) && !forced)
		return

	if(!bleed_amt) // if we weren't provided the amount of blood we lost this tick in the args
		bleed_amt = get_bleed_rate()

	var/bleeding_severity = ""
	var/next_cooldown = BLEEDING_MESSAGE_BASE_CD

	switch(bleed_amt)
		if(-INFINITY to 0)
			return
		if(0 to 1)
			bleeding_severity = "You feel light trickles of blood across your skin"
			next_cooldown *= 2.5
		if(1 to 3)
			bleeding_severity = "You feel a small stream of blood running across your body"
			next_cooldown *= 2
		if(3 to 5)
			bleeding_severity = "You skin feels clammy from the flow of blood leaving your body"
			next_cooldown *= 1.7
		if(5 to 7)
			bleeding_severity = "Your body grows more and more numb as blood streams out"
			next_cooldown *= 1.5
		if(7 to INFINITY)
			bleeding_severity = "Your heartbeat thrashes wildly trying to keep up with your bloodloss"

	var/rate_of_change = ", but it's getting better." // if there's no wounds actively getting bloodier or maintaining the same flow, we must be getting better!
	if(HAS_TRAIT(src, TRAIT_COAGULATING)) // if we have coagulant, we're getting better quick
		rate_of_change = ", but it's clotting up quickly!"
	else
		// flick through our wounds to see if there are any bleeding ones getting worse or holding flow (maybe move this to handle_blood and cache it so we don't need to cycle through the wounds so much)
		for(var/i in all_wounds)
			var/datum/wound/iter_wound = i
			if(!iter_wound.blood_flow)
				continue
			var/iter_wound_roc = iter_wound.get_bleed_rate_of_change()
			switch(iter_wound_roc)
				if(BLOOD_FLOW_INCREASING) // assume the worst, if one wound is getting bloodier, we focus on that
					rate_of_change = ", <b>and it's getting worse!</b>"
					break
				if(BLOOD_FLOW_STEADY) // our best case now is that our bleeding isn't getting worse
					rate_of_change = ", and it's holding steady."
				if(BLOOD_FLOW_DECREASING) // this only matters if none of the wounds fit the above two cases, included here for completeness
					continue

	to_chat(src, span_warning("[bleeding_severity][rate_of_change]"))
	COOLDOWN_START(src, bleeding_message_cd, next_cooldown)

/mob/living/carbon/human/bleed_warn(bleed_amt = 0, forced = FALSE)
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
		return ..()

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		BP.setBleedStacks(0)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return FALSE
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return FALSE

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == /datum/reagent/blood) //normal blood
				if(blood_data["viruses"])
					for(var/thing in blood_data["viruses"])
						var/datum/disease/D = thing
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
							continue
						C.ForceContractDisease(D)
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))
					C.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
					return TRUE

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAX_LETHAL)
			return TRUE

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return TRUE


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == /datum/reagent/blood) //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["viruses"] = list()

		for(var/thing in diseases)
			var/datum/disease/D = thing
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = dna.unique_enzymes
		if(LAZYLEN(disease_resistances))
			blood_data["resistances"] = disease_resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.type] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!HAS_TRAIT_FROM(src, TRAIT_SUICIDED, REF(src)))
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = dna.blood_type
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		blood_data["quirks"] = list()
		for(var/V in quirks)
			var/datum/quirk/T = V
			blood_data["quirks"] += T.type
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return /datum/reagent/blood

/mob/living/carbon/human/get_blood_id()
	if(HAS_TRAIT(src, TRAIT_HUSK) || !dna)
		return
	if(check_holidays(APRIL_FOOLS) && is_clown_job(mind?.assigned_role))
		return /datum/reagent/colorful_reagent
	if(dna.species.exotic_blood)
		return dna.species.exotic_blood
	else if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	return /datum/reagent/blood

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-"),
		"A+" = list("A-", "A+", "O-", "O+"),
		"B-" = list("B-", "O-"),
		"B+" = list("B-", "B+", "O-", "O+"),
		"AB-" = list("A-", "B-", "O-", "AB-"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+"),
		"O-" = list("O-"),
		"O+" = list("O-", "O+"),
		"L" = list("L"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip)
	if(get_blood_id() != /datum/reagent/blood)
		return
	if(!T)
		T = get_turf(src)
	if(isclosedturf(T) || (isgroundlessturf(T) && !GET_TURF_BELOW(T)))
		return

	var/list/temp_blood_DNA
	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.add_overlay(pick(drop.random_icon_states))
				drop.transfer_mob_blood_dna(src)
				return
			else
				temp_blood_DNA = GET_ATOM_BLOOD_DNA(drop) //we transfer the dna from the drip to the splatter
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T, get_static_viruses())
			drop.transfer_mob_blood_dna(src)
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T, get_static_viruses())
	if(QDELETED(B)) //Give it up
		return
	B.bloodiness = min((B.bloodiness + BLOOD_AMOUNT_PER_DECAL), BLOOD_POOL_MAX)
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.add_blood_DNA(temp_blood_DNA)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/xenoblood/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.add_blood_DNA(list("UNKNOWN DNA" = "X*"))

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)
		B = new(T)

#undef BLOOD_DRIP_RATE_MOD
