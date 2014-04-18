class PR0PlayerPawn extends PR0Pawn;

//Light that emits from the player
var(Light) PointLightComponent HeroLight;
//Light Radius
var(Light) int Radius;
//The color of the emitting light
var(Light) Color LightColor;

// members for the custom mesh
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

var(Movement) float TranslationOffset;

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	HeroLight = new(self)class'PointLightComponent';
	HeroLight.SetLightProperties(5,LightColor);
	HeroLight.Radius = 100;
	Mesh.AttachComponent(HeroLight, 'HatTip');
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	HeroLight.SetEnabled(TRUE);
}

//Checks when pawn is touching floor. Removes damage from falling
simulated event Landed(Vector HitNormal, Actor FloorActor)
{
	//Resets the souluminescence radius to its minimum
	HeroLight.Radius = 100;
	SetPhysics(PHYS_Walking);
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local ParticleSystem PS;

	PS = ParticleSystem'PRAsset.Particles.P_VH_Death_Dust_Secondary';

	// Play player death particle effect
	WorldInfo.MyEmitterPool.SpawnEmitter(PS, Location);
	
	// Make the player mesh disappear
	PR0PlayerController(Controller).IgnoreMoveInput(true);
	SetInvisible(true);
	Mesh.SetSkeletalMesh(none);

	SetTimer(2, false, 'playDyingFlash');
}

function playDyingFlash()
{
	local PR0PlayerController PC;
	local PR0HUDGfx HUDmovie;
	local GFxRespawnMovie RespawnMovie;

	ForEach LocalPlayerControllers(class'PR0PlayerController', PC)
	{
		if( pc.ViewTarget == self )
		{
			HUDmovie = PR0HUDGFx(pc.MyHud);
			RespawnMovie = new class'GFxRespawnMovie';
			if ( HUDmovie!=none )
				HUDmovie.HudMovie.TickHUD();
				HUDmovie.ToggleHUD();
				RespawnMovie.Begin();
			break;
		}
	}

	pc.SetPause(true);
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	//local vector TranslationVector;
	//TranslationVector.Z = TranslationOffset;

	//super.SetCharacterClassFromInfo(Info);
	//Mesh.SetSkeletalMesh(defaultMesh);
	////Mesh.SetMaterial(0,defaultMaterial0);
	////Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	//Mesh.AnimSets=defaultAnimSet;
	//Mesh.SetAnimTreeTemplate(defaultAnimTree);
	//Mesh.SetTranslation(TranslationVector);
	////Mesh.SetScale(0.5);
	super.SetCharacterClassFromInfo(class'PR0.PR0FamilyInfo_Ghost');
	Mesh.SetAnimTreeTemplate(AnimTree'PlayerCharacter.MageAnimTree');
}

DefaultProperties
{
	LightColor = (R=255,G=255,B=255,A=0)
	SpawnSound = none

	/*Begin Object Name=SandboxPawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'PlayerCharacter.Mesh.Mage'
		AnimSets(0)=AnimSet'PlayerCharacter.Anims.MageAnims'
		AnimTreeTemplate=AnimTree'PlayerCharacter.MageAnimTree'
		HiddenGame=FALSE
		HiddenEditor=FALSE
		Scale = 0.50
		Translation = (Z=-100)
    End Object*/

	//Begin Object NAME=CollisionCylinder 
	//	CollideActors=true
	//	CollisionRadius=+20
	//	CollisionHeight=+50
	//	bAlwaysRenderIfSelected=true
	//	//bDrawWireCylinder=true;
	//	Translation = (Z=20)
	//End Object
	//CollisionComponent=CollisionCylinder
	//CylinderComponent=CollisionCylinder
	//Components.Add(CollisionCylinder)

	//defaultMesh=SkeletalMesh'PlayerCharacter.Mesh.Mage'
	//defaultAnimTree=AnimTree'PlayerCharacter.MageAnimTree'
	//defaultAnimSet(0)=AnimSet'PlayerCharacter.Anims.MageAnims'

	TranslationOffset = -200
}
