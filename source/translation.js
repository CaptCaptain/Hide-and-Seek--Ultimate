const availableLanguages = ["en-US"]
const practiceRangeTranslations = ['"Practice Range"']
const translations = {
    STYLE_DEFAULT: {
        "en-US": "DEFAULT"
    },
    STYLE_GLITCH: {
        "en-US": "GLITCH"
    },
    STYLE_TINY: {
        "en-US": "TINY"
    },
    STYLE_MERCY_V_REIN: {
        "en-US": "MERCY VS. REINHARDT"
    },
    GAME_STATE_WAITING: {
        "en-US": "Waiting For Players"
    },
    GAME_STATE_HIDING: {
        "en-US": "Hiding"
    },
    GAME_STATE_SEEKING: {
        "en-US": "Seeking"
    },
    GAME_STATE_RESULTS: {
        "en-US": "Results"
    },
    GAME_STATE_END: {
        "en-US": "End Game"
    },
    GAME_TITLE: {
        "en-US": "Hide & Seek"
    },
    GAME_SUBTITLE: {
        "en-US": "Ultimate"
    },
    GAME_STYLE: {
        "en-US": "Style"
    },
    GAME_WAITING_FOR_PLAYERS: {
        "en-US": "Waiting For Players"
    },
    HIDER: {
        "en-US": "Hider"
    },
    SEEKER: {
        "en-US": "Seeker"
    },
    PHASE: {
        "en-US": "Phase"
    },
    WEBLINK: {
        "en-US": "For Latest Version, head to: https://workshop.codes/hide-and-seek-ult"
    },
    VERSION: {
        "en-US": 'Current Version: {}\n',
        format: 'CURRENT_VERSION'
    },
    GAME_NAME: {
        "en-US": '{} Hide & Seek: Ultimate by CaptCaptain#11421',
        format: 'abilityIconString(random.choice(getAllHeroes()), Button.ULTIMATE)'
    },
    SLINGSHOT_USAGE_TOGGLE: {
        "en-US": 'Toggle Slingshot'
    },
    SLINGSHOT_USAGE_CONFIRM: {
        "en-US": 'Confirm'
    },
    SLINGSHOT_CANNOT_USE: {
        "en-US": 'CANNOT USE SLINGSHOT WHILE IN LOS OF SEEKERS'
    },
    SLINGSHOT_ON_COOLDOWN: {
        "en-US": 'SLINGSHOT IS ON COOLDOWN'
    },
    SLINGSHOT_CANT_IN_AIR: {
        "en-US": 'SLINGSHOT CANNOT BE USED WHILE IN THE AIR'
    },
    THIRD_PERSON_CAMERA_USAGE: {
        "en-US": 'Toggle third person camera'
    },
    LAYING_DOWN_EMOTE: {
        "en-US": 'Emote'
    },
    LAYING_DOWN_LAYING: {
        "en-US": 'Laying Down'
    },
    LAYING_DOWN_STAND: {
        "en-US": 'Stand up'
    },
    REVEALING_HIDERS: {
        "en-US": 'Revealing the remaining hiders'
    },
    SEEKER_WAIT: {
        "en-US": 'Wait until Seeking Phase to Leave'
    },
    SEEKER_ASSISTANCE: {
        "en-US": '{0} THERE ARE HIDERS IN THIS AREA {0}',
        format: 'iconString(Icon.WARNING)'
    },
    BE_CAREFUL: {
        "en-US": 'BE CAREFUL!'
    },
    TEAM_SCORE_TITLE: {
        "en-US": 'TEAM SCORE:'
    },
    TEAM_SCORE: {
        "en-US": 'HIDERS: {}\nSEEKERS: {}',
        format: 'HiderTeamScore, SeekerTeamScore'
    },
    JOINED_LATE_1: {
        "en-US": 'YOU JOINED LATE!'
    },
    JOINED_LATE_2: {
        "en-US": 'YOU WILL BE PUT INTO SPECTATOR'
    },
    JOINED_LATE_3: {
        "en-US": 'PLEASE WAIT FOR THE NEXT ROUND'
    },
    HIDER_IN_SPAWN: {
        "en-US": '{0} YOU WILL BE KILLED IF YOU REMAIN IN SPAWN AFTER HIDING PHASE {0}',
        format: 'iconString(Icon.WARNING)'
    },
    SOMBRA_VISIBLE: {
        "en-US": '{0} YOU ARE VISIBLE TO SEEKERS {0}',
        format: 'iconString(Icon.WARNING)'
    },
    SOMBRA_DESTROY_TRANSLOCATOR: {
        "en-US": '{0} YOUR TRANSLOCATOR WILL BE DESTROYED IN {1} SECONDS OR WHEN IT IS OUT OF LOS {0}',
        format: 'iconString(Icon.WARNING), eventPlayer.getAbilityCooldown(Button.ABILITY_2)'
    },
    SEEKER_OUTLINES_DEFAULT: {
        "en-US": "Default"
    },
    SEEKER_OUTLINES_OCCLUDED: {
        "en-US": "Occluded"
    },
    SEEKER_OUTLINES_ALWAYS: {
        "en-US": "Always"
    },
    SHOW_LAST_HIDER: {
        "en-US": "Last Hider Only"
    },
    RULESET_TITLE: {
        "en-US": '{} RULESET',
        format: 'abilityIconString(Hero.TORBJORN, Button.ABILITY_2)'
    },
    RULESET_STYLE: {
        "en-US": 'STYLE: {}',
        format: 'StyleString'
    },
    RULESET_FIRST_WINS: {
        "en-US": 'FIRST TEAM TO: {} WIN(S)',
        format: 'WS_SET_ADV_WINS'
    },
    RULESET_HIDING_TIME: {
        "en-US": 'HIDING TIME: {}:{}',
        format: 'floor(((WS_SET_HIDETIME % 86400) % 3600) / 60), floor(((WS_SET_HIDETIME % 86400) % 3600) % 60)'
    },
    RULESET_SEEK_TIME: {
        "en-US": 'SEEK TIME: {}:{}',
        format: 'floor(((WS_SET_SEEKTIME % 86400) % 3600) / 60), floor(((WS_SET_SEEKTIME % 86400) % 3600) % 60)'
    },
    RULESET_PLAYER_SIZE: {
        "en-US": 'PLAYER SIZE: {}x',
        format: 'WS_SET_ADV_SCALE'
    },
    RULESET_PLAYER_SPEED: {
        "en-US": 'PLAYER SPEED: {}x',
        format: 'WS_SET_ADV_BASESPEED'
    },
    RULESET_SEEKER_OUTLINES: {
        "en-US": 'SEEKER OUTLINES: {}',
        format: 'SeekerOutlineString'
    },
    RULESET_HIDER_OUTLINES: {
        "en-US": 'HIDER OUTLINES: {}',
        format: 'WS_SET_USEOUTLINE'
    },
    RULESET_SEEKER_ASSIST: {
        "en-US": 'SEEKER ASSISTANCE: {}',
        format: 'WS_SET_SEEKER_ASSIST'
    },
    RULESET_AUTOMATIC: {
        "en-US": 'Automatic'
    },
    RULESET_TANK_SCALING: {
        "en-US": 'HIDER TANK SCALING: {}',
        format: 'TankScalingString'
    },
    RULESET_SLINGSHOT: {
        "en-US": 'ALLOW SLINGSHOT TOOL: {}',
        format: 'WS_SET_USE_SLINGSHOT'
    },
    RULESET_SLOW_HIDERS: {
        "en-US": 'SLOW HIDERS WHEN IN LOS OF SEEKER: {}',
        format: 'WS_SET_SLOWHIDER'
    },
    RULESET_LAYING_DOWN: {
        "en-US": 'ALLOW HIDERS TO LAY DOWN: {}',
        format: 'WS_SET_LAYING_DOWN'
    },
    RULESET_SHOW_HIDERS: {
        "en-US": 'SHOW REMAINING HIDERS AFTER ROUND: {}',
        format: 'ShowHiderString'
    },
    RULESET_WB_INF_GRAPPLE: {
        "en-US": 'WRECKING HIDER INFINITE GRAPPLE: {}',
        format: 'WS_SET_ADV_INF_HAMMOND_GRAPPLE'
    },
    RULESET_RESTRICT_SEEKER_HERO: {
        "en-US": 'RESTRICT SEEKER HERO ROSTER: {}',
        format: 'not WS_SET_ADV_SEEK_ALLOWH'
    },
    RULESET_CHANGE_HOST: {
        "en-US": 'TO CUSTOMIZE RULESET (HOST ONLY):\nGO TO LOBBY > SETTINGS > WORKSHOP SETTINGS'
    },
    RULESET_CHECK_CHANGE: {
        "en-US": 'FOR MORE INFORMATION ON RULESET:\nGO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP\n'
    }
}
result = 'globalvar practiceRangeTranslations = ' + '[' + practiceRangeTranslations.join() + ']';

// translate
for (var translation in translations) {

    //check if all languages are here
    for (var lang of availableLanguages) {
        if (translations[translation][lang] === undefined) {
            throw new Error("Missing language '"+lang+"' for translation '"+translation+"'");
        }
    }

    const varDeclaration = translations[translation].in_player_hud ? "globalvar STR_"+translation+" = [" : "#!define STR_"+translation+" [";

    console.log(translations[translation].format)

    result += varDeclaration+availableLanguages.map(x => JSON.stringify(translations[translation][x]).replace(/##(\w+)##/g, '"$1"') + (translations[translation].format ? ".format("+translations[translation].format+")" : ""))+'][max(false, practiceRangeTranslations.index("{0}".format(Map.PRACTICE_RANGE)))]\n';
}
result