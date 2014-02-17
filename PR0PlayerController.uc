class PR0PlayerController extends UTPlayerController;

var Pawn OldPawn;
var bool possessed, Flying;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	`log("PR0PlayerController is up!");
}

function UpdateLightWhenJump()
{
	local PointLightComponent HeroLight;

	foreach Pawn.Mesh.AttachedComponents(class'PointLightComponent', HeroLight)
	{
		//HeroLight.Radius += 1
	}
}

//Possesses a different pawn
function OnPossess(SeqAct_Possess inAction)
{
    if(possessed==TRUE)
    {
        ReturnToNormal();
    }
    else
    {
        possessed=TRUE;
        if( inAction.PawnToPossess != None )
        {
            OldPawn = Pawn;
            UnPossess();
            OldPawn.SetHidden(TRUE);
            OldPawn.SetCollisionType(COLLIDE_NoCollision);
            Possess( inAction.PawnToPossess, FALSE );
            SetTimer(5, false, 'ReturnToNormal');
        }    
    }
}

//Unpossesses and returns the original character
function ReturnToNormal()
{
    local Pawn EnemyPawn;
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
        Pawn.Acceleration.Z = PlayerInput.aUp * DeltaTime * 1000;

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
		local Rotator DeltaRot, ViewRotation;

		ViewRotation = Rotation;

		//Calculate Delta to be applied to ViewRotation
		DeltaRot.Yaw = Pawn.Rotation.Yaw;
		DeltaRot.Pitch = PlayerInput.aLookUp;

		//Processes the player ViewRotation adds DeltaRot (player's input)
		ProcessViewRotation(DeltaTime, ViewRotation, DeltaRot);

		//Set the Pawn's rotation
		SetRotation(ViewRotation);
	}
}

DefaultProperties
{
	Possessed = false
	Flying = false
}
