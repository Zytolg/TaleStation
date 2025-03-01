// GLOB list for the species sprites shit
GLOBAL_LIST_EMPTY(avian_beak_list)
GLOBAL_LIST_EMPTY(avian_tail_list)

/datum/species/avian
	name = "Avian"
	id = SPECIES_AVIAN

	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_EASILY_WOUNDED,
		TRAIT_MUTANT_COLORS,
	)

	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list("legs" = "Normal Legs")
	external_organs = list(
		/obj/item/organ/external/snout/avian_beak = "Short",
		/obj/item/organ/external/tail/avian_tail = "Wide",
		)

	mutanttongue = /obj/item/organ/internal/tongue/avian
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_MAMMAL
	species_pain_mod = 1

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/avian,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/avian,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/avian,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/avian,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/avian,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/avian,
	)

	digitigrade_customization = DIGITIGRADE_OPTIONAL

// Randomize avian
/datum/species/avian/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	features["avian_beak"] = pick("Short", "Long")
	features["avian_tail"] = pick("Wide", "Short")
	return features

// Avian species preview in tgui
/datum/species/avian/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features["mcolor"] = COLOR_WHITE
	human_for_preview.dna.features["avian_beak"] = "short"
	human_for_preview.dna.features["avian_tail"] = "wide"

	human_for_preview.update_body()
	human_for_preview.update_body_parts(update_limb_data = TRUE)

/datum/species/avian/random_name(gender,unique,lastname)
	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male_taj)
	else
		randname = pick(GLOB.first_names_female_taj)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names_taj)]"

	return randname

// Generates avian side profile for prefs
/proc/generate_avian_side_shots(datum/sprite_accessory/sprite_accessory, key, include_snout = TRUE)
	var/static/icon/avian
	var/static/icon/avian_with_snout

	if (isnull(avian))
		avian = icon('talestation_modules/icons/species/tajaran/bodyparts.dmi', "tajaran_head_m", EAST)
		var/icon/eyes = icon('icons/mob/human/human_face.dmi', "eyes", EAST)
		eyes.Blend(COLOR_BLACK, ICON_MULTIPLY)
		avian.Blend(eyes, ICON_OVERLAY)

		avian_with_snout = icon(avian)
		avian_with_snout.Blend(icon('talestation_modules/icons/species/avians/avian_beaks.dmi', "m_avian_beak_short", EAST), ICON_OVERLAY)

	var/icon/final_icon = include_snout ? icon(avian_with_snout) : icon(avian)

	if (!isnull(sprite_accessory))
		var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)

	final_icon.Crop(11, 20, 23, 32)
	final_icon.Scale(32, 32)
	final_icon.Blend(COLOR_WHITE, ICON_MULTIPLY)

	return final_icon

/* TO-DO: They need to CAW!!
/datum/species/avian/get_species_speech_sounds(sound_type)
	return string_assoc_list(list(
	))
*/
