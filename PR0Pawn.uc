class PR0Pawn extends UTPawn;

//THIS IS A COMMENT

//Position of Y-AXIS to lock the camera to
var(Camera) float CamOffsetDistance;
//Light that emits from the player
var(Light) PointLightComponent HeroLight;
//Light Radius
var(Light) int Radius;
//The color of the emitting light
var(Light) Color LightColor;

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	HeroLight = new(self)class'PointLightComponent';
	HeroLight.SetLightProperties(5,LightColor);
	HeroLight.Radius = 200;
	AttachComponent(HeroLight);
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	`log("PR0Pawn is up");
}

//Checks when pawn is touching floor. Removes damage from falling
simulated event Landed(Vector HitNormal, Actor FloorActor)
{
	SetPhysics(PHYS_Walking);
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
	out_CamRot.Yaw = 90 * DegToUnrRot;

	return true;
}

//Returns the basic aim rotation without any adjustments
simulated singular event Rotator GetBaseAimRotation()
{
	//The rotation of this pawn
	local Rotator POVRot;

	//Set the POVRot to the previous rotation value of this pawn
	POVRot = Rotation;

	if((Rotation.Yaw % 65535 > 90 * DegToUnrRot && Rotation.Yaw % 65535 < 49560) ||
		(Rotation.Yaw % 65535 < -90 * DegToUnrRot && Rotation.Yaw % 65535 > -49560) )
	{
		POVRot.Yaw = 180 * DegToUnrRot;
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

//Handler of the start firing kismet function
function OnAIStartFireAt(UTSeqAct_AIStartFireAt Action)
{
	//Controller.GotoState('Attack');
	//Action.LinkedVariables(class'Player', Target);
	//Target = Action.InputLinks

	//Make Bot start firing at player
	Controller.GotoState('Attack');
}

DefaultProperties
{
	CamOffsetDistance = -700.0

	LightColor = (R=255,G=255,B=255,A=0)

	//Begin Object class=DynamicLightEnvironmentComponent Name=HeroLightEnvironment
	//	bEnabled = true
	//	bIsCharacterLightEnvironment = true
	//	bSynthesizeDirectionalLight = true
	//	bUseBooleanEnvironmentShadowing = false
	//	InvisibleUpdateTime = 1.f
	//End Object
	//LightEnvironment = HeroLightEnvironment
	//Components.Add(HeroLightEnvironment)

	Begin Object class=SkeletalMeshComponent Name=SandboxPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		//LightEnvironment = HeroLightEnvironment
		Translation = (Z=-10)
		HiddenGame=FALSE
		HiddenEditor=FALSE
    End Object


    Mesh=SandboxPawnSkeletalMesh
    Components.Add(SandboxPawnSkeletalMesh)

	// TODO: TEST ADDING EVENTS HERE INSTEAD OF CONTROLLER
	SupportedEvents.Add(class'SeqEvent_TriggerAlarm')
	SupportedEvents.Add(class'SeqEvent_BotStartShooting')
	SupportedEvents.Add(class'SeqEvent_StateChange')
}