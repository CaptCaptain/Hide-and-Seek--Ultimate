const availableLanguages = ["en-US"];
const practiceRangeTranslations = ['"Practice Range"'];
const translations = {
	STYLE_DEFAULT: {
		"en-US": "DEFAULT",
	},
	STYLE_GLITCH: {
		"en-US": "GLITCH",
	},
	STYLE_TINY: {
		"en-US": "TINY",
	},
	STYLE_MERCY_V_REIN: {
		"en-US": "MERCY VS. REINHARDT",
	},
	GAME_STATE_WAITING: {
		"en-US": "Waiting For Players",
	},
	GAME_STATE_HIDING: {
		"en-US": "Hiding",
	},
	GAME_STATE_SEEKING: {
		"en-US": "Seeking",
	},
	GAME_STATE_RESULTS: {
		"en-US": "Results",
	},
	GAME_STATE_END: {
		"en-US": "Match Complete",
	},
	GAME_TITLE: {
		"en-US": "Hide & Seek",
	},
	GAME_SUBTITLE: {
		"en-US": "Ultimate",
	},
	GAME_STYLE: {
		"en-US": "Style",
	},
	GAME_WAITING_FOR_PLAYERS: {
		"en-US": "Waiting For Players",
	},
	HIDER: {
		"en-US": "Hider",
	},
	SEEKER: {
		"en-US": "Seeker",
	},
	PHASE: {
		"en-US": "Phase",
	},
	WEBLINK: {
		"en-US": "https://workshop.codes/hide-and-seek-ult",
	},
	VERSION: {
		"en-US": "Current Version: {}\n",
		format: "CURRENT_VERSION",
	},
	GAME_NAME: {
		"en-US": "{} Hide & Seek: Ultimate by CaptCaptain#11421",
		format: "abilityIconString(random.choice(getAllHeroes()), Button.ULTIMATE)",
	},
	SLINGSHOT_USAGE: {
		"en-US": "[{}]: Toggle slingshot / [{}]: Confirm",
		format: "buttonString(Button.INTERACT), buttonString(Button.PRIMARY_FIRE)",
	},
	SLINGSHOT_CANNOT_USE: {
		"en-US": "CANNOT USE SLINGSHOT WHILE IN LOS OF SEEKERS",
	},
	SLINGSHOT_ON_COOLDOWN: {
		"en-US": "SLINGSHOT IS ON COOLDOWN",
	},
	SLINGSHOT_CANT_IN_AIR: {
		"en-US": "SLINGSHOT CANNOT BE USED WHILE IN THE AIR",
	},
	THIRD_PERSON_CAMERA_USAGE: {
		"en-US": "[{}]: Toggle third person camera",
		format: "buttonString(Button.RELOAD)",
	},
	LAYING_DOWN_USAGE: {
		"en-US": "[DOUBLE TAP {}]: Lay down / [{}]: Stand up",
		format: "buttonString(Button.CROUCH), buttonString(Button.JUMP)",
	},
	SPECTATE_CAMERA_USAGE: {
		"en-US": "[{}]: Toggle Spectate Camera / [{} / {}]: Switch Player",
		format:
			"buttonString(Button.ULTIMATE), buttonString(Button.PRIMARY_FIRE), buttonString(Button.SECONDARY_FIRE)",
	},
	TIP_CONTROLS: {
		"en-US": "{} View the top of your screen for controls",
		format: "iconString(Icon.EXCLAMATION_MARK)",
	},
	TIPS_HIDER: {
		"en-US": "{} {}",
		format:
			"iconString(Icon.EXCLAMATION_MARK), random.choice(['Laying down anchors you to the surface, try it on a roof', 'Think outside of the box for your hiding spots', 'Consider hiding in the environment to make yourself harder to spot', 'Some skins can blend in with the environment'])",
	},
	TIPS_SEEKER: {
		"en-US": "{} {}",
		format:
			"iconString(Icon.EXCLAMATION_MARK), random.choice(['Think about where you would hide', 'Some hiders cover themselves in the environment to be harder to spot', 'Some skins can blend in with the environment', 'Hiders can be on the roofs', 'Hold JUMP to glide', 'Use SLINGSHOT to fly across the map and to hard to reach places'])",
	},
	CEILING_ATTACH_USAGE: {
		"en-US": "[Emote + {}]: Attach to Ceiling / [{}]: Detach",
		format: "buttonString(Button.JUMP), buttonString(Button.CROUCH)",
	},
	CEILING_TOO_HIGH: {
		"en-US": "Ceiling is too high or non-existant",
	},
	REVEALING_HIDERS: {
		"en-US": "Revealing the remaining hiders",
	},
	SEEKER_WAIT: {
		"en-US": "Wait until Seeking Phase to Leave",
	},
	SEEKER_ASSISTANCE: {
		"en-US": "{0} THERE ARE HIDERS IN THIS AREA {0}",
		format: "iconString(Icon.WARNING)",
	},
	SEEKER_ASSISTANCE_USAGE: {
		"en-US": "[DOUBLE TAP {}]: Activate Hider Detection Pulse (5s CD / 15s CD)",
		format: "buttonString(Button.CROUCH)",
	},
	SEEKER_ASSISTANCE_NONE: {
		"en-US": "{0} THERE ARE NO HIDERS IN THIS AREA {0}",
		format: "iconString(Icon.NO)",
	},
	SEEKER_ASSISTANCE_COOLDOWN: {
		"en-US": "{0} DETECTION PULSE IS ON COOLDOWN {0}",
		format: "iconString(Icon.CROSS)",
	},
	SEEKER_ASSISTANCE_USING: {
		"en-US": "{0} DETECTION PULSE IS ACTIVE {0}",
		format: "iconString(Icon.CROSS)",
	},
	SEEKER_MOIRA_AMMO: {
		"en-US": "{0}",
		format:
			"abilityIconString(eventPlayer.getCurrentHero(), Button.SECONDARY_FIRE)",
	},
	SEEKER_TIME_GAINED: {
		"en-US": "(hider killed)",
	},
	SEEKER_SOMBRA_STEALTH_DURATION: {
		"en-US": "{0}",
		format: "abilityIconString(eventPlayer.getCurrentHero(), Button.ABILITY_1)",
	},
	BE_CAREFUL: {
		"en-US": "BE CAREFUL!",
	},
	TEAM_SCORE_TITLE: {
		"en-US": "TEAM SCORE:",
	},
	TEAM_SCORE: {
		"en-US": "HIDERS: {}\nSEEKERS: {}",
		format: "HiderTeamScore, SeekerTeamScore",
	},
	JOINED_LATE_1: {
		"en-US": "YOU JOINED LATE!",
	},
	JOINED_LATE_2: {
		"en-US": "PLEASE WAIT FOR THE NEXT ROUND",
	},
	JOINED_LATE_3: {
		"en-US": "PRESS {} TO BEGIN SPECTATING",
		format: "buttonString(Button.JUMP)",
	},
	HIDER_IN_SPAWN: {
		"en-US":
			"{0} YOU WILL BE KILLED IF YOU REMAIN IN SPAWN AFTER HIDING PHASE {0}",
		format: "iconString(Icon.WARNING)",
	},
	SEEKER_BLINDED: {
		"en-US": "You are currently blind while the hiders hide!",
	},
	SOMBRA_VISIBLE: {
		"en-US": "{0} YOU ARE VISIBLE TO SEEKERS {0}",
		format: "iconString(Icon.WARNING)",
	},
	SOMBRA_DESTROY_TRANSLOCATOR: {
		"en-US":
			"{0} YOUR TRANSLOCATOR WILL BE DESTROYED IN {1} SECONDS OR WHEN IT IS OUT OF LOS {0}",
		format:
			"iconString(Icon.WARNING), eventPlayer.getAbilityCooldown(Button.ABILITY_2)",
	},
	SEEKER_OUTLINES_DEFAULT: {
		"en-US": "Default",
	},
	SEEKER_OUTLINES_OCCLUDED: {
		"en-US": "Occluded",
	},
	SEEKER_OUTLINES_ALWAYS: {
		"en-US": "Always",
	},
	SHOW_LAST_HIDER: {
		"en-US": "Last Hider Only",
	},
	RULESET_TITLE: {
		"en-US": "{} RULESET",
		format: "abilityIconString(Hero.TORBJORN, Button.ABILITY_2)",
	},
	RULESET_MAP: {
		"en-US": "MAP: {} [{}]",
		format: "getCurrentMap(), getCurrentGamemode()",
	},
	RULESET_STYLE: {
		"en-US": "STYLE: {}",
		format: "StyleString",
	},
	RULESET_FIRST_WINS: {
		"en-US": "FIRST TEAM TO: {} WIN(S)",
		format: "WS_SET_ADV_WINS",
	},
	RULESET_HIDING_TIME: {
		"en-US": "TIME LIMIT - HIDING: {}:{}",
		format:
			"floor(((WS_SET_HIDETIME % 86400) % 3600) / 60), floor(((WS_SET_HIDETIME % 86400) % 3600) % 60)",
	},
	RULESET_SEEK_TIME: {
		"en-US": "TIME LIMIT - SEEKING: {}:{}",
		format:
			"floor(((WS_SET_SEEKTIME % 86400) % 3600) / 60), floor(((WS_SET_SEEKTIME % 86400) % 3600) % 60)",
	},
	RULESET_PLAYER_SIZE: {
		"en-US": "PLAYER SIZE: {}x",
		format: "WS_SET_ADV_SCALE",
	},
	RULESET_PLAYER_SPEED: {
		"en-US": "PLAYER SPEED: {}x",
		format: "WS_SET_ADV_BASESPEED",
	},
	RULESET_SEEKER_OUTLINES: {
		"en-US": "SEEKER OUTLINES: {}",
		format: "SeekerOutlineString",
	},
	RULESET_HIDER_OUTLINES: {
		"en-US": "HIDER OUTLINES: {}",
		format: "WS_SET_USEOUTLINE",
	},
	RULESET_SEEKER_ASSIST: {
		"en-US": "SEEKER ASSISTANCE: {}",
		format: "WS_SET_SEEKER_ASSIST",
	},
	RULESET_AUTOMATIC: {
		"en-US": "Automatic",
	},
	RULESET_TANK_SCALING: {
		"en-US": "HIDER TANK SCALING: {}",
		format: "TankScalingString",
	},
	RULESET_SLINGSHOT: {
		"en-US": "ALLOW SLINGSHOT TOOL: {}",
		format: "WS_SET_USE_SLINGSHOT",
	},
	RULESET_SLOW_HIDERS: {
		"en-US": "SLOW HIDERS WHEN IN LOS OF SEEKER: {}",
		format: "WS_SET_SLOWHIDER",
	},
	RULESET_LAYING_DOWN: {
		"en-US": "ALLOW HIDERS TO LAY DOWN: {}",
		format: "WS_SET_LAYING_DOWN",
	},
	RULESET_CEILING_ATTACH: {
		"en-US": "ALLOW HIDERS TO ATTACH TO CEILING: {}",
		format: "WS_SET_ATTACH_CEILING",
	},
	RULESET_SHOW_HIDERS: {
		"en-US": "SHOW REMAINING HIDERS AFTER THE ROUND: {}",
		format: "ShowHiderString",
	},
	RULESET_WB_INF_GRAPPLE: {
		"en-US": "WRECKING HIDER INFINITE GRAPPLE: {}",
		format: "WS_SET_ADV_INF_HAMMOND_GRAPPLE",
	},
	RULESET_RESTRICT_SEEKER_HERO: {
		"en-US": "RESTRICT SEEKER HERO ROSTER: {}",
		format: "not WS_SET_ADV_SEEK_ALLOWH",
	},
	RULESET_MATCH_VOICE_ENABLED: {
		"en-US": "MATCH VOICE CHAT: ENABLED",
	},
	RULESET_CHANGE_HOST: {
		"en-US":
			"TO CUSTOMIZE RULESET (HOST ONLY):\nGO TO LOBBY > SETTINGS > WORKSHOP SETTINGS",
	},
	RULESET_CHECK_CHANGE: {
		"en-US":
			"FOR MORE INFORMATION ON RULESET:\nGO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP\n",
	},
};
result =
	"globalvar practiceRangeTranslations = " +
	"[" +
	practiceRangeTranslations.join() +
	"]";

// translate
for (var translation in translations) {
	//check if all languages are here
	for (var lang of availableLanguages) {
		if (translations[translation][lang] === undefined) {
			throw new Error(
				"Missing language '" + lang + "' for translation '" + translation + "'"
			);
		}
	}

	const varDeclaration = translations[translation].in_player_hud
		? "globalvar STR_" + translation + " = ["
		: "#!define STR_" + translation + " [";

	console.log(translations[translation].format);

	result +=
		varDeclaration +
		availableLanguages.map(
			(x) =>
				JSON.stringify(translations[translation][x]).replace(
					/##(\w+)##/g,
					'"$1"'
				) +
				(translations[translation].format
					? ".format(" + translations[translation].format + ")"
					: "")
		) +
		'][max(false, practiceRangeTranslations.index("{0}".format(Map.PRACTICE_RANGE)))]\n';
}
result;
