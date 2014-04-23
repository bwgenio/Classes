class PR0Pawn extends UTPawn;

//Position of Y-AXIS to lock the camera to
var(Camera) float CamOffsetDistance;

// check whether the user is attacking
var bool isPlayingAttackAnimation;

/** Collection of gameplay elements 
 **/
// The distance which bot will become suspicious
var(Gameplay) float SuspicionDistance;
//The distance which bot will become hostile
var(Gameplay) float HostileDistance;
//The Alertness increment of bot. How much alertness should be increased
var(Gameplay) int AlertnessIncrement;
//Bot's maximum fire distance
var(Combat) float MaxFireDistance;
//Bot's chase Timer (seconds)
var(Combat) float ChaseTimer;

var AnimNodePlayCustomAnim DeathAnim;
var class<DamageType> DmgType;
var Vector HitLoc;
var SoundCue DeathSoundCue;

simulated function Tick(float DeltaTime)
{
	//Variable to hold reference to pawn's location
	local Vector tempLocation;

	super.Tick(DeltaTime);

	//Makes sure the pawn stays in Y=0 line
	tempLocation = Location;
	tempLocation.Y = 0;
	SetLocation(tempLocation);
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{	
	if(Controller.IsA('PR0Bot'))
	{
		//Alert enemy bot when they are hit 
		PR0Bot(Controller).AlertBotWhenHit(UTWeapon(DamageCauser).Owner);
	}
	//Overwrites the momentum so the player won't be flying back when shot
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Vect(0,0,0), DamageType, HitInfo, DamageCauser);
}

//Override to make player mesh visible by default
simulated event BecomeViewTarget(PlayerController PC)
{
	local UTPlayerController UTPC;
	
	Super.BecomeViewTarget(PC);

	if(LocalPlayer(PC.Player) != none)
	{
		UTPC = UTPlayerController(PC);
		if(UTPC != none)
		{
			//Set player controller to be behind the view
			UTPC.SetBehindView(TRUE);
			//Make mesh visible
			SetMeshVisibility(UTPC.bBehindView);
			//Hide the crosshair
			UTPC.bNoCrosshair = true;
		}
	}
}

simulated function bool CalcCamera(float fDeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	//Set the camera's X and Z position as the Pawn's location
	out_CamLoc = Location;
	//Set the camera's Y position as the view offset
	out_CamLoc.Y = CamOffsetDistance;
	
	//Perfectly Horizontal camera has Pitch = 0
	out_CamRot.Pitch = 0;
	//Perfectly Horizontal camera has Roll = 0
	out_CamRot.Roll = 0;
	//90 degrees offset of Side scrolling camera applies when Yaw = 16384
	out_CamRot.Yaw = 16384;

	return true;
}

//Returns the basic aim rotation without any adjustments
simulated singular event Rotator GetBaseAimRotation()
{
	//The rotation of this pawn
	local Rotator POVRot;

	//Set the POVRot to the previous rotation value of this pawn
	POVRot = Rotation;

	if((Rotation.Yaw % 65535 > 16384 && Rotation.Yaw % 65535 < 49560) ||
		(Rotation.Yaw % 65535 < -16384 && Rotation.Yaw % 65535 > -49560) )
	{
		POVRot.Yaw = 32768;
	}
	else
	{
		POVRot.Yaw = 0;
	}

	if(POVRot.Pitch == 0)
	{
		POVRot.Pitch = RemoteViewPitch << 8;
	}
	

	return POVRot;
}

simulated event PlayDying(class<DamageType> DamageType, Vector HitLocation)
{
	local ParticleSystem PS;

	PS = ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Far';

	//Play the particle system for pawn's death
	WorldInfo.MyEmitterPool.SpawnEmitter(PS, Location);

	//Play deathsound for pawn's death
	PlaySound(DeathSoundCue);

	DeathAnim.PlayCustomAnim('Death', 1.0);
	DmgType = DamageType;
	HitLoc = HitLocation;

	SetTimer(2.0, false, 'destroyPawn');
}

function destroyPawn()
{
	super.PlayDying(DmgType, HitLoc);
}

DefaultProperties
{
	CamOffsetDistance = -700.0
	isPlayingAttackAnimation = false
	//GroundSpeed = 120;
}
