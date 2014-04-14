class PR0Pawn extends UTPawn;

var GFxPosMiniGame PosMiniGamemovie;

//Position of Y-AXIS to lock the camera to
var(Camera) float CamOffsetDistance;

simulated event PreBeginPlay()
{
	super.PreBeginPlay();

}


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
	PosMiniGamemovie = PR0PlayerController(WorldInfo.GetALocalPlayerController()).PosMiniGameMovie;
	if(PosMiniGamemovie != none)
	{
		PosMiniGamemovie.isCaptured(false);
	}
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
DefaultProperties
{
	PosMiniGamemovie = none;
	CamOffsetDistance = -700.0
}
