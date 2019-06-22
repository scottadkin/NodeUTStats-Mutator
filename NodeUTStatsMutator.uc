//=============================================================================
// NodeUTStatsMutator.
//=============================================================================
class NodeUTStatsMutator expands Mutator;


var int CSP;

var (NodeUTStats) float SpawnKillTimeLimit;
var (NodeUTStats) float MultiKillTimeLimit;

struct nPlayer{
	var PlayerReplicationInfo p;
	var int spawns;
	var float lastSpawnTime;
	var int id;
	var int spawnKills;
	var int spawnKillSpree;
	var int bestSpawnKillSpree;
	var float lastKillTime;
	var int currentSpree;
	var int bestSpree;
	var int currentMulti;
	var int bestMulti;
};


var nPlayer nPlayers[64];


function int getPlayerIndex(PlayerReplicationInfo p){

	local int i;

	for(i = 0; i < 64; i++){

		if(nPlayers[i].id == p.PlayerID){
			return i;
		}
	}

	return -1;
}


function int insertNewPlayer(PlayerReplicationInfo p){
	
	local int i;
	
	
	for(i = 0; i < 64; i++){
		
	
		if(nPlayers[i].id == -1){
			nPlayers[i].p = p;
			nPlayers[i].id = p.PlayerID;
			//LOG("Inseted new player "$p.PlayerName);
			Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"Face"$Chr(9)$p.PlayerID$Chr(9)$p.TalkTexture);
			Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"Voice"$Chr(9)$p.PlayerID$Chr(9)$p.VoiceType);
			return i;
		}
	}
}


function updateSpawnInfo(int offset){
		
	nPlayers[offset].spawns++;
	nPlayers[offset].lastSpawnTime = Level.TimeSeconds;

	//LOG(nPlayers[offset].p.PlayerName$" has spawned at "$nPlayers[offset].lastSpawnTime$" Total spawns = "$nPlayers[offset].spawns);

}


function PostBeginPlay(){

	local int i;

	LOG("¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ NodeUTStats started ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬");
	

	for(i = 0; i < 64; i++){
	
		nPlayers[i].id = -1;
		nPlayers[i].lastSpawnTime = -1;


	}
}

function bool HandleEndGame(){


	local int i;

	for(i = 0; i < 64; i++){
		
		if(nPlayers[i].id == -1){
			break;
		}

		updateStats(i);
		updateSpecialEvents(i, true);
		Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"SpawnKills"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].spawnKills);
		Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"BestSpawnKillSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpawnKillSpree);
		Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"BestSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpree);
		Level.Game.LocalLog.LogEventString(Level.TimeSeconds$Chr(9)$"nstats"$Chr(9)$"BestMulti"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestMulti);
	}

	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}


function updateStats(int PlayerIndex){

	
	local int bestSpawnSpree;
	local int currentSpawnSpree;
	local int bestSpree;
	local int currentSpree;

	bestSpawnSpree = nPlayers[PlayerIndex].bestSpawnKillSpree;
	currentSpawnSpree = nPlayers[PlayerIndex].spawnKillSpree;
	bestSpree = nPlayers[PlayerIndex].bestSpree;
	currentSpree = nPlayers[PlayerIndex].currentSpree;


	if(currentSpawnSpree > bestSpawnSpree){

		nPlayers[PlayerIndex].bestSpawnKillSpree = currentSpawnSpree;

		Log(nPlayers[PlayerIndex].p.PlayerName$Chr(9)$" just got their best spawn kill spree ("$nPlayers[PlayerIndex].spawnKillSpree$") was ("$bestSpawnSpree$")");

		nPlayers[PlayerIndex].spawnKillSpree = 0;

	}

	if(currentSpree > bestSpree){
		LOG(nPlayers[PlayerIndex].p.PlayerName$" just beat their best killing spree "$currentSpree$" was ("$bestSpree$")");
		nPlayers[PlayerIndex].bestSpree = currentSpree;
	}
}


function UpdateSpecialEvents(int PlayerId, bool bKilled){

	local int bestMulti;
	local int currentMulti;
	local int bestSpree;
	local int currentSpree;
	local float lastKillTime;

	bestMulti = nPlayers[PlayerId].bestMulti;
	currentMulti = nPlayers[PlayerId].currentMulti;

	bestSpree = nPlayers[PlayerId].bestSpree;
	currentSpree = nPlayers[PlayerId].currentSpree;

	lastKillTime = nPlayers[PlayerId].lastKillTime;

	if(bKilled){
	
		nPlayers[PlayerId].currentMulti = 0;
		nPlayers[PlayerId].currentSpree = 0;

		if(currentSpree > bestSpree){
			nPlayers[PlayerId].bestSpree = currentSpree;
		}

		if(currentMulti > bestMulti){
			nPlayers[PlayerId].bestMulti = currentMulti;

		}

	}else{
	
		nPlayers[PlayerId].currentSpree++;

		if(Level.TimeSeconds - lastKillTime <= MultiKillTimeLimit){
			
			nPlayers[PlayerId].currentMulti++;

		}else{
			
			if(currentMulti > bestMulti){
				nPlayers[PlayerId].bestMulti = currentMulti;
			}

			nPlayers[PlayerId].currentMulti = 1;
		}

	}

}


function ScoreKill(Pawn Killer, Pawn Other){

	local int KillerId, OtherId;




	if(Killer.PlayerReplicationInfo != None){
		KillerId = getPlayerIndex(Killer.PlayerReplicationInfo);
		LOG(Killer.PlayerReplicationInfo.PlayerName$" has died");
	}

	if(Other.PlayerReplicationInfo != None){
		OtherId = getPlayerIndex(Other.PlayerReplicationInfo);
	}

	if(KillerId != -1){
		
		
		UpdateSpecialEvents(KillerId,false);

		nPlayers[KillerId].lastKillTime = Level.TimeSeconds;
		
		if(OtherId != -1){

			if(Level.TimeSeconds - nPlayers[OtherId].lastSpawnTime <= SpawnKillTimeLimit){
				//LOG("SPAWN KILLLLLL");
				nPlayers[KillerId].spawnKills++;
				nPlayers[KillerId].spawnKillSpree++;
				//nPlayers[KillerId].currentSpree++;
			}

			updateStats(OtherId);
			UpdateSpecialEvents(OtherId, true);

		}
	}


	if(OtherId != -1){
		//nPlayers[OtherId]
	}

	if(NextMutator != None){
		NextMutator.ScoreKill(Killer, Other);
	}

}

function ModifyPlayer(Pawn Other){

	local int currentPID;

	if(Other.PlayerReplicationInfo != None){
		
		
		currentPID = getPlayerIndex(Other.PlayerReplicationInfo);

		if(currentPID == -1){

			currentPID = InsertNewPlayer(Other.PlayerReplicationInfo);
			//catch players that have killed themselves
			//updateStats(currentPID);
			//updateSpecialEvents(currentPID, true);

		}	

		updateStats(currentPID);
		updateSpecialEvents(currentPID, true);
		updateSpawnInfo(currentPID);
	}

	if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}

defaultproperties
{
     SpawnKillTimeLimit=2.000000
     MultiKillTimeLimit=3.000000
}
