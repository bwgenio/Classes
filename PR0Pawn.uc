class PR0Pawn extends UTPawn;

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
	HeroLight.Radius = 100;
	Mesh.AttachComponent(HeroLight, 'b_Neck');
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	HeroLight.SetEnabled(TRUE);
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

//Checks when pawn is touching floor. Removes damage from falling
simulated event Landed(Vector HitNormal, Actor FloorActor)
{
	//Resets the souluminescence radius to its minimum
	HeroLight.Radius = 100;
	SetPhysics(PHYS_Walking);
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(Controller.IsA('PR0Bot'))
	{
		//Alert enemy bot when they are hit 
		PR0Bot(Controller).AlertBotWhenHit(UTWeapon(DamageCauser).Owner);
	}
	if(PR0PlayerController(controller).PosMiniGameMovie.bMovieIsOpen)
	{
		//closes the possession mini game swf if player gets damage.
		PR0PlayerController(controller).PosMiniGameMovie.isCaptured(false);
	}
	//Overwrites the momentum so the player won't be flying back when shot
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Vect(0,0,0), DamageType, HitInfo, DamageCauser);
}

simulated event playDying(class<DamageType> DamageType, vector HitLoc)
{
	local PR0PlayerController PC;
	ForEach LocalPlayerControllers(class'PR0PlayerController', PC)
		{
			if( pc.ViewTarget == self )
			{
				if ( PR0HUDGfx(pc.MyHud)!=none )
					PR0HUDGFx(pc.MyHud).HudMovie.TickHUD();
				break;
			}
		}
		ConsoleCommand("open ?restart");
		PR0HUDGFx(pc.MyHud).TogglePauseMenu();
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

//Handler of the start firing kismet function
function OnAIStartFireAt(UTSeqAct_AIStartFireAt Action)
{
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

	//Begin Object Class=PointLightComponent Name=HeroLightEnvironment
		
	//	bSynthesizeSHLight=TRUE
	//	bIsCharacterLightEnvironment=TRUE
	//	bEnabled = TRUE
	//	Radius = 200
	//End Object
	//LightEnvironment=HeroLightEnvironment
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
}
