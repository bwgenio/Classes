class PR0PlayerController extends UTPlayerController;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	`log("PR0PlayerController is up!");
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
		Pawn.Acceleration.Z = 0;

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
}
