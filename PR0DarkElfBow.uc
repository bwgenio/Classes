class PR0DarkElfBow extends UDKWeapon;

var(Mechanics) float FireRate;

simulated event StartFire(byte FireModeNum)
{
	if (PR0EnemyDarkElf(Owner).isPlayingAttackAnimation == false)
	{
		// Primary Attack
		if (FireModeNum == 0)
		{
			PR0EnemyDarkElf(Owner).ArrowShootAnim.PlayCustomAnim('ATTACK', 1.75);
			PR0EnemyDarkElf(Owner).isPlayingAttackAnimation = true;

			setTimer(1.75, false, 'setAttackAnimationBool');
			setTimer(1.9, false, 'FireProjectile');
		}
	}
}

function setAttackAnimationBool()
{
	PR0EnemyDarkElf(Owner).isPlayingAttackAnimation = false;
}

function FireProjectile()
{
	super.StartFire(0);
}

DefaultProperties
{
	FiringStatesArray(0) = WeaponFiring 
    WeaponFireTypes(0) = EWFT_Projectile
    FireInterval(0) = 1.5
    Spread(0) = 0

	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh = SkeletalMesh'PRAsset.EnemyDarkElfAsset.DarkElfBow_skele'
		HiddenGame = FALSE
		HiddenEditor = FALSE
	end Object
	Mesh = GunMesh
	Components.Add(GunMesh)

	WeaponProjectiles(0) = class'PR0.PR0ArrowShot'
	FireRate = 2.0
}
