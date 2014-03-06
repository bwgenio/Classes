class PR0PlayerController extends UTPlayerController;

var Pawn OldPawn;
var bool possessed, Flying;
//The range of possession
var(Ability) float PossessionRange;
//The rate which light grow
var(Ability) int LightGrowRate;
//The rate which light dim
var(Ability) int LightDimRate;
//The maximum range of souluminescence
var(Ability) int MaxLightRange;
//The minimum range of souluminescence
var(Ability) int MinLightRange;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

//Updated the HealthBar Upon Death
simulated event Destroyed()
{
	super.Destroyed();
}

function ModifyLightIntensity()
{
	local PointLightComponent HeroLight;

	foreach Pawn.Mesh.AttachedComponents(class'PointLightComponent', HeroLight)
	{
		//Brighten the light when jumping
		if(Flying == TRUE)
		{
			HeroLight.Radius = Min(HeroLight.Radius + LightGrowRate, MaxLightRange);
		}
		//Dim the light when descending
		else
		{
			HeroLight.Radius = Max(HeroLight.Radius - LightDimRate, MinLightRange);
		}
	}
}

function bool IsCursorOnEnemy()
{
	//Pawn's location. The start of the trace
	local Vector out_Location;
	//Pawn's rotation (which way the cursor is facing)
	local Rotator out_Rotation;
	//The location of the cursor. The end of the trace
	local Vector CursorLocation;
	//The actor which is hit by possession
	local Actor HitActor;
	//Location where the trace hits an actor
	local Vector HitLocation;
	//The normal where the trace hits an actor
	local Vector HitNormal;

	//Get the pawn's viewpoint (not based on camera)
	Pawn.GetActorEyesViewPoint(out_Location, out_Rotation);

	//The cursor's vector is stored in the HUD
	CursorLocation = PR0HUDGfx(myHUD).WorldCursorOrigin;

	//Force the Y-position to be zero
	CursorLocation.Y = 0;
	out_Location.Y = 0;

	HitActor = Trace(HitLocation, HitNormal, CursorLocation, out_Location, true);

	//Return false if cursor is not hitting anything
	if(HitActor == none)
	{
		return False;
	}

	//Check for multiple cases of hitting a target
	if(HitActor.IsA('PR0Pawn') && (HitActor.Location==CursorLocation || (Abs(CursorLocation.X-HitActor.Location.X) <= 50.0f) || (Abs(CursorLocation.Z-HitActor.Location.Z) <= 50.0f))
		&& (VSize(out_Location-CursorLocation)<=PossessionRange))
	{
		return True;
	}
	else
	{
		return False;
	}
}

exec function Actor GetPossessionTarget()
{
	//Pawn's location. The start of the trace
	local Vector out_Location;
	//Pawn's rotation (which way the cursor is facing)
	local Rotator out_Rotation;
	//The location of the cursor. The end of the trace
	local Vector CursorLocation;
	//The line which character will attempt to cast Possession
	local Vector PossessionLine;
	//The actor which is hit by possession
	local Actor HitActor;
	//Location where the trace hits an actor
	local Vector HitLocation;
	//The normal where the trace hits an actor
	local Vector HitNormal;

	FlushPersistentDebugLines();
	//Get the pawn's viewpoint (not based on camera)
	Pawn.GetActorEyesViewPoint(out_Location, out_Rotation);
	
	//The cursor's vector is stored in the HUD
	CursorLocation = PR0HUDGfx(myHUD).WorldCursorOrigin;

	//Force the Y-position to be zero
	CursorLocation.Y = 0;
	out_Location.Y = 0;
	DrawDebugSphere(CursorLocation, 50, 10, 0, 255, 0, true);

	/** The following codes are used to determine the exact line which possession should be applied
	 *  The steps are as follows:
	 *  1. Get the line which connects the Player's viewpoint and the cursor
	 *  2. Normalize that line, so the length of that line is 1
	 *  3. Multiply by PossessionRange, giving us a line with exact length that we want*/
	PossessionLine = CursorLocation - out_Location;
	DrawDebugLine(out_Location, CursorLocation, 0, 255, 0, true);

	CursorLocation = out_Location + (PossessionLine * PossessionRange) / VSize(PossessionLine);
	DrawDebugLine(out_location,CursorLocation,255,0,0,true);
	DrawDebugSphere(CursorLocation, 50, 100, 255,0,0,true);

	HitActor = Trace(HitLocation, HitNormal, CursorLocation, out_Location, true);

	`log("HitActor is "$HitActor);
	if(HitActor.IsA('PR0Pawn'))
	{
		//The possession hits a bot and will possess it
		return HitActor;
	}
	else
	{
		//The possession misses, none will be returned
		return none;
	}
}

//Possesses a different pawn
function OnPossess(SeqAct_Possess inAction)
{
	//Reference to bot pawn to possess
	local Pawn PawnToPossess;
	//Reference to player's light
	local PointLightComponent HeroLight;


    if(possessed==TRUE)
    {
        ReturnToNormal();
    }
    else
    {
		PawnToPossess = PR0Pawn(GetPossessionTarget());
        if( PawnToPossess != None )
        {
			//Target to possess is found, and we will possess it
			possessed=TRUE;
			PR0HUDGfx(myHUD).HudMovie.PosCountdown();
			//Stop Bot firing when he is firing
			PawnToPossess.StopFire(0);

			//Hide PlayerPawn, Set Collision to NoCollision, and Turn off HeroLight
            OldPawn = Pawn;
            UnPossess();
            OldPawn.SetHidden(TRUE);
            OldPawn.SetCollisionType(COLLIDE_NoCollision);
			foreach OldPawn.Mesh.AttachedComponents(class'PointLightComponent', HeroLight)
			{
				HeroLight.SetEnabled(FALSE);
			}

            Possess( PawnToPossess, FALSE );
			SetTimer(1, true, 'PosCountdown', PR0HUDGfx(myHUD).HudMovie);
            SetTimer(6, false, 'ReturnToNormal');
        }    
		else
		{
			`log("TARGET NOT FOUND");
		}
    }
}

//Unpossesses and returns the original character
function ReturnToNormal()
{
	//Reference to the bot
    local Pawn EnemyPawn;
	//Reference to player's light
	local PointLightComponent HeroLight;
	
	PR0HUDGfx(myHUD).HudMovie.EndPosCountdown();
	SetTimer(0.f);

	//Return when player already unpossessed
	if(possessed == FALSE)
	{
		return;
	}
	
    possessed=FALSE;
    EnemyPawn = Pawn;
    UnPossess();
    EnemyPawn.SetCollisionType(COLLIDE_NoCollision);
    Possess(OldPawn, FALSE);
    OldPawn.SetLocation(EnemyPawn.Location);
    
    if(EnemyPawn != None)
    {
        EnemyPawn.Destroy();
    }

    OldPawn.SetHidden(FALSE);
    OldPawn.SetCollisionType(COLLIDE_BlockAll);
	foreach OldPawn.Mesh.AttachedComponents(class'PointLightComponent', HeroLight)
	{
		HeroLight.SetEnabled(TRUE);
	}
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	//Handles current move on the client
	function ProcessMove(float DeltaTime, Vector NewAccel, EDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
		local Rotator TempRot;

		//Pawn is dead or missing hence no move is required
		if(Pawn == none)
		{
			return;
		}

		//ENetRole
		//ROLE_None No role at all.
		//ROLE_SimulatedProxy Locally simulated proxy of this actor.
		//ROLE_AutonomousProxy Locally autonomous proxy of this actor.
		//ROLE_Authority Authoritative control over the actor.
		if(Role == ROLE_AUTHORITY)
		{
			//Update ViewPitch for remote clients
			//So remote clients know where this pawn is looking (Pawn's Rotation)
			Pawn.SetRemoteViewPitch(Rotation.Pitch);
		}

		Pawn.Acceleration.X = -1 * PlayerInput.aStrafe * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
		Pawn.Acceleration.Y = 0;

		//Flying physics only available when the player is not possessing any bot
		if(possessed == FALSE)
		{
			if(PlayerInput.aUp != 0)
			{
			   Flying = TRUE;
			   Pawn.SetPhysics(PHYS_Flying);
			}
			else if(PlayerInput.aUp == 0 && Flying)
			{
				Flying = FALSE;
				Pawn.SetPhysics(PHYS_Falling);
			}
			ModifyLightIntensity();
			Pawn.Acceleration.Z = PlayerInput.aUp * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
		}

		TempRot.Pitch = Pawn.Rotation.Pitch;
		TempRot.Roll = 0;
		//To make the Pawn's rotation match the Acceleration
		if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) > 0)
		{
			TempRot.Yaw = 0;
			Pawn.SetRotation(TempRot);
		}
		//else, the pawn is looking backwards, we rotate it 180 degrees
		else if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) < 0)
		{
			TempRot.Yaw = 180 * DegToUnrRot;
			Pawn.SetRotation(TempRot);
		}

		//Check if the player is jumping or ducking, and apply physics accordingly
		CheckJumpOrDuck();
	}

	function UpdateRotation(float DeltaTime)
	{
		//The cursor location
		local Vector CursorLocation;

		//Calculate Delta to be applied to ViewRotation
		//DeltaRot.Yaw = Pawn.Rotation.Yaw;
		//DeltaRot.Pitch = PlayerInput.aLookUp;

		//Processes the player ViewRotation adds DeltaRot (player's input)
		//ProcessViewRotation(DeltaTime, ViewRotation, DeltaRot);
		CursorLocation = PR0HUDGfx(myHUD).WorldCursorOrigin;
		CursorLocation.Y = 0;
		
		//Set the Pawn's rotation
		SetRotation(Rotator(Normal(CursorLocation - Location)));
	}
}

DefaultProperties
{
	bForceBehindView = false
	bIsPlayer = true
	Possessed = false
	Flying = false
	PossessionRange=400
	LightGrowRate=10
	LightDimRate=5
	MaxLightRange=500
	MinLightRange=100
	InputClass=class'PR0.MouseInterfacePlayerInput'
}
