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

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

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
	//Initialize StartNode
	StartNode = Action.StartNode;
	//Initialize End Node
	EndNode = Action.EndNode;
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
			Alertness = 100;
			GoToState('Hostile', 'Begin');
			WorldInfo.Game.Broadcast(self, "HOSTILE MODE");
			return;
			//Hostile state will try to trigger the alarm and kill the player
		}
		else if(Distance <= SuspicionDistance)
		{
			//WorldInfo.Game.Broadcast(self, "SUSPICION MODE");
			//Increase the alertness
			Alertness += 10;
			`log("ALERTNESS INCREASED TO "$Alertness);
			return;
		}
		else
		{
			//Player is too far to be seen by the bot.
			//Reset the alertness back to zero
			Alertness = 0;
			`log("ALERTNESS BACK TO ZERO");
			Target = none;
			Seen = none;
			return;
		}
	}
	
	return;
}

event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	`log("I HEAR A NOISE "$Loudness);
	super.HearNoise(Loudness, NoiseMaker, NoiseType);

	//Bot will walk towards the NoiseMaker if the loudness is greater or equal to 1
	//And the sound is made inside his SuspicionDistance
	if(Loudness >= 1.0 && VSize(NoiseMaker.Location - Pawn.Location) <= SuspicionDistance)
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
		if (PreviousStateName != 'None')
		{
			Pawn.TriggerEventClass(class'SeqEvent_StateChange', Pawn);
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
	Goto('Begin');
}

state Hostile
{
	ignores SeePlayer;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN STATE HOSTILE FROM "$PreviousStateName);
		Pawn.TriggerEventClass(class'SeqEvent_StateChange', Pawn);
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
		//Pawn.TriggerEventClass(class'SeqEvent_TriggerAlarm', Pawn);
	}

	Sleep(5);
	GoTo('Begin');
}

state Attack
{
	ignores SeePlayer;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN STATE ATTACK FROM "$PreviousStateName);
		Pawn.TriggerEventClass(class'SeqEvent_StateChange', Pawn);
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

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN CHASEPLAYER STATE FROM "$PreviousStateName);
		Pawn.TriggerEventClass(class'SeqEvent_StateChange', Pawn);
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
		`log("TIMER RUNS OUT. BACK TO PATHFINDING");
		GotoState('PathFinding');
	}

Begin:
	//Enemy position will be updated from SeePlayer function.
	//SeePlayer function will update Target variable, which will be used in ChasingPlayer function

	if(ChaseTimer <= 0)
	{
		//Bot running out of ChaseTimer, so Chase activity will be ceased and back to Pathfinding state
		//Reset ChaseTimer back to default
		ChaseTimer = Default.ChaseTimer;
		//Reset the Bot's alertness to zero
		Alertness = 0;
		`log("CHASE TIMER OUT");
		//Reset Bot's state to pathfinding
		GotoState('PathFinding');
	}
	else if(Target != none && ActorReachable(Target))
	{
		
		if(VSize(Target.Location - Pawn.Location) < MaxFireDistance)
		{
			//The Target is insdie bot's fire range.
			`log("START FIRING AT TARGET AFTER CHASING");
			//Reset ChaseTimer back to default
			ChaseTimer = Default.ChaseTimer;
			//Start Firing the Player again
			GotoState('Attack');
		}
		else
		{
			//Subtract ChaseTimer so bot will stop chasing the player
			ChaseTimer -= 1;
			`log("MOVING TOWARD THE PLAYER DIRECTLY CHASETIMER IS "$ChaseTimer);
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
			//Reduce ChaseTimer so bot would stop chasing the player after a while
			ChaseTimer -= 1;
			`log("MOVING TO TEMPORARY DESTINATION BECAUSE PLAYER IS NOT DIRECTLY REACHABLE "$TempDest);
			//Move to the temporary destination
			MoveToward(TempDest, TempDest, 50);
		}
		else
		{
			//Actor is not reachable or target disappears
			`log("TARGET DISAPPEARS "$Target);
			//Reset the ChaseTimer for future combat
			ChaseTimer = Default.ChaseTimer;
			//Resets the alertness back to zero
			Alertness = 0;
			//Return to pathfinding state
			GotoState('PathFinding');
		}
	}

	//Sleep(0.5);
	Goto('Begin');
}

state Suspicion
{
	ignores SeePlayer;

	function BeginState(Name PreviousStateName)
	{
		`log("BOT IS NOW IN SUSPICION STATE FROM "$PreviousStateName);
		Alertness = 50;
	}

Begin:

	MoveToward(TempDest, TempDest, 50,,true);
	Sleep(5);
	GotoState('PathFinding');
}

DefaultProperties
{
	bIsPlayer = true
	SuspicionDistance = 800
	HostileDistance = 400
	MaxFireDistance = 800
	Alertness=0
	ChaseTimer=3
	//bStatic = false

	//To see in kismet (Selected Actor, add event using actor)
	//SupportedEvents.Add(class'SeqEvent_TriggerAlarm')
	//SupportedEvents.Add(class'SeqEvent_BotStartShooting')
	//SupportedEvents.Add(class'SeqEvent_StateChange')
}
