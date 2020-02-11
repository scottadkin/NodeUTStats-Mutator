class NodeUTStatsMutator expands Mutator;

var int CSP;

var (NodeUTStats) float SpawnKillTimeLimit;
var (NodeUTStats) float MultiKillTimeLimit;
var (NodeUTStats) bool bIgnoreMonsters;
var (NodeUTStats) string faces[39];

struct nPlayer{
	var PlayerReplicationInfo p;
	var Pawn pawn;
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
	var int damageDone;
	var int damageTaken;
	var int netSpeed;
	var float mouseSens;
	var float dodgeClickTime;
	var int fov;
	var int settingChecks;
	var int monsterKills;
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


/*function getMouseSens(PlayerPawn p){

	Log(p.MouseSensitivity);
}*/

function string getRandomFace(){
	
	local string currentFace;
	local int currentIndex;

	currentIndex = Rand(38);

	return faces[currentIndex];
	
}

function int insertNewPlayer(Pawn p){
	
	local int i;
	//local StatLog log;
	local int id;
	local PlayerPawn potato;


	
//	log = Level.Game.LocalLog;
	
	for(i = 0; i < 64; i++){
		
	
		if(nPlayers[i].id == -1){

			nPlayers[i].p = p.PlayerReplicationInfo;
			nPlayers[i].id = p.PlayerReplicationInfo.PlayerID;
			nPlayers[i].settingChecks = 0;
			nPlayers[i].netspeed = 0;
			nPlayers[i].mouseSens = 0;
			nPlayers[i].fov = 0;
			//nPlayers[i].pawn = p;

			//id = p.PlayerReplicationInfo.PlayerID;
			
			//LOG("Inseted new player "$p.PlayerName);

			if(nPlayers[i].p.TalkTexture != None){
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"Face"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$nPlayers[i].p.TalkTexture);
			}else{
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"Face"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$getRandomFace());
			}

			if(nPlayers[i].p.VoiceType != None){
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"Voice"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$nPlayers[i].p.VoiceType);
			}

			/*if(p.isA('PlayerPawn')){
				//Log(p.MouseSensitivity);

				getMouseSens(PlayerPawn(p));

			}*/

			if(PlayerPawn(p) != None){

				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"NetSpeed"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).Player.CurrentNetSpeed);
				//Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"MouseSens"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).MouseSensitivity);
				//Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"DodgeClickTime"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).DodgeClickTime);
				//Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"Fov"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).FovAngle);

			}
			
		
			return i;
		}
	}

	return -1;
}


function updateSpawnInfo(int offset){
		
	nPlayers[offset].spawns++;
	nPlayers[offset].lastSpawnTime = Level.TimeSeconds;

	//LOG(nPlayers[offset].p.PlayerName$" has spawned at "$nPlayers[offset].lastSpawnTime$" Total spawns = "$nPlayers[offset].spawns);

}


function PostBeginPlay(){

	local int i;

	LOG("��������������� NodeUTStats started ���������������");

	//LOG(Level.Game.gamename);
	//LOG(Caps(Level.Game.gamename));
	//Level.Game.Spawn( class'NodeUTStatsSpawnNotify');
	

	for(i = 0; i < 64; i++){
	
		nPlayers[i].id = -1;
		nPlayers[i].lastSpawnTime = -1;


	}
}


function bool bMonsterHuntGame(){

	
	local string find;

	local string gt;
	local int searchResult;


	gt = Caps(Level.Game.gamename);
	//Log("gametype = "$ gt);
	//gt = Caps(gt);
	//Log("gametype.Caps = "$ gt);

	find = Caps("Monster Hunt");
	

	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	find = Caps("MonsterHunt");
	
	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	find = Caps("Coop Game");

	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	

	return false;
}

function bool HandleEndGame(){


	local int i;

	
	if(!bMonsterHuntGame()){

		for(i = 0; i < 64; i++){
		
			if(nPlayers[i].id == -1){
				continue;
			}

			updateStats(i);
			updateSpecialEvents(i, true);

			Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"SpawnKills"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].spawnKills);
			Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"BestSpawnKillSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpawnKillSpree);
			Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"BestSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpree);
			Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"BestMulti"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestMulti);
			//Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"MonsterKills"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].monsterKills);
		}

	}else{
		
		Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"Monster hunt game finished");
	}

	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}

/*function checkPlayerSettings(Pawn Other){

	local int playerIndex;

	if(PlayerPawn(Other) != None){

		if(Other.PlayerReplicationInfo != None){

			playerIndex = getPlayerIndex(Other.PlayerReplicationInfo);

			if(playerIndex != -1){
			
				if(nPlayers[playerIndex].netspeed != PlayerPawn(Other).Player.CurrentNetSpeed){
					LOG("NETSPEED change for "$Other.PlayerReplicationInfo.playerName$" Changed to "$PlayerPawn(Other).Player.CurrentNetSpeed);
					nPlayers[playerIndex].netspeed = PlayerPawn(Other).Player.CurrentNetSpeed;
				}
				
				if(nPlayers[playerIndex].mouseSens != PlayerPawn(Other).MouseSensitivity){
					LOG("Mouse sens change for " $ Other.PlayerReplicationInfo.playerName $ " Changed to " $ PlayerPawn(Other).MouseSensitivity);
				}

				if(nPlayers[playerIndex].fov != PlayerPawn(Other).FovAngle){
					LOG("Fov change for " $ Other.PlayerReplicationInfo.playerName $ " Changed to " $ PlayerPawn(Other).FovAngle);
				}


				if(nPlayers[playerIndex].dodgeClickTime != PlayerPawn(Other).DodgeClickTime){
					LOG("Dodge click time change for " $ Other.PlayerReplicationInfo.playerName $ " Changed to " $ PlayerPawn(Other).DodgeClickTime);
				}

				/*Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"NetSpeed"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).Player.CurrentNetSpeed);
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"MouseSens"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).MouseSensitivity);
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"DodgeClickTime"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).DodgeClickTime);
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"Fov"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).FovAngle);*/
			}
		
		}
	}
}*/


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


	}

	nPlayers[PlayerIndex].spawnKillSpree = 0;

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


function LogKillDistance(Pawn Killer, Pawn Other){

	local float distance;
	
	local int killerId;
	local int otherId;

	if(Killer.PlayerReplicationInfo != None && Other.PlayerReplicationInfo != None){

		killerId = Killer.PlayerReplicationInfo.PlayerID;
		otherId = Other.PlayerReplicationInfo.PlayerID;

		distance = VSize(Killer.Location - Other.Location);

		Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats" $Chr(9)$ "kill_distance" $Chr(9)$ distance $Chr(9)$ killerId $Chr(9)$ otherId);
	}
}


function ScoreKill(Pawn Killer, Pawn Other){

	local int KillerId, OtherId;


	//LOG(Other.Class);
	
	
	if(Killer != None){

		if(Killer.PlayerReplicationInfo != None){

			//checkPlayerSettings(Killer);

			KillerId = getPlayerIndex(Killer.PlayerReplicationInfo);

			LogKillDistance(Killer, Other);

			
			//check if victim is a monster
			if(!Other.IsA('PlayerPawn') && !Other.IsA('HumanBotPlus')){
				Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp()$Chr(9)$"nstats"$Chr(9)$"MonsterKill"$Chr(9)$Killer.PlayerReplicationInfo.PlayerID$Chr(9)$Other.Class);
			}

		}else{
			KillerId = -1;
		}
	}

	if(Other != None){
		if(Other.PlayerReplicationInfo != None){
			//checkPlayerSettings(Other);
			OtherId = getPlayerIndex(Other.PlayerReplicationInfo);
			//LOG(Other.PlayerReplicationInfo);
		}else{
			OtherId = -1;
		}
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

	local NodeUTStatsPlayerReplicationInfo test;

	if(Other.PlayerReplicationInfo != None && Other.bIsPlayer){
		
		
		currentPID = getPlayerIndex(Other.PlayerReplicationInfo);



		if(currentPID == -1){

			currentPID = InsertNewPlayer(Other);

		}	

		
		if(currentPID != -1){
			updateStats(currentPID);
			updateSpecialEvents(currentPID, true);
			updateSpawnInfo(currentPID);
		}
	}

	if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}

defaultproperties
{
     SpawnKillTimeLimit=2.000000
     MultiKillTimeLimit=3.000000
     Faces(0)="soldierskins.hkil5vector"
     Faces(1)="soldierskins.blkt5malcom"
     Faces(2)="commandoskins.goth5grail"
     Faces(3)="soldierskins.sldr5johnson"
     Faces(4)="fcommandoskins.daco5jayce"
     Faces(5)="fcommandoskins.goth5visse"
     Faces(6)="commandoskins.daco5graves"
     Faces(7)="sgirlskins.venm5sarena"
     Faces(8)="soldierskins.raws5kregore"
     Faces(9)="sgirlskins.army5sara"
     Faces(10)="sgirlskins.garf5vixen"
     Faces(11)="commandoskins.daco5boris"
     Faces(12)="commandoskins.daco5luthor"
     Faces(13)="commandoskins.cmdo5blake"
     Faces(14)="commandoskins.daco5ramirez"
     Faces(15)="fcommandoskins.daco5kyla"
     Faces(16)="soldierskins.sldr5brock"
     Faces(17)="commandoskins.goth5kragoth"
     Faces(18)="sgirlskins.venm5cilia"
     Faces(19)="fcommandoskins.goth5freylis"
     Faces(20)="sgirlskins.garf5isis"
     Faces(21)="fcommandoskins.daco5tanya"
     Faces(22)="sgirlskins.army5lauren"
     Faces(23)="soldierskins.blkt5riker"
     Faces(24)="soldierskins.sldr5rankin"
     Faces(25)="soldierskins.blkt5othello"
     Faces(26)="fcommandoskins.goth5cryss"
     Faces(27)="fcommandoskins.daco5mariana"
     Faces(28)="soldierskins.raws5arkon"
     Faces(29)="commandoskins.cmdo5gorn"
     Faces(30)="fcommandoskins.goth5malise"
     Faces(31)="sgirlskins.fbth5annaka"
     Faces(32)="tcowmeshskins.warcowface"
     Faces(33)="bossskins.boss5xan"
     Faces(34)="sgirlskins.fwar5cathode"
     Faces(35)="soldierskins.hkil5matrix"
     Faces(36)="tskmskins.meks5disconnect"
     Faces(37)="fcommandoskins.aphe5indina"
     Faces(38)="soldierskins.hkil5tensor"
}
