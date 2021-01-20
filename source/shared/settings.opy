settings {
    "main": {
        "description": 'The classic Hide & Seek game has returned as a new and improved workshop gamemode! A new additional level of customization is offered to hosts through Workshop Settings; make everyone small, change the time for each phase, or even how the game plays with different game styles\n[Created by CaptCaptain#11421] [For the latest code, visit: https://workshop.codes/hide-and-seek-ult]'
    },
    "lobby": {
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "mapRotation": "afterGame",
        "returnToLobby": "never",
        "teamBalancing": "afterGame",
        "team1Slots": 9,
        "team2Slots": 3
    },
    "gamemodes": {
        "skirmish": {
            "disabledMaps": [
                "workshopIsland", "workshopIslandNight", "workshopChamber", "workshopGreenScreen", "workshopExpanse", "workshopExpanseNight"
            ]
        },
        "tdm": {
            "enabledMaps": [
                "castillo", "chateauGuillard", "kanezaka", "ecopointAntarctica", "ecopointAntarcticaWinter",
                "necropolis", "petra", "blackForest", "blackForestWinter"
            ]
        },
        "ctf": {
            "enabledMaps": [
                "ayutthaya", "busanDowntownLny", "busanSanctuaryLny"
            ]
        },
        "general": {
            "heroLimit": "off",
            "enableRandomHeroes": false,
            "spawnHealthPacks": "disabled",
            "gamemodeStartTrigger": "immediately",
            "flagPickupTime": 5
        }
    },
    "heroes": {
        "allTeams": {
            "general": {
                "enableUlt": false,
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            },
            "dva": {
                "enableSpawningWithUlt": true
            }
        },
        "team2": {
            "general": {
                "abilityCooldown%": 50
            }
        }
    }
}

# Translations
#!define GetTranslatedText() __script__("translation.js")
GetTranslatedText()

enum STYLE:
    DEFAULT,
    CLASSIC,
    RESTRICTED,
    MERCY_REIN,
    GLITCH,
    TINY

enum ACCESSIBILITY:
    DVA_MECH_ALLOW_BOTH,
    DVA_MECH_ALLOW_DEMECH,
    DVA_MECH_DISABLED,
    TANKS_SCALE_ALL,
    TANKS_SCALE,
    TANKS_NOSCALE,
    3RD_CAMERA_ON,
    3RD_CAMERA_OFF,
    3RD_CAMERA_TOGGLE,
    SEEKER_ASSIST_ON,
    SEEKER_ASSIST_OFF,
    SEEKER_OUTLINES_DEFAULT,
    SEEKER_OUTLINES_OCCLUDED,
    SEEKER_OUTLINES_ALWAYS

enum SHOW_HIDERS:
    LAST_HIDER,
    ALL_HIDERS,
    OFF

enum SHOW_DEBUG_STATS:
    ALL,
    HOST,
    NONE

globalvar CURRENT_VERSION = "2.1.0"

# Default settings
globalvar WS_SET_USEOUTLINE = createWorkshopSetting(bool, "Ruleset", "Hider Outlines", false, 4)
globalvar WS_SET_HIDETIME_RAW = createWorkshopSetting(enum["1:30", "1:00", "0:45"], "Ruleset", "Time Limit: Hiding", 1, 2)
globalvar WS_SET_HIDETIME = [90, 60, 45][WS_SET_HIDETIME_RAW]
globalvar WS_SET_SEEKTIME_RAW = createWorkshopSetting(enum["5:00", "4:30", "4:00", "3:30", "3:00", "2:30", "2:00"], "Ruleset", "Time Limit: Seeking", 2, 2)
globalvar WS_SET_SEEKTIME = [300, 270, 240, 210, 180, 150, 120][WS_SET_SEEKTIME_RAW]
globalvar WS_SET_MODE_RAW = createWorkshopSetting(enum["Default", "Glitch (Noclip)", "TINY", "Mercy V. Reinhardt"], "Ruleset", "Style", 0, 0)
globalvar WS_SET_MODE = [STYLE.DEFAULT, STYLE.GLITCH, STYLE.TINY, STYLE.MERCY_REIN][WS_SET_MODE_RAW]
globalvar WS_SET_REQUIRED_RATIO = createWorkshopSetting(enum["1:3", "1:2", "1:1"], "Ruleset", "Required Seeker to Hider Ratio", 0, 3)
globalvar WS_SET_REQUIRED_HIDERS = [3, 2, 1][WS_SET_REQUIRED_RATIO]
globalvar WS_SET_WAITING_MAXTIME_RAW = createWorkshopSetting(enum["IMMEDIATELY", "Wait For Players (Timeout)", "Wait For Players (No Timeout)"], "Ruleset", "Game Mode Start", 1, 1)
globalvar WS_SET_WAITING_MAXTIME = [0, 5, 9999][WS_SET_WAITING_MAXTIME_RAW]
globalvar WS_SET_SLOWHIDER = createWorkshopSetting(bool, "Ruleset", "Slow Hider When In Line Of Sight Of Seeker", true, 4)
globalvar WS_SET_SEEKER_OUTLINES_RAW = createWorkshopSetting(enum["Default", "Occluded", "Always"], "Ruleset", "Seeker Outlines", 0, 4)
globalvar WS_SET_SEEKER_OUTLINES = [ACCESSIBILITY.SEEKER_OUTLINES_DEFAULT, ACCESSIBILITY.SEEKER_OUTLINES_OCCLUDED, ACCESSIBILITY.SEEKER_OUTLINES_ALWAYS][WS_SET_SEEKER_OUTLINES_RAW]
globalvar WS_SET_SHOW_HIDERS_RAW = createWorkshopSetting(enum["Last Hider Only", "On", "Off"], "Ruleset", "Show Remaining Hiders When Round Ends", 2, 5)
globalvar WS_SET_SHOW_HIDERS = [SHOW_HIDERS.LAST_HIDER, SHOW_HIDERS.ALL_HIDERS, SHOW_HIDERS.OFF][WS_SET_SHOW_HIDERS_RAW]
globalvar WS_SET_END_RAW = createWorkshopSetting(enum["SKIP END GAME SCREEN", "SKIP POTG", "DO NOTHING"], "Ruleset", "WHEN MATCH IS COMPLETE (SKIRMISH)", 0, 7)
globalvar WS_SET_END = [25.9, 8, 9999][WS_SET_END_RAW]

# Accessibility Settings
globalvar WS_SET_3RD_CAM_RAW = createWorkshopSetting(enum["First Person", "Third Person", "Toggle"], "Accessibility Settings", "Camera Mode", 0, 6)
globalvar WS_SET_3RD_CAM = [ACCESSIBILITY.3RD_CAMERA_OFF, ACCESSIBILITY.3RD_CAMERA_ON, ACCESSIBILITY.3RD_CAMERA_TOGGLE][WS_SET_3RD_CAM_RAW]
globalvar WS_SET_SEEKER_ASSIST = createWorkshopSetting(bool, "Accessibility Settings", "Seeker Assistance", false, 5)
globalvar WS_SET_LAYING_DOWN = createWorkshopSetting(bool, "Accessibility Settings", "Allow Hiders to Lay Down", false, 5)
globalvar WS_SET_USE_SLINGSHOT = createWorkshopSetting(bool, "Accessibility Settings", "Allow Slingshot Tool", false, 5)
globalvar WS_SET_ADV_DVA_MECH_RAW = createWorkshopSetting(enum["Allow De-mech Only", "Allow Re-mech and De-mech", "Off"], "Accessibility Settings", "D.va Player Accessibility", 1, 2)
globalvar WS_SET_ADV_DVA_MECH = [ACCESSIBILITY.DVA_MECH_ALLOW_DEMECH, ACCESSIBILITY.DVA_MECH_ALLOW_BOTH, ACCESSIBILITY.DVA_MECH_DISABLED][WS_SET_ADV_DVA_MECH_RAW]
globalvar WS_SET_ADV_INF_HAMMOND_GRAPPLE = createWorkshopSetting(bool, "Accessibility Settings", "Wrecking Ball Hider Accessibility: Infinite Grapple", false, 2)
globalvar WS_SET_ADV_TANKSCALING_RAW = createWorkshopSetting(enum["Scale Down All Tanks", "Scale Down Tanks Automatically", "Off"], "Accessibility Settings", "Tank Hider Accessibility", 2, 2)
globalvar WS_SET_ADV_TANKSCALING = [ACCESSIBILITY.TANKS_SCALE_ALL, ACCESSIBILITY.TANKS_SCALE, ACCESSIBILITY.TANKS_NOSCALE][WS_SET_ADV_TANKSCALING_RAW]

# Advanced Settings
globalvar WS_SET_ADV_WINS_RAW = createWorkshopSetting(enum["1 win", "2 wins", "3 wins"], "Advanced Settings", "FIRST TEAM TO", 0, 0)
globalvar WS_SET_ADV_WINS = [1, 2, 3][WS_SET_ADV_WINS_RAW]
globalvar WS_SET_ADV_SCALE = createWorkshopSetting(float[0.1:1], "Advanced Settings", "Player Size Scalar", 1, 0)
globalvar WS_SET_ADV_SEEK_ALLOWH = createWorkshopSetting(bool, "Advanced Settings", "Allow Restricted Seeker Heroes (Moira, Zenyatta, Sombra)", false, 4)
globalvar WS_SET_ADV_BASESPEED = createWorkshopSetting(float[1:5], "Advanced Settings", "Player Speed Scalar", 1, 1)
globalvar WS_SET_ADV_DEBUGSTATS_RAW = createWorkshopSetting(enum["HOST ONLY", "ALL PLAYERS", "NONE"], "Advanced Settings", "Show Debug Stats", 2, 6)
globalvar WS_SET_ADV_DEBUGSTATS = [SHOW_DEBUG_STATS.HOST, SHOW_DEBUG_STATS.ALL, SHOW_DEBUG_STATS.NONE][WS_SET_ADV_DEBUGSTATS_RAW]

rule "____________Shared Rules": @Delimiter
#!include "game.opy"
#!include "player.opy"
#!include "hider.opy"
#!include "seeker.opy"
rule "____________Skirmish Rules": @Delimiter
#!include "../skirmish-ctf/player.opy"
#!include "../skirmish-ctf/hider.opy"
#!include "../skirmish-ctf/seeker.opy"
rule "____________TDM Rules": @Delimiter
#!include "../tdm/player.opy"
#!include "../tdm/hider.opy"
#!include "../tdm/seeker.opy"