/// -- This file is ONLY for adding the unique_examine element onto items, pre-existing or modular. --
// Concept taken from skyrat-tg, some descriptions may match.

/*
 * Get the job TITLES of all jobs that are in the security department,
 * and all the jobs that are ONLY in the command department
 *
 * returns a list of strings
 */
/proc/get_sec_and_command_jobs()
	RETURN_TYPE(/list)
	var/list/job_list = list()

	var/datum/job_department/command_department = SSjob.get_department_type(/datum/job_department/command)
	for(var/datum/job/job as anything in command_department.department_jobs)
		if(job.departments_bitflags == DEPARTMENT_BITFLAG_COMMAND) // we only want people with command ONLY (captain, asset protection)
			job_list |= job.title

	var/datum/job_department/sec_department = SSjob.get_department_type(/datum/job_department/security)
	for(var/datum/job/job as anything in sec_department.department_jobs)
		job_list |= job.title

	return string_list(job_list)

// SYNDICATE / SYNDICATE TOY ITEMS //

/obj/item/storage/backpack/duffelbag/syndie
	name = "dark duffel bag"
	desc = "A large lightweight duffel bag for holding extra supplies."

/obj/item/storage/backpack/duffelbag/syndie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"This bag is used to store tactical equipment and is manufactured by Donk Co. \
		It's faster and lighter than other duffelbags without sacrificing any space.", \
		EXAMINE_CHECK_SYNDICATE, hint = FALSE)
	AddElement(/datum/element/unique_examine, \
		"A large, dark colored dufflebag commonly used to transport ammunition, tools, and explosives. \
		Its design makes it much lighter than other duffelbags without sacrificing any space.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs())

/obj/item/clothing/under/syndicate
	name = "suspicious turtleneck"
	var/unique_description = "A tactical, armored turtleneck manufactured by 'neutral' parties, close to the Gorlex Marauders."

/obj/item/clothing/under/syndicate/Initialize(mapload)
	. = ..()
	if(unique_description)
		AddElement(/datum/element/unique_examine, unique_description, EXAMINE_CHECK_SYNDICATE, hint = FALSE)
		AddElement(/datum/element/unique_examine, "A padded, armored outfit commonly used by syndicate operatives in the field.", EXAMINE_CHECK_JOB, get_sec_and_command_jobs())

/obj/item/clothing/under/syndicate/skirt
	name = "suspicious skirtleneck"
	unique_description = "A tactical, armored skirtleneck manufactured by 'neutral' parties, close to the Gorlex Marauders."

/obj/item/clothing/under/syndicate/bloodred
	name = "blood-red pajamas"
	desc = "Pajamas, manufactured in an ominous blood-red color scheme... it feels heavy."
	unique_description = "Developed by Roseus Galactic in conjunction with the Gorlex Marauders, part of the Tactical Sneaksuit bundle. Not space resistant."

/obj/item/clothing/under/syndicate/bloodred/sleepytime
	unique_description = "A Gorlex Marauders staple, through and through - comfy pajamas."

/obj/item/clothing/under/syndicate/tacticool
	unique_description = ""
	var/tacticool_description = "Knockoff, Nanotrasen brand tactical turtleneck - it's not even the right color."

/obj/item/clothing/under/syndicate/tacticool/Initialize(mapload)
	. = ..()
	if(tacticool_description)
		AddElement(/datum/element/unique_examine, tacticool_description, EXAMINE_CHECK_SYNDICATE, real_name = name)

/obj/item/clothing/under/syndicate/tacticool/skirt
	tacticool_description = "Knockoff, Nanotrasen brand tactical skirtleneck - it's not even the right color."

/obj/item/clothing/under/syndicate/sniper
	name = "silk suit"
	desc = "A heavy, comfortable silk suit. The collar is really sharp."
	unique_description = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator."

/obj/item/clothing/under/syndicate/combat
	unique_description = "Favored by Cybersun operatives for it's 'maintenance camo', \
		this otherwise standard Tactical Turtleneck remains a classic part of the Syndicate."

/obj/item/clothing/under/syndicate/coldres
	name = "insulated suspicious turtleneck"
	desc = "A suspicious looking turtleneck with camouflage cargo pants. It's pretty padded and warm."
	unique_description = "A nondescript and slightly suspicious-looking turtleneck with digital camouflage cargo pants. \
		The interior has been padded with special insulation for both warmth and protection. \
		It's normally assigned to operatives deployed into frozen hellscapes."

/obj/item/clothing/under/syndicate/rus_army
	unique_description = ""

/obj/item/clothing/under/syndicate/camo
	unique_description = ""

/obj/item/clothing/under/syndicate/soviet
	unique_description = ""

// DRINKS //

/obj/item/reagent_containers/cup/glass/bottle/lizardwine/Initialize(mapload)
	. = ..()
	var/vintage = rand(GLOB.year_integer + 450, GLOB.year_integer + 555) // Wine has an actual vintage var but lizardwine is special
	AddElement(/datum/element/unique_examine, \
		"A bottle of ethically questionable lizard wine. \
		Rare now-a-days following the harsh regulations placed on the great wine industry. You'd place the vintage at... \
		[(vintage >= 3000) ? "[vintage] Nanotrasen White-Green. Not my personal preference..." : "a respectable [vintage] Nanotrasen White-Green. Wonderful."]", \
		EXAMINE_CHECK_SKILLCHIP, /obj/item/skillchip/wine_taster, hint = FALSE)
	AddElement(/datum/element/unique_examine, \
		"A lizardperson's tail is important in keeping balance and warding off enemies in combat situations. \
		You can't help but feel disappointed and saddened looking at this, knowing a fellow kin was robbed of such a thing.", \
		EXAMINE_CHECK_SPECIES, /datum/species/lizard)

/obj/item/reagent_containers/cup/glass/bottle/wine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A bottle of fine [name]. Classic, refreshing, usually comes with a sharp taste. \
		The vintage is labeled as [generate_vintage()]... You'll be the one to determine that.", \
		EXAMINE_CHECK_SKILLCHIP, /obj/item/skillchip/wine_taster, hint = FALSE)

// MAGICAL ITEMS //

/obj/item/scrying
	desc = "A mysterious glowing incandescent orb of crackling energy. Moving your fingers towards it creates arcs of blue electricity."

/obj/item/scrying/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A scrying orb - a view into another plane of existance. \
		Using it will allow you to release your ghost while alive, \
		allowing you to spy upon the station and talk to the deceased. \
		In addition, holding it it will permanently grant you X-ray vision.", \
		EXAMINE_CHECK_FACTION, ROLE_WIZARD)

/obj/item/codex_cicatrix
	name = "suspicious purple book"
	desc = "A purple book clasped with a heavy iron lock and bound in a firm leather."

/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The Codex Cicatrix - the book of knowledge holding all the secrets of the veil between the worlds, the Mansus. \
		Discovered by Wizard Federation aeons ago but locked away deep in the shelving of the highest security libraries of the Spindward Galaxy, \
		the book was recently stolen during a raid by the Cybersun Industries - which is how you got into contact with it.", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC)
	AddElement(/datum/element/unique_examine, \
		"The Codex Cicatrix - the book of knowledge that supposedly holds all the secrets of the viel between the worlds.. \
		Discovered by Wizard Federation long ago, but locked away deep in the shelving of the highest security libraries of the Spindward Galaxy, \
		the book was recently stolen during a raid by the Cybersun Industries, copied, and widespread to aspiring seekers of power.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs(), hint = FALSE)

/obj/item/toy/eldritch_book
	name = "suspicious purple book"

/obj/item/toy/eldritch_book/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A fake Codex Cicatrix - the book of knowledge holding all the secrets of the veil between the worlds, the Mansus. \
		While the book was recently discovered, copied, and spread due to a recent Cybersun Industries raid on a high-security library, \
		it seems as if Nanotrasen has already began marketing and selling fake toy copies for children... interesting.", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC, real_name = "Codex Cicatrix")

/obj/effect/heretic_rune/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The transumation circle - the site to most known rituals involving unlocking the key to the veil between worlds. \
		Many concentric black ink circles are drawn amidst a larger, thick green circle, weakening the chains of reality \
		and allowing a seekers of ancient powers to access the mysteries of the Mansus.", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC)

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A pierce in reality - a weakness in the veil that allows power to be gleamed from the Mansus.\
		\n[span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC)

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A tapped pierce in reality - this one has been sapped of power. \
		There is nothing here for Them any longer.\
		\n[span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC)
	AddElement(/datum/element/unique_examine, \
		span_hypnophrase("A harrowing reminder of the \
		fragility of our reality \
		the fleeting nature of life, and of impending slow doom."), \
		EXAMINE_CHECK_NONE, hint = FALSE)
	AddElement(/datum/element/unique_examine, \
		"A tapped, used rift in reality. Its pressence means a fellow man - likely a crewmate - \
		has attempted to throw off the shackles of reality \
		and began seeking power and strength from a copy of the forbidden Codex Cicatrix.", \
		EXAMINE_CHECK_MINDSHIELD, hint = FALSE)

/obj/item/toy/reality_pierce/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A pierced reality - a weakness in the veil that allows power to be gleamed from the Mansus. \
		This one is fake, however. How'd they even make this?", \
		EXAMINE_CHECK_FACTION, FACTION_HERETIC, real_name = "Pierced Reality")

/obj/effect/rune/Initialize(mapload)
	. = ..()
	if(icon == 'icons/obj/antags/cult/rune.dmi')
		AddElement(/datum/element/unique_examine, \
			"A rune of blood inscribed by the followers of the Geometer Nar'sie \
			to channel powerful blood magics through the invoker.", \
			EXAMINE_CHECK_FACTION, "cult")
	else
		AddElement(/datum/element/unique_examine, \
			"A sigil of power inscribed by the followers of the Clockwork God Rat'var \
			to channel powerful clock magics through the invoker.", \
			EXAMINE_CHECK_FACTION, "cult")

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	if(e_name == "rune")
		AddElement(/datum/element/unique_examine, \
			"A rune of blood inscribed by the followers of the Geometer Nar'sie \
			to channel powerful blood magics through the invoker. \
			Except this one is crayon and not blood - a mockery.", \
			EXAMINE_CHECK_FACTION, "cult")

// ITEMS //

/obj/item/gun/ballistic/revolver/mateba/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A refitted revolver that takes .357 caliber, the Mateba Model 6 Unica - \
		or as it's commonly known shorthand, either the Mateba or the Unica - \
		has been the weapon of choice for Nanotrasen commanding officers in the field for decades.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs())

/obj/item/gun/energy/laser/captain/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The pride and joy of every site director in the Spinward. \
		It's tradition amongst site directors to mod and maintain a lasergun of your own, only bringing it out to use in dire straits. \
		Every site director has their own personal modifications - \
		this one is modified with a self-recharging cell and hellfire laser rounds.", \
		EXAMINE_CHECK_JOB, "Captain")

/obj/item/gun/energy/e_gun/hos/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"A modernized and remastered version of the site director's antique laser gun, \
		the X-01 multiphase energy gun was developed in the past few decades to issue to only the highest brass officers \
		in Nanotrasen security forces. While in the past the gun was outfitted with taser electrodes instead of an ion bolts, \
		it is still used by lead officers for quick response and utility in the event of varying threats.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_SECURITY)

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"Every Nanotrasen operated station comes with an installed self-destruct terminal \
		for extreme measures, and [station_name()] is no exception. \
		The Nuclear Authentication Disk, entrusted only into the hands of the site director, \
		acting site director, or any higher ranked Nanotrasen personel on board the station, \
		is the linch pin of this self-destruct device, providing the only key to activate it - \
		should the holder also have the authentication codes.", \
		EXAMINE_CHECK_MINDSHIELD)
	AddElement(/datum/element/unique_examine, \
		"Only one person is entrusted with the Nuclear Authentication Disk on board the station - \
		the site director (or acting site director in their absence). \
		Being the direct line of communication to Nanotrasen, they are the only member of the crew authorized \
		to hold the authentication disk and (should the situation call for it) enter the codes to the self-destruct. \
		Of course, because of the importance of the disk in unlocking nuclear devices, the Nuclear Authentication Disk \
		is a very sought after object - luckily, it's in good hands...", \
		EXAMINE_CHECK_SKILLCHIP, /obj/item/skillchip/disk_verifier, hint = FALSE)

/obj/item/clothing/shoes/magboots/advance/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The Site Foreman's treasured advanced magboots - a sleek white design of the standard magboots \
		designed with speed and wearability in mind during extravehicular activity. \
		Offers a lighter magnetic pull compared to standard model of magboots, \
		reducing slowdown without sacrificing safety or usability.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_ENGINEERING)

/obj/item/mod/control/pre_equipped/advanced/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The Site Foreman's spotless advanced MODsuit - a sleek white design of the standard engineering \
		and atmospheric MODsuits with improved mobility and resistance to fire and radiation.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_ENGINEERING)

/obj/item/card/id/advanced/gold/captains_spare/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The site director's spare ID card - the backup all-access ID card assigned to the care of the site director themselves. \
		Standard-issue golden ID cards supplied to all Nanotrasen operated space stations, to allow \
		for normal operation of every aspect of the station in the absence of the site director... \
		assuming it doesn't end up in the hands of certain gas-masked individuals, of course.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_COMMAND)

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CAPTAIN, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)
	AddElement(/datum/element/unique_examine, \
		"The Hand Teleporter, a breakthrough of bluespace technology, is a miniature hand-held version of the \
		larger room-sized teleporters found aboard various stations across the Spinward. \
		While not as powerful independently as a full teleporter gate setup just yet, \
		these are often entrusted to the Captain for their emergencies, though Research Directors \
		and even space explorers are often given one for personal usage.", \
		EXAMINE_CHECK_JOB, job_examine)

/obj/item/spear/bonespear/ceremonial/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"It's common tradition for Ash-kin to build and carry their own spear or axe \
		as their weapon of choice for most of their lives. While most have abandoned this practice since, \
		some are still allowed by the company to carry a ceremonial or traiditional weapon - \
		provided they aren't used for attacking others, of course.", \
		EXAMINE_CHECK_SPECIES, /datum/species/lizard)

// MOBS //

/mob/living/basic/pet/dog/corgi/ian/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"It's Ian! Your trusty companion through and through. \
		It's the Head of Personnel's secondary job to keep Ian safe and sound from anything that can harm them. \
		Ian's birthday is on September 9th - be sure to celebrate!", \
		EXAMINE_CHECK_JOB, JOB_HEAD_OF_PERSONNEL)

/mob/living/carbon/alien/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_XENOBIOLOGIST)
	AddElement(/datum/element/unique_examine, \
		"A Xenomorph - an alien species designed to hunt and capture live prey. \
		They reproduce by attaching facehuggers to their prey, impregnating them with the alient seed, \
		eventually causing the host to burst in a violent display of gore as a new larva writhes out.", \
		EXAMINE_CHECK_JOB, string_list(job_examine))
	AddElement(/datum/element/unique_examine, \
		"A Xenomorph - an alien species designed to hunt live prey. \
		Weak to flames and laser fire. Facial coverage in the form of biosuits, hardsuits, or riot helmets are of utmost importance \
		when facing these creatures to avoid being 'facehugged' by their offspring.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs(), hint = FALSE)

/mob/living/simple_animal/hostile/alien/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_XENOBIOLOGIST)
	AddElement(/datum/element/unique_examine, \
		"A xenomorph - an alien species designed to hunt and capture live prey. \
		They reproduce by attaching facehuggers to their prey, impregnating them with the alient seed, \
		eventually causing the host to burst in a violent display of gore as a new larva writhes out.", \
		EXAMINE_CHECK_JOB, string_list(job_examine))
	AddElement(/datum/element/unique_examine, \
		"A xenomorph - an alien species designed to hunt live prey. \
		Weak to flames and laser fire. Facial coverage in the form of biosuits, hardsuits, or riot helmets are of utmost importance \
		when facing these creatures to avoid being 'facehugged' by their offspring.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs(), hint = FALSE)

/mob/living/carbon/alien/humanoid/royal/queen/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_XENOBIOLOGIST)
	AddElement(/datum/element/unique_examine, \
		"A xenomorph queen - the patriarch of the xenomorph species. \
		Produces large, brown eggs which birth into the facehugger - \
		the small, jumpy alien creature responisble for the alien's method of reproduction. \
		Leads its sisters and offspring through their alien hivemind - \
		when slain, releases a psychic screen via the hivemind, greatly disorienting their kin.", \
		EXAMINE_CHECK_JOB, string_list(job_examine))
	AddElement(/datum/element/unique_examine, \
		"A xenomorph queen - the patriarch of the xenomorph species. \
		Leads the nest through their xenomorph hivemind. The source of the xenos - \
		killing the queen is important in killing the hive. \
		When slain, releases a psychic scream along the alien hivemind, \
		confusing and disorienting their kin and offspring.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs(), hint = FALSE)

/mob/living/simple_animal/hostile/alien/queen/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_XENOBIOLOGIST)
	AddElement(/datum/element/unique_examine, \
		"A xenomorph queen - the patriarch of the xenomorph species. \
		Produces large, brown eggs which birth into the facehugger - \
		the small, jumpy alien creature responisble for the alien's method of reproduction. \
		Leads its sisters and offspring through their alien hivemind - \
		when slain, releases a psychic screen via the hivemind, greatly disorienting their kin.", \
		EXAMINE_CHECK_JOB, string_list(job_examine))
	AddElement(/datum/element/unique_examine, \
		"A xenomorph queen - the patriarch of the xenomorph species. \
		Leads the nest through their xenomorph hivemind. The source of the xeno menace - \
		killing the queen is crucial in killing the hive. \
		When slain, releases a psychic scream along the alien hivemind, confusing and disorienting their kin and offspring.", \
		EXAMINE_CHECK_JOB, get_sec_and_command_jobs(), hint = FALSE)

/mob/living/basic/pet/dog/corgi/exoticcorgi/dufresne/Initialize(mapload)
	. = ..()
	var/static/list/job_examine = list(JOB_CHAPLAIN)
	AddElement(/datum/element/unique_examine, \
		"A peculiar and unusual corgi. You don't know if this corgi comes from Nar'Sie, \
		Ratvar or the Eldritch Gods. Whatever it may be, best to keep your distance.", \
		EXAMINE_CHECK_JOB, job_examine)

// MACHINES //

/obj/machinery/computer/communications/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"The communications console is the station's one and only link to central command for anything and everything. \
		If every console on the station is destoyed, the emergency shuttle is automatically called on a 25 minute timer. \
		Likewise if a large percentage of the station's crew perish the shuttle is automatically called in that case, too. \
		It's good that central command cares.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_COMMAND)

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"Hope you're wearing meson goggles - Crystallized supermatter, one of the most deadly and reactive things in the universe. \
		Supermatter reacts when shot with energy, turning the light energy of emitters into heated waste gases and bursts of gamma radiation.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_ENGINEERING)

/obj/machinery/computer/slot_machine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"Often called 'one armed bandit', 'fruit machine', or just 'slots', \
		\the [src] is one of the most common forms of gambling in the galaxy. \
		A 7 century old design. Simple and addictive - \
		Hopefully you're doing your job and not playing it right now.", \
		EXAMINE_CHECK_DEPARTMENT, DEPARTMENT_BITFLAG_SERVICE)

// STRUCTURES //

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/unique_examine, \
		"This religious altar is the place where chaplains can commune with their deities and undergo mystical rituals to their gods. \
		The closest place on the station to the gods above is in front of the altar, \
		and it's where the most successful prayers and rituals take place.", \
		EXAMINE_CHECK_TRAIT, TRAIT_SPIRITUAL)
