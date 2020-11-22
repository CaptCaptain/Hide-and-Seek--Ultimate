#!mainFile "settings.opy"

globalvar Hud_GameInfo
globalvar Hud_GameTitle
globalvar globalHudIndex = 0
playervar BaseMoveSpeed = 100 * WORKSHOP_SET_ADV_BASESPEED
playervar BaseJumpHeight = 100 * WORKSHOP_SET_ADV_BASESPEED
playervar HiderSlowFactor = 2
playervar DvaMechPosition
playervar LastWalkablePosition

subroutine RestrictAbilities

def RestrictAbilities():
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    if WORKSHOP_SET_MODE == STYLE.MERCY_REIN: goto skip_evaluation
    switch eventPlayer.getTeam():
        case Team.1:
            switch eventPlayer.getCurrentHero():
                case Hero.MERCY:
                    eventPlayer.setAbility2Enabled(false)
                    break
            break
        case Team.2:
            switch eventPlayer.getCurrentHero():
                case Hero.ORISA:
                    eventPlayer.setSecondaryFireEnabled(false)
                    break
                case Hero.HANZO:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.SYMMETRA:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.TORBJORN:
                    eventPlayer.setAbility1Enabled(false)
                    break
                case Hero.WIDOWMAKER:
                    eventPlayer.setAbility2Enabled(false)
                    break
                case Hero.JUNKRAT:
                    eventPlayer.setAbility2Enabled(false)
                    break
            break
    skip_evaluation:

rule "Player Huds":
    @Event eachPlayer

    # Creates the Objective Hud
    hudText(eventPlayer, "{} {}".format(abilityIconString(eventPlayer.getCurrentHero(), Button.ULTIMATE) if eventPlayer.getTeam() == Team.1 else abilityIconString(eventPlayer.getCurrentHero(), Button.PRIMARY_FIRE), "HIDER" if eventPlayer.getTeam() == Team.1 else "SEEKER"), "PHASE: {}".format(CurrentGameState), "{}:{}".format(floor(((CurrentTime % 86400) % 3600) / 60), floor(((CurrentTime % 86400) % 3600) % 60)) if CurrentTime > 60 else "{}".format(CurrentTime), HudPosition.TOP, 1, Color.BLUE if eventPlayer.getTeam() == Team.1 else Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)

    wait(9999)

rule "Title Hud":
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "HIDE & SEEK", getObjectivePosition(getCurrentObjective()) + vect(0, 5, 0),5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "ULTIMATE", getObjectivePosition(getCurrentObjective()) + vect(0, 4.5, 0),2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.SKY_BLUE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "STYLE: {}".format(WORKSHOP_SET_MODE), getObjectivePosition(getCurrentObjective()) + vect(0, 4, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.ROSE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createInWorldText(getAllPlayers(), "WAITING FOR PLAYERS".format(RequiredHiders), getObjectivePosition(getCurrentObjective()) + vect(0, 3.25, 0),1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
    Hud_GameTitle.append(getLastCreatedText())
    createEffect(getAllPlayers(), Effect.SPHERE, Color.TURQUOISE, getObjectivePosition(getCurrentObjective()), 20, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    Hud_GameTitle.append(getLastCreatedEntity())

    waitUntil(CurrentGameState != GAME_STATE.WAITING, 9999)

    for globalHudIndex in range(0, len(Hud_GameTitle)):
        destroyInWorldText(Hud_GameTitle[globalHudIndex])
        destroyEffect(Hud_GameTitle[globalHudIndex])
    Hud_GameTitle = null

rule "Global Huds":
    @Condition CurrentGameState == GAME_STATE.HIDING

    hudSubheader(getAllPlayers(), CURRENT_PATCHNOTES, HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "Version: {} ({})\n".format(CURRENT_VERSION, CURRENT_CODE), HudPosition.LEFT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "{} Hide & Seek: Ultimate by CaptCaptain#11421".format(abilityIconString(random.choice(getAllHeroes()), Button.ULTIMATE)), HudPosition.LEFT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudHeader(getAllPlayers(), "{} RULESET:".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2)), HudPosition.LEFT, 1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WORKSHOP_SET_ADV_USEPRERELEASE:
        hudSubtext(getAllPlayers(), "USE PRE-RELEASE UPDATE: {}".format(WORKSHOP_SET_ADV_USEPRERELEASE), HudPosition.LEFT, 1.1, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())


    hudSubtext(getAllPlayers(), "STYLE: {}".format(WORKSHOP_SET_MODE), HudPosition.LEFT, 2, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "FIRST TEAM TO: {} WIN(S)".format(WORKSHOP_SET_ADV_WINS), HudPosition.LEFT, 3, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "SEEK TIME: {}:{}".format(floor(((WORKSHOP_SET_SEEKTIME % 86400) % 3600) / 60), floor(((WORKSHOP_SET_SEEKTIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "HIDING TIME: {}:{}".format(floor(((WORKSHOP_SET_HIDETIME % 86400) % 3600) / 60), floor(((WORKSHOP_SET_HIDETIME % 86400) % 3600) % 60)), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "PLAYER SIZE: {}x".format(WORKSHOP_SET_ADV_SCALE), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubtext(getAllPlayers(), "PLAYER SPEED: {}x".format(WORKSHOP_SET_ADV_BASESPEED), HudPosition.LEFT, 4, Color.ROSE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "TO CUSTOMIZE RULESET (HOST ONLY):\nGO TO LOBBY > SETTINGS > WORKSHOP SETTINGS", HudPosition.LEFT, 5, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    hudSubheader(getAllPlayers(), "FOR MORE INFORMATION ON RULESET:\nGO TO LOBBY > RIGHT CLICK MAP PICTURE > SCROLL DOWN TO WORKSHOP\n", HudPosition.LEFT, 6, Color.TURQUOISE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
    Hud_GameInfo.append(getLastCreatedText())

    if WORKSHOP_SET_ADV_WINS > 1:
        hudText(getAllPlayers(), "TEAM SCORE:", "", "HIDERS: {}\nSEEKERS: {}".format(HiderTeamScore, SeekerTeamScore), HudPosition.LEFT, 6, Color.TEAM_1, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_SORT_ORDER, SpecVisibility.DEFAULT)
        Hud_GameInfo.append(getLastCreatedText())

rule "Remove Global Huds":
    @Condition CurrentGameState == GAME_STATE.SEEKING
    for globalHudIndex in range(0, len(Hud_GameInfo)):
        destroyHudText(Hud_GameInfo[globalHudIndex])
    Hud_GameInfo = null

rule "Player Scaling":
    @Event eachPlayer
    @Condition WORKSHOP_SET_ADV_SCALE > 1 or WORKSHOP_SET_ADV_SCALE < 1

    # Scales the player
    eventPlayer.startScalingSize(WORKSHOP_SET_ADV_SCALE, false)
    eventPlayer.startScalingBarriers(WORKSHOP_SET_ADV_SCALE, false)
    eventPlayer.startModifyingVoicelinePitch(2 - WORKSHOP_SET_ADV_SCALE, false)

rule "Player Setup":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()
    eventPlayer.disableRespawn()
    eventPlayer.setMoveSpeed(eventPlayer.BaseMoveSpeed)
    eventPlayer.setJumpVerticalSpeed(eventPlayer.BaseJumpHeight)
    
    # Glitch Mode
    if WORKSHOP_SET_MODE == STYLE.GLITCH:
        eventPlayer.disableEnvironmentCollision(false)

    # Teleport to Objective
    waitUntil(eventPlayer.hasSpawned(), 9999)
    eventPlayer.DvaMechPosition = eventPlayer.getPosition()
    RestrictAbilities()
    if CurrentGameState == GAME_STATE.WAITING:
        eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(getCurrentObjective())))

rule "Reset Ammo":
    @Event eachPlayer
    @Condition not eventPlayer.isFiringPrimaryFire() and not eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.getAmmo(0) > 0

    # Reset ammo when player has not fired for more than a second
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))

rule "Resurrect":
    @Event playerDied
    @Condition not eventPlayer.isInSpawnRoom()
    @Condition eventWasEnvironment or attacker() == victim()

    # If the player dies to the environment or self-destructs.
    eventPlayer.resurrect()
    eventPlayer.teleport(eventPlayer.LastWalkablePosition if eventPlayer.LastWalkablePosition != null else nearestWalkablePosition(eventPlayer.getPosition()))
    eventPlayer.setStatusEffect(null, Status.STUNNED, 2)
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 1)
    smallMessage(eventPlayer, "BE CAREFUL!")

rule "Disable Certain Abilities":
    @Event eachPlayer
    @Condition eventPlayer.isInSpawnRoom()

    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setSecondaryFireEnabled(false)

    waitUntil(not eventPlayer.isInSpawnRoom(), 9999)

    RestrictAbilities()

rule "Set Last Walkable Position":
    @Event eachPlayer
    @Condition eventPlayer.isInAir()

    eventPlayer.LastWalkablePosition = nearestWalkablePosition(eventPlayer.getPosition())

    waitUntil(eventPlayer.isOnGround(), 9999)

# Accessibility Rules
rule "D.va: TP to Mech Position (Hider)":
    @Event eachPlayer
    @Team 1
    @Hero dva
    @Condition CurrentGameState == GAME_STATE.HIDING
    
    eventPlayer.teleport(eventPlayer.DvaMechPosition)

rule "D.va: TP to Mech Position (Seeker)":
    @Event eachPlayer
    @Team 2
    @Hero dva
    @Condition CurrentGameState == GAME_STATE.HIDING
    @Condition not eventPlayer.isInSpawnRoom()
    
    eventPlayer.teleport(eventPlayer.DvaMechPosition)

rule "D.va: Ult":
    @Event eachPlayer
    @Hero dva

    eventPlayer.setUltEnabled(true)
    eventPlayer.disallowButton(Button.ULTIMATE)

rule "D.va: Enable De-mech":
    @Event eachPlayer
    @Hero dva
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

    if not eventPlayer.isInAlternateForm() and (WORKSHOP_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_DEMECH or WORKSHOP_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH):
        eventPlayer.setUltCharge(0)
        kill(eventPlayer, null)
        if WORKSHOP_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH:
            waitUntil(eventPlayer.isInAlternateForm(), 9999)
            eventPlayer.allowButton(Button.ULTIMATE)
            eventPlayer.setUltCharge(100)
    elif eventPlayer.isInAlternateForm() and WORKSHOP_SET_ADV_DVA_MECH == ACCESSIBILITY.DVA_MECH_ALLOW_BOTH:
        eventPlayer.allowButton(Button.ULTIMATE)
        eventPlayer.forceButtonPress(Button.ULTIMATE)
        waitUntil(not eventPlayer.isInAlternateForm(), 9999)
        eventPlayer.disallowButton(Button.ULTIMATE)

rule "Show Debug Stats":
    @Condition WORKSHOP_SET_ADV_DEBUGSTATS != SHOW_DEBUG_STATS.NONE

    hudText(hostPlayer if WORKSHOP_SET_ADV_DEBUGSTATS == SHOW_DEBUG_STATS.HOST else getAllPlayers(), "Debug Stats", "SERVER LOAD: {}\nSERVER LOAD AVERAGE: {}\nSERVER LOAD PEAK: {}\n".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()), "", HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!include "hider.opy"
#!include "seeker.opy"