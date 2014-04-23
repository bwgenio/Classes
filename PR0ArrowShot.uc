class PR0ArrowShot extends UDKProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if(Other != Instigator)
	{
		//Spawn damage particle
		Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), class'UTDmgType_Fire',,self);
		Destroy();
	}
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=8
		CollisionHeight=16
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    Components.Add(MyLightEnvironment)

	Begin object class=StaticMeshComponent Name=BaseMesh
        StaticMesh = StaticMesh'PRAsset.EnemyDarkElfAsset.DarkElfArrow_static'
        LightEnvironment=MyLightEnvironment
    End object
 
    Components.Add(BaseMesh)

	Speed = 2000
	MomentumTransfer = 0
	Damage = 40
}
