class Pr0Bot extends UDKBot;

//AI Patrol Starting Node
var(Patrol) Actor StartNode;
//AI Patrol Ending Node
var(Patrol) Actor EndNode;
//AI Temporary Destination (For General Pathfinding purposes)
var(Patrol) Actor TempDest;

//The distance which bot will become suspicious
var(Behavior) float SuspicionDistance;
//The distance which bot will become hostile
var(Behavior) float HostileDistance;
//The Alertness of bot. Range is 0-100
var(Behavior) int Alertness;
//The closest Alarm to a bot.
var(Behavior) Actor ClosestAlarm;

//Enemy pawn, when spotted by bot
var(Combat) Actor Target;
//Bot's maximum fire distance
var(Combat) float MaxFireDistance;
//Bot's chase Timer (seconds)
var(Combat) float ChaseTimer;

//Reference to HUDMovie in GFxHUD
var(HUD) GFxHUD HUDMovie;
//Current Alertness stage. HUD only updated if alertness stage is different
var(HUD) int CurrentAlertnessFrame;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	//Initialize reference to the player's HUD so it so bot can give alertness to player
	HUDMovie = PR0HUDGfx(WorldInfo.GetALocalPlayerController().myHUD).HudMovie;

	//Initiate the state
	GotoState('PathFinding');
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}

function PR0ConfigureBot(SeqAct_PR0ConfigureBot Action)
{
	if(Action == none)
	{
		StartNode = none;
		EndNode = none;
		return;
	}
	//Initialize StartNode
	StartNode = Action.StartNode;
	//Initialize End Node
	EndNode = Action.EndNode;
}

function AlertBotWhenHit(Actor DamageCauser)
{
	if(Alertness > 0)
	{
		//Bot is already alerted, no need to alert the bot
		return;
	}
	else
	{
		TempDest = DamageCauser;
		GotoState('Suspicion');
	}
}

event SeePlayer(Pawn Seen)
{
	//Actor that catches the Bot's view. (Not necessarily the Player, e.g. if the player is behind wall)
	local Actor HitActor;
	//The Location of the actor
	local Vector HitLocation;
	//
	local Vector HitNormal;
	//Distance from the bot to the player
	local float Distance;

	//Call the controller's SeePlayer function
	super.SeePlayer(Seen);

	Distance = VSize(Pawn.Location - Seen.Location);
	//Trace a line and see what it collides first
	HitActor = Trace(HitLocation, HitNormal,Pawn.Location, Seen.Location, false);

	if(HitActor != none)
	{
		//Player is behind a wall, and Bot is not supposed to see him
		Seen = none;
		//TODO: If bot sees player entering the wall, bot should be able to follow
		return;
	}
	else
	{
		//Set the Move Target to Seen player
		Target = Seen;
		
		//Return to prevent state change when chasingplayer, so the bot keep chasing the player
		if(IsInState('ChasePlayer'))
		{
			return;
		}
		//Player is seen by the bot, or alertness reached 100
		else if(Distance <= HostileDistance || Alertness == 100)
		{
			GoToState('Hostile', 'Begin');
			return;
			//Hostile state will try to trigger the alarm and kill the player
		}
		else if(Alertness == 25)
		{
			TempDest = Target;
			GotoState('Suspicion');
			return;
		}
		else if(Distance <= SuspicionDistance)
		{
			//Increase the alertness
			UpdateAlertness(Alertness+5);
			return;
		}
		else
		{
			//Player is too far to be seen by the bot.
			//Reset the alertness back to zero
			//TODO: BUGGY WITH 2 BOTS
			if(Alertness != 0)
			{
				`log(WorldInfo.GetALocalPlayerController().Pawn);
				`log("CALLED BY "$self$" DISTANCE IS "$Distance$" SEEN IS "$Seen);
				UpdateAlertness(0);
			}
			Target = none;
			Seen = none;
			return;
		}
	}
	
	return;
}

/**
 * Called when Bot's alertness is changed to update the player's alertness HUD
 */
function UpdateAlertness(int NewAlertness)
{
	//The new frame resulting from the increase/decrease of alertness
	local int NewAlertnessFrame;
	`log("UPDATE ALERTNESS OF "$self$" TO "$NewAlertness);
	//Determine the new frame and check if the eye HUD needs to be opened more
	NewAlertnessFrame = FCeil(float(NewAlertness)/25.0f);
	
	//TODO: Update alertness should always show the highest alertness of all bots
	if(NewAlertnessFrame != CurrentAlertnessFrame)
	{
		CurrentAlertnessFrame = NewAlertnessFrame;
		HUDMovie.gotoFrame(NewAlertnessFrame);
	}

	//Update bot's alertness	
	Alertness = NewAlertness;
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	`log("I HEAR A NOISE "$Loudness);
	super.HearNoise(Loudness, NoiseMaker, NoiseType);

	//Bot will walk towards the NoiseMaker if the loudness is greater or equal to 1
	//And the sound is0 made inside his SuspicionDistance
	if(Loudness >= 1. && VSize(NoiseMaker.Location - Pawn.Location) <= SuspicionDistance)
	{ 
		`log("MOVING TOWARDS "$NoiseMaker);
		TempDest = NoiseMaker;
		GotoState('Suspicion');
	}
}

function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
	//Reference to the playerpawn
	local Pawn PlayerPawn;

	if(Pawn != none)
	{
		PlayerPawn = WorldInfo.GetALocalPlayerController().Pawn;
		return Rotator(Normal(PlayerPawn.Location - Pawn.Location));
	}
	else
	{
		return Rotation;
	}
}

//The Pathfinding state has a prefix Auto to denote that this is the default state the bot will start in
auto state PathFinding
{
	simulated function PathFind(out Actor _TempDest, Actor Destination)
	{
		_TempDest = FindPathToward(Destination,,1000,true);
	}

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN STATE PATHFINDING FROM "$PreviousStateName);
		if(Alertness != 0)
		{
			UpdateAlertness(0);
		}
	}

Begin:
	 //Move to pathnode if one exists
	if(StartNode != none && EndNode != none)
	{
		MoveToward(StartNode, StartNode, 50);
		Sleep(5);
		MoveToward(EndNode, EndNode, 50);
		Sleep(5);
	}
	else
	{
		GotoState('Idle');
	}
	Goto('Begin');
}

state Hostile
{
	ignores SeePlayer, HearNoise;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN STATE HOSTILE FROM "$PreviousStateName);
		UpdateAlertness(100);
	}

	function FindClosestAlarm()
	{
		//Reference to a single alarm in the world
		local Trigger Alarm;
		//Distance to the bot
		local float _Distance;
		//Closest distance to bot
		local float ClosestDistance;

		ClosestDistance = 1000000;

		foreach AllActors(class'Trigger', Alarm)
		{
			//distance between an alarm and the bot
			_Distance = VSize(Alarm.Location - Pawn.Location);
			if(_Distance < ClosestDistance)
			{
				ClosestAlarm = Alarm;
				ClosestDistance = _Distance;
			}
		}

		if(ClosestDistance > 2000)
		{
			ClosestAlarm = none;
		}
	}

Begin:

	//Randomize A.I. Behavior.
	//Or we should check how far is the nearest alarm
	//Or check wheter alarm is in certain distance from bot
	//if(Bool(Rand(2)))
	if(true)
	{
		TempDest = Target;
		GotoState('Attack');
	}
	else
	{
		FindClosestAlarm();
		if(ClosestAlarm != none)
		{
			`log("MOVING TOWARD "$ClosestAlarm);
			MoveToward(ClosestAlarm, ClosestAlarm);
		}
		else
		{
			//No alarm is found, bot should attack the player
			TempDest = Target;
			GotoState('Attack');
		}
	}

	Sleep(5);
	GoTo('Begin');
}

state Attack
{
	ignores SeePlayer, HearNoise;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN STATE ATTACK FROM "$PreviousStateName);
	}

	function AttackPlayer()
	{
		//Distance between Enemy and Bot
		local float EnemyDistance;
		//The Player's pawn
		local Pawn PlayerPawn;

		//Stop bot's movement
		Pawn.Acceleration=Vect(0,0,0);
		
		PlayerPawn = WorldInfo.GetALocalPlayerController().Pawn;

		EnemyDistance = VSize(Pawn.Location - PlayerPawn.Location);

		if(EnemyDistance <= MaxFireDistance)
		{
			if(CanSee(PlayerPawn))
			{
				//Pawn.SetDesiredRotation(Rotator(Normal(PlayerPawn.Location)));
				SetFocalPoint(PlayerPawn.Location);
				Focus = PlayerPawn;
				Pawn.StartFire(0);
			}
			else
			{
				//StopFiring();
				Pawn.StopFire(0);
				Focus = none;
				GotoState('ChasePlayer');
			}
		}
		else
		{
			//Try to approach player before attacking
			Pawn.StopFire(0);
			Focus = none;
			GotoState('ChasePlayer');
		}

		return;
	}

Begin:

	AttackPlayer();
	Sleep(0.5);
	Goto('Begin');
}

state ChasePlayer
{
	ignores HearNoise;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN CHASEPLAYER STATE FROM "$PreviousStateName);
		SetTimer(ChaseTimer, false, 'AbortChase');
	}

	function FindChasePath(out Actor Destination)
	{
		//Find Path to the target
		`log("FINDING PATH TO "$Target);
		Destination = FindPathToward(Target,,1000,true);
	}

	function AbortChase()
	{
		//ChaseTimer has been depleted and bot goes back to pathfinding
		WorldInfo.Game.Broadcast(self,"TIMER RUNS OUT. BACK TO PATHFINDING");
		UpdateAlertness(0);
		GotoState('PathFinding');
	}

Begin:
	//Enemy position will be updated from SeePlayer function.
	//SeePlayer function will update Target variable, which will be used in ChasingPlayer function

	if(Target != none && ActorReachable(Target))
	{
		
		if(VSize(Target.Location - Pawn.Location) < MaxFireDistance)
		{
			//The Target is insdie bot's fire range.
			Worldinfo.Game.Broadcast(self, "START FIRING AT TARGET AFTER CHASING");
			SetTimer(0);
			//Start Firing the Player again
			GotoState('Attack');
		}
		else
		{
			//Subtract ChaseTimer so bot will stop chasing the player
			WorldInfo.Game.Broadcast(self, "MOVING TOWARD THE PLAYER DIRECTLY CHASETIMER IS "$ChaseTimer);
			//MoveToward the player directly
			MoveToward(Target, Target, 50);
		}
	}
	else //Target is not reachable directly, pathfinding is required
	{
		if(Target != none)
		{
			//Find a new path
			FindChasePath(TempDest);
			if(TempDest == none)
			{
				WorldInfo.Game.Broadcast(self, "TARGET UNREACHABLE");
				AbortChase();
			}
			//Reduce ChaseTimer so bot would stop chasing the player after a 
			WorldInfo.Game.Broadcast(self, "MOVING TO TEMPORARY DESTINATION BECAUSE PLAYER IS NOT DIRECTLY REACHABLE "$TempDest);
			//Move to the temporary destination
			MoveToward(TempDest, TempDest, 50);
		}
		else
		{
			//Actor is not reachable or target disappears
			`log("TARGET DISAPPEARS "$Target);
			SetTimer(0);
			//Resets the alertness back to zero
			UpdateAlertness(0);
			//Return to pathfinding state
			GotoState('PathFinding');
		}
	}

	Sleep(0.1);
	Goto('Begin');
}

state Suspicion
{
	ignores SeePlayer;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN SUSPICION STATE FROM "$PreviousStateName$" TEMPDEST IS "$TempDest);
		UpdateAlertness(20);
	}

	function bool Suspicious()
	{
		local float Distance;

		Distance = VSize(TempDest.Location - Pawn.Location);

		if(Distance <= SuspicionDistance && Distance > HostileDistance)
		{
			WorldInfo.Game.Broadcast(self, "TRUE DISTANCE "$Distance$" Alertness "$Alertness);
			//Increase the alertness if player is still inside the bot's field of vision
			UpdateAlertness(Alertness+5);
			return true;
		}
		else if(Distance <= HostileDistance)
		{
			//Player inside the bot's hostile distance, engage attack mode
			WorldInfo.Game.Broadcast(self, "FALSE DISTANCE "$Distance$" Alertness "$Alertness);
			GotoState('Hostile');
			return false;
		}
		else
		{
			//Else player is away and alertness will decrease
			WorldInfo.Game.Broadcast(self, "TOO FAR "$Distance);
			UpdateAlertness(Alertness - 5);
			return false;
		}
		
	}

Begin:
	
	//If target is still not in hostile distance, walk towards it for 100 units
	if(Suspicious() == true)
	{
		MoveToward(TempDest, TempDest, VSize(TempDest.Location - Pawn.Location) - 100,,true);
	}
	//Stays in the same place and do nothing
	else
	{
		`log("NOT SUSPICIOUS AT ALL");
	}

	if(Alertness <= 0)
	{
		GotoState('Pathfinding');
	}
	else if(Alertness >= 100)
	{
		GotoState('Hostile');
	}

	Sleep(1);
	Goto('Begin');
}

DefaultProperties
{
	//TODO: bIsPlayer is set to false to counteract SeePlayer function seeing other AI instead of the player
	//      should there be a problem it should be changed back to true, and update SeePlayer function to accept Player controlled pawn only
	bIsPlayer = false
	SuspicionDistance = 800
	HostileDistance = 400
	MaxFireDistance = 600
	ChaseTimer = 5
	CurrentAlertnessFrame = 0

	StartNode = none
	EndNode = none

	//To see in kismet (Selected Actor, add event using actor)
	//SupportedEvents.Add(class'SeqEvent_TriggerAlarm')
	//SupportedEvents.Add(class'SeqEvent_BotStartShooting')
	//SupportedEvents.Add(class'SeqEvent_StateChange')
}
