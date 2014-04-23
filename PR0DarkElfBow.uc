class PR0DarkElfBow extends UDKWeapon;

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
			setTimer(1.25, false, 'ProjectileFire');
			setTimer(1.25, false, 'PlaySFX');
		}
	}
}

function PlaySFX()
{
	PlaySound(SoundCue'PRAsset.EnemySFX.DarkElf_Arrow1_Cue');
}

function setAttackAnimationBool()
{
	PR0EnemyDarkElf(Owner).isPlayingAttackAnimation = false;
}

DefaultProperties
{
	FiringStatesArray(0) = WeaponFiring 
    WeaponFireTypes(0) = EWFT_Projectile
    FireInterval(0) = 1.5
    Spread(0) = 0
	ShouldFireOnRelease(0) = 0

	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh = SkeletalMesh'PRAsset.EnemyDarkElfAsset.DarkElfBow_skele'
		HiddenGame = FALSE
		HiddenEditor = FALSE
	end Object
	Mesh = GunMesh
	Components.Add(GunMesh)

	WeaponProjectiles(0) = class'PR0.PR0ArrowShot'
}
