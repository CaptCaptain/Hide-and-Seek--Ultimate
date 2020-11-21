settings {
    "main": {
        "description": 'The classic Hide & Seek game has returned as a new and improved workshop gamemode! A new additional level of customization is offered to hosts through Workshop Settings; make everyone small, change the time for each phase, or even how the game plays with styles such as "Glitch" or "Mercy V. Reinhardt"\n[Created by CaptCaptain#11421]'
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
        "general": {
            "heroLimit": "off",
            "enableRandomHeroes": false,
            "spawnHealthPacks": "disabled"
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

#!obfuscate

enum STYLE:
    DEFAULT = "DEFAULT",
    CLASSIC = "CLASSIC",
    RESTRICTED = "RESTRICTED",
    MERCY_REIN = "MERCY VS. REINHARDT",
    GLITCH = "GLITCH"

enum ACCESSIBILITY:
    DVA_MECH_ALLOW_BOTH,
    DVA_MECH_ALLOW_DEMECH,
    DVA_MECH_DISABLED,
    WB_GRAPPLE_ALLOW,
    WB_GRAPPLE_ALLOW_COOLDOWN,
    WB_GRAPPLE_DISABLED

globalvar CURRENT_VERSION = "1.0.0"
globalvar CURRENT_CODE = "Code: D0XT4"
globalvar CURRENT_PATCHNOTES = "Latest Patch Notes\n* Initial Release\n(For previous patch notes, visit: N/A)"

# Default settings
globalvar WORKSHOP_SET_USEOUTLINE = createWorkshopSetting(bool, "Ruleset", "Hider Outlines", false, 4)
globalvar WORKSHOP_SET_HIDETIME_RAW = createWorkshopSetting(enum["1:30", "1:00", "0:45"], "Ruleset", "Hiding Time", 1, 2)
globalvar WORKSHOP_SET_HIDETIME = [90, 60, 45][WORKSHOP_SET_HIDETIME_RAW]
globalvar WORKSHOP_SET_SEEKTIME_RAW = createWorkshopSetting(enum["5:00", "4:30", "4:00", "3:30", "3:00", "2:30", "2:00"], "Ruleset", "Seeking Time", 2, 2)
globalvar WORKSHOP_SET_SEEKTIME = [300, 270, 240, 210, 180, 150, 120][WORKSHOP_SET_SEEKTIME_RAW]
globalvar WORKSHOP_SET_MODE_RAW = createWorkshopSetting(enum["Default", "Glitch (Noclip)", "Mercy V. Reinhardt"], "Ruleset", "Style", 0, 0)
globalvar WORKSHOP_SET_MODE = [STYLE.DEFAULT, STYLE.GLITCH, STYLE.MERCY_REIN][WORKSHOP_SET_MODE_RAW]
globalvar WORKSHOP_SET_REQUIRED_RATIO = createWorkshopSetting(enum["1:3", "1:2", "1:1"], "Ruleset", "Required Seeker to Hider Ratio", 0, 3)
globalvar WORKSHOP_SET_REQUIRED_HIDERS = [3, 2, 1][WORKSHOP_SET_REQUIRED_RATIO]
globalvar WORKSHOP_SET_WAITING_MAXTIME_RAW = createWorkshopSetting(enum["IMMEDIATELY", "Wait For Players (Timeout)", "Wait For Players (No Timeout)"], "Ruleset", "Game Mode Start", 1, 1)
globalvar WORKSHOP_SET_WAITING_MAXTIME = [0, 25, 9999][WORKSHOP_SET_WAITING_MAXTIME_RAW]
globalvar WORKSHOP_SET_SLOWHIDER = createWorkshopSetting(bool, "Ruleset", "Slow Hider When In Line Of Sight Of Seeker", true, 4)

# Advanced Settings
globalvar WORKSHOP_SET_ADV_WINS_RAW = createWorkshopSetting(enum["1 win", "2 wins", "3 wins"], "Advanced Settings", "FIRST TEAM TO", 0, 0)
globalvar WORKSHOP_SET_ADV_WINS = [1, 2, 3][WORKSHOP_SET_ADV_WINS_RAW]
globalvar WORKSHOP_SET_ADV_END_RAW = createWorkshopSetting(enum["SKIP END GAME SCREEN", "SKIP POTG", "DO NOTHING"], "Advanced Settings", "WHEN MATCH IS COMPLETE", 0, 5)
globalvar WORKSHOP_SET_ADV_END = [25.9, 8, 9999][WORKSHOP_SET_ADV_END_RAW]
globalvar WORKSHOP_SET_ADV_SCALE = createWorkshopSetting(float[0.1:1], "Advanced Settings", "Player Size Scalar", 1, 0)
globalvar WORKSHOP_SET_ADV_SEEK_ALLOWH = createWorkshopSetting(bool, "Advanced Settings", "Allow Restricted Seeker Heroes (Moira, Zenyatta, Sombra)", false, 4)
globalvar WORKSHOP_SET_ADV_DVA_MECH_RAW = createWorkshopSetting(enum["Allow De-mech Only", "Allow Re-mech and De-mech", "Off"], "Advanced Settings", "D.va Player Accessibility", 1, 2)
globalvar WORKSHOP_SET_ADV_DVA_MECH = [ACCESSIBILITY.DVA_MECH_ALLOW_DEMECH, ACCESSIBILITY.DVA_MECH_ALLOW_BOTH, ACCESSIBILITY.DVA_MECH_DISABLED][WORKSHOP_SET_ADV_DVA_MECH_RAW]
#globalvar WORKSHOP_SET_ADV_WB_GRAPPLE_RAW = createWorkshopSetting(enum["Allow when in Line Of Sight of Seeker (No Cooldown)", "Allow when in Line Of Sight of Seeker (Cooldown)", "Disabled when in Line Of Sight of Seeker"], "Advanced Settings", "Wrecking Ball Grapple Player Accessibility", 0, 2)
#globalvar WORKSHOP_SET_ADV_WB_GRAPPLE = [ACCESSIBILITY.WB_GRAPPLE_ALLOW, ACCESSIBILITY.WB_GRAPPLE_ALLOW_COOLDOWN, ACCESSIBILITY.WB_GRAPPLE_DISABLED][WORKSHOP_SET_ADV_WB_GRAPPLE_RAW]
globalvar WORKSHOP_SET_ADV_USEPRERELEASE = false #createWorkshopSetting(bool, "Advanced Settings", "Use Pre-release Update if Available", false, 6)
globalvar WORKSHOP_SET_ADV_BASESPEED = createWorkshopSetting(float[1:5], "Advanced Settings", "Player Speed Scalar", 1, 1)

#!include "game.opy"
#!include "player.opy"