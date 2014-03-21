class LumosPickup extends UTPickupFactory_HealthVial

HideCategories(Object, Debug, Advanced, Mobile, Physics);

function PickedUpBy(Pawn P)
{
	if(P.Controller.IsA('PR0PlayerController'))
	{
		//lumos is picked up by player
		PR0PlayerController(P.Controller).IncreaseLuminosityPoints();
		super.PickedUpBy(P);
	}

}


DefaultProperties
{
	Begin Object Name=HealthPickupMesh
		StaticMesh=StaticMesh'PRAsset.Assets.Lumos_pickup'
		Scale = 0.25
	End Object

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+10.000000
		CollisionHeight=+10.000000
		CollideActors=true
	End Object

	bCollideActors = true

	HealingAmount = 0
	PickupSound = SoundCue'PRAsset.Music.Lumos_Pickup_SoundCue'

	bFloatingPickup=true
	BobSpeed = 1.0
	BobOffset = 10.0
	bRotatingPickup = true
	YawRotationRate = 32000

	bIsRespawning = false
}
