#!mainFile "settings.opy"

enum GAME_STATE:
    WAITING = "Waiting For Players",
    HIDING = "Hiding",
    SEEKING = "Seeking",
    RESULTS = "Results",
    END = "End Game"

globalvar CurrentGameState = GAME_STATE.WAITING
globalvar CurrentTime = 1800
globalvar CurrentRound = 0
globalvar HiderTeamScore = 0
globalvar SeekerTeamScore = 0
globalvar LastHiderHud
playervar ShowHiders = false
playervar JoinedLate

#!define HidersExist (len([player for player in getPlayers(Team.1) if player.hasSpawned() and player.isAlive() and not player.isInSpawnRoom() and not player.JoinedLate]) > 0)

subroutine PLAYSOUND_DEBUFF
subroutine PLAYSOUND_RINGEXPLOSION
subroutine PLAYSOUND_BUFF
globalvar playerIndex
def PLAYSOUND_RINGEXPLOSION():
    for playerIndex in range(0, len(getAllPlayers())):
        playEffect(getAllPlayers()[playerIndex], DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, getAllPlayers()[playerIndex], 100)
def PLAYSOUND_DEBUFF():
    for playerIndex in range(0, len(getAllPlayers())):
        playEffect(getAllPlayers()[playerIndex], DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, getAllPlayers()[playerIndex], 100)
def PLAYSOUND_BUFF():
    for playerIndex in range(0, len(getAllPlayers())):
        playEffect(getAllPlayers()[playerIndex], DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getAllPlayers()[playerIndex], 100)

rule "Stop Skirmish Clock / Scoring":
    pauseMatchTime()
    disableScoring()

rule "Waiting Phase":
    @Condition CurrentGameState == GAME_STATE.WAITING
    @Condition len([player for player in getPlayers(Team.1) if player.hasSpawned() and not player.isInSpawnRoom()]) > 0 and len([player for player in getPlayers(Team.2) if player.hasSpawned() and not player.isInSpawnRoom()]) > 0

    printLog("Game Phase: Waiting")

    #!define RequiredHiders WS_SET_REQUIRED_HIDERS * getNumberOfLivingPlayers(Team.2)

    # Wait until everyone spawns in
    waitUntil(all([player.hasSpawned() for player in getAllPlayers()]), WS_SET_WAITING_MAXTIME)

    # Wait until player count meets the required ratio of seekers to hiders
    waitUntil(len([player for player in getPlayers(Team.1) if player.hasSpawned() and not player.isDummy()]) >= RequiredHiders and len([player for player in getPlayers(Team.2) if player.hasSpawned()]) > 0, WS_SET_WAITING_MAXTIME)

    CurrentGameState = GAME_STATE.HIDING

rule "Hiding Phase":
    @Condition CurrentGameState == GAME_STATE.HIDING

    printLog("Game Phase: Hiding")
    PLAYSOUND_RINGEXPLOSION()
    [player for player in getPlayers(Team.ALL).exclude(getPlayersOnHero(Hero.DVA, Team.ALL)) if player.hasSpawned() and not player.isInSpawnRoom()].respawn()

    CurrentRound += 1 
    bigMessage(getAllPlayers() if WS_SET_ADV_WINS > 1 else null, "Round {}".format(CurrentRound)) 
    CurrentTime = WS_SET_HIDETIME
    chase(CurrentTime, 0, rate = 1, ChaseReeval.DESTINATION_AND_RATE)

    waitUntil(CurrentTime == 0, 9999)

    stopChasingVariable(CurrentTime)

    CurrentGameState = GAME_STATE.SEEKING

rule "Seeking Phase":
    @Condition CurrentGameState == GAME_STATE.SEEKING

    printLog("Game Phase: Seeking")
    PLAYSOUND_RINGEXPLOSION()
    
    CurrentTime = WS_SET_SEEKTIME
    chase(CurrentTime, 0, rate = 1, ChaseReeval.DESTINATION_AND_RATE)

    waitUntil(CurrentTime == 0 or not HidersExist, 9999)

    stopChasingVariable(CurrentTime)

    CurrentGameState = GAME_STATE.RESULTS

rule "Results":
    @Condition CurrentGameState == GAME_STATE.RESULTS

    printLog("Game Phase: Results")

    PLAYSOUND_BUFF()

    # Add score to winning team
    if HidersExist:
        HiderTeamScore += 1
        bigMessage(getAllPlayers() if WS_SET_ADV_WINS > 1 else null, "Hiders Win!")
    else:
        SeekerTeamScore += 1
        bigMessage(getAllPlayers() if WS_SET_ADV_WINS > 1 else null, "Seekers Win!")
    
    # Show hiders if workshop setting is enabled
    if (WS_SET_SHOW_HIDERS == SHOW_HIDERS.ALL_HIDERS and len(getLivingPlayers(Team.1)) >= 1) or (WS_SET_SHOW_HIDERS == SHOW_HIDERS.LAST_HIDER and len(getLivingPlayers(Team.1)) == 1):
        smallMessage(getAllPlayers(), "Revealing the remaining hiders")
        getPlayers(Team.ALL).ShowHiders = true
        waitUntil(all([player.ShowHiders == false for player in getAllPlayers()]), 9999)
    
    # If team score reaches required wins, then declare victory. Otherwise, start another round
    if HiderTeamScore >= WS_SET_ADV_WINS:
        declareTeamVictory(Team.1)
        CurrentGameState = GAME_STATE.END
    elif SeekerTeamScore >= WS_SET_ADV_WINS:
        declareTeamVictory(Team.2)
        CurrentGameState = GAME_STATE.END
    else:
        setSlowMotion(25)
        wait(1)
        CurrentGameState = GAME_STATE.HIDING
        setSlowMotion(100)

rule "Countdown":
    @Condition CurrentTime < 10
    @Condition CurrentTime > 0

    PLAYSOUND_DEBUFF()

    wait(1)

    if RULE_CONDITION:
        goto RULE_START

rule "End Game":
    @Condition CurrentGameState == GAME_STATE.END

    printLog("Game Phase: End")

    wait(WS_SET_END)

    setMatchTime(0)
    unpauseMatchTime()

rule "Add Bots":
    @Condition hostPlayer.isCommunicating(Comms.READY)
    @Disabled

    createDummy(Hero.TRACER, Team.1, 0, random.choice(getSpawnPoints(Team.1)), null)
    createDummy(Hero.TRACER, Team.1, 1, random.choice(getSpawnPoints(Team.1)), null)
    createDummy(Hero.TRACER, Team.1, 2, random.choice(getSpawnPoints(Team.1)), null)
    createDummy(Hero.TRACER, Team.1, 3, random.choice(getSpawnPoints(Team.1)), null)
    createDummy(Hero.TRACER, Team.1, 4, random.choice(getSpawnPoints(Team.1)), null)
    createDummy(Hero.TRACER, Team.1, 5, random.choice(getSpawnPoints(Team.1)), null)

    createDummy(Hero.TRACER, Team.2, 0, random.choice(getSpawnPoints(Team.2)), null)
    createDummy(Hero.TRACER, Team.2, 1, random.choice(getSpawnPoints(Team.2)), null)
    createDummy(Hero.TRACER, Team.2, 2, random.choice(getSpawnPoints(Team.2)), null)

