class PR0PlayerController extends UTPlayerController;

var Pawn OldPawn;
var bool possessed, Flying, Illuminating, bPosIsReady;
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
//The lumos points which the player has
var(Ability) int LuminosityPoints;
//the enemy to possess
var editconst Pawn PawnToPossess;
//Possession MiniGame Movie
var GFxPosMiniGame PosMiniGameMovie;
//holds the xbox values for the cursor
var float MouseY;
var float MouseX;
var PR0Pawn currentPawn;
//Damage point to the player's health when he is under light
var(Logic) int LightDamage;
var PR0Pawn temp;
var SkeletalMesh defaultMesh;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;

simulated function PostBeginPlay() {
	super.PostBeginPlay();
}

function ModifyLightIntensity()
{
	local PointLightComponent HeroLight;

	foreach Pawn.Mesh.AttachedComponents(class'PointLightComponent', HeroLight)
	{

		//Dim the light when descending or brigtness points is zero
		if(Illuminating == FALSE || LuminosityPoints <= 0)
		{
			HeroLight.Radius = Max(HeroLight.Radius - LightDimRate, MinLightRange);
		}
		//Brighten the light when jumping
		else
		{
			HeroLight.Radius = Min(HeroLight.Radius + LightGrowRate, MaxLightRange);
			LuminosityPoints -= 10;
		}

	}

}

function IncreaseLuminosityPoints()
{
	LuminosityPoints = Min(Default.LuminosityPoints, LuminosityPoints + 750);
}

function bool IsCursorOnEnemy()
{
	//Pawn's location. The start of the trace
	local Vector out_Location;
	//Pawn's rotation (which way the cursor is facing)
	local Rotator out_Rotation;
	//The location of the cursor. The end of the trace
	local Vector CursorLocation;
	//The enemy bot which is hit by possession
	local PR0Pawn HitActor;
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

	//HitActor = Trace(HitLocation, HitNormal, CursorLocation, out_Location, true);
	foreach TraceActors(class'PR0Pawn', HitActor, HitLocation, HitNormal, CursorLocation, out_Location)
	{
		break;
	}
	
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

//gets called by kismet when trigger is touched
//calls the function to display the tutorial messages from GfxHud
exec function TutDisplay()
{
	//GotoState('PlayerWaiting');
	PR0HUDGfx(myHUD).HudMovie.TutDisplay();
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
	local PR0Pawn HitActor;
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

	//HitActor = Trace(HitLocation, HitNormal, CursorLocation, out_Location, true);
	foreach TraceActors(class'PR0Pawn', HitActor, HitLocation, HitNormal, CursorLocation, out_Location)
	{
		break;
	}

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

// lights up the player
//gets called on button F
exec function Illuminate()
{
	Illuminating = true;
}

// turns off player
// gets called onRelease of button F
exec function StopIlluminate()
{
	Illuminating = false;
}

function SuccessPossess()
{
	//Reference to player's light
	local PointLightComponent HeroLight;
	//refrence to movie
	local GFxHUD Movie;

    if(possessed==TRUE)
    {
        ReturnToNormal();
    }
    else
    {
		PosMiniGameMovie.Close();
		PosMiniGameMovie = none;
		PR0HUDGfx(myHUD).ToggleHUD();
		Movie = PR0HUDGfx(myHUD).HudMovie;
		//Target to possess is found, and we will possess it
		possessed=TRUE;
		Movie.PosCountdown();
		//Stop Bot firing when he is firing
		PawnToPossess.StopFire(0);
		//Reset's the pawn alertness
		//PR0Bot(PawnToPossess.Controller).UpdateAlertness(0);

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
	}
}

function StartChessGame(SeqAction_StartChess myAction)
{
	local GFxKnightMiniGame Movie;
	local float Level;

	Level = myAction.Level;

	Movie = new class'GFxKnightMiniGame';
	Movie.begin(level);
}

function EndChessGame()
{
	//Trigger door opening
	TriggerEventClass(class'SeqEvent_EndChess', self);
}

//Possesses a different pawn
// gets called onClick of right mouse click
exec function PossessEnemy()
{
	//refrence to movie
	local GFxPosMiniGame Movie;

    if(possessed==TRUE)
    {
        ReturnToNormal();
    }
	else if(PosMiniGameMovie != none)
	{
		PosMiniGameMovie.isCaptured(false);
	}
    else
    {
		PawnToPossess = PR0Pawn(GetPossessionTarget());
        if( PawnToPossess != None )
        {
			PR0HUDGfx(myHUD).ToggleHUD();
			Movie = new class'GFxPosMiniGame';
			Movie.Init();
			PosMiniGameMovie = Movie;		
        }
		else
		{
			`log("TARGET NOT FOUND");
		}
    }
}

function togglePosReady(bool state)
{
	bPosIsReady = state;
}

//Unpossesses and returns the original character
function ReturnToNormal()
{
	//Reference to the bot
    local Pawn EnemyPawn;
	//Reference to player's light
	local PointLightComponent HeroLight;

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
		local DamagingLight MapLights;

		//Pawn is dead or missing hence no move is required
		if(Pawn == none)
		{
			return;
		}
		
		//Damage to light only applicable when player is in ghost form
		if(possessed == false)
		{
			foreach WorldInfo.AllActors(class'DamagingLight', MapLights )
			{
				//Check if light is enabled and player is within the light's radius
				if(MapLights.LightComponent.bEnabled && PointLightComponent(MapLights.LightComponent).Radius >= VSize(Pawn.Location - MapLights.Location))
				{
					//Check if player inside the lightcone, if he does, then take damage
					if (SpotLightComponent(MapLights.LightComponent).OuterConeAngle >= (180 - RadToDeg * Atan2((Pawn.Location.X - MapLights.Location.X),(Pawn.Location.Z - MapLights.Location.Z))))
					{
						Pawn.TakeDamage(LightDamage, self, Pawn.Location, Vect(0,0,0), class'DmgType_Crushed',,Pawn);
					}			
				}
			}

			//Flying physics only available when the player is not possessing any bot
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
		SetRotation(Rotator(Normal(CursorLocation - Pawn.Location - vect(0,0,50))));
	}
}

event PlayerTick (float DeltaTime)
{
	MouseY = PlayerInput.aLookUp * 25;
	MouseX = PlayerInput.aTurn * 25;
	if(PosMiniGameMovie != none)
	{
		PosMiniGameMovie.tick();
	}
	super.PlayerTick(DeltaTime);
}

//returns MouseY
function float returnMouseY()
{
	return MouseY;
}

//returns MouseX
function float returnMouseX()
{
	return MouseX;
}

public function ghostForm(){
//	local PR0Pawn temp;
//	temp.SetCharacterClassFromInfo(class'PR0.PR0FamilyInfo_Ghost');
//	Pawn=temp;
//	Unpossess();
//	Possess(temp, FALSE);
//	self.Pawn.Mesh.SetSkeletalMesh(defaultMesh);
//	self.Pawn.Mesh.AnimSets=defaultAnimSet;
//	self.Pawn.Mesh.SetAnimTreeTemplate(defaultAnimTree);
}


DefaultProperties
{
	bIsPlayer = true
	PosMiniGameMovie = none
	//PlayerReplicationInfo =  class'PR0.PR0PlayerReplicationInfo'
	bForceBehindView = false
	Possessed = false
	Flying = false
	Illuminating = false
	bPosIsReady = true
	LuminosityPoints = 3000
	PossessionRange=400
	LightGrowRate=10
	LightDimRate=5
	MaxLightRange=500
	MinLightRange=100
	LightDamage=2
	MouseY=0
	MouseX=0
	InputClass=class'PR0.PR0PlayerInput'
	SupportedEvents.Add(class'SeqEvent_TriggerAlarm')
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA';
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human';
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
}
