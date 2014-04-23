class PR0EnemyDarkElf extends PR0Pawn;

var AnimNodePlayCustomAnim ArrowShootAnim;
//var AnimNodePlayCustomAnim DeathAnim;
//var class<DamageType> DmgType;
//var Vector HitLocation;

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	super.SetCharacterClassFromInfo(class'PR0.PR0FamilyInfo_DarkElf');
	Mesh.SetAnimTreeTemplate(AnimTree'PRAsset.EnemyDarkElf.EnemyAnimTree');
	//Mesh.SetSkeletalMesh(SkeletalMesh'PRAsset.EnemyDarkElf.DarkElf');
	//Mesh.SetPhysicsAsset(PhysicsAsset'PRAsset.EnemyDarkElf.DarkElf_Physics');
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        ArrowShootAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnim'));
		DeathAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomDeathAnim'));
    }
}

//simulated event PlayDying(class<DamageType> DamageType, Vector HitLoc)
//{
//	DeathAnim.PlayCustomAnim('Death', 1.0);
//	DmgType = DamageType;
//	HitLocation = HitLoc;

//	SetTimer(2.0, false, 'destroyPawn');
//}

//function destroyPawn()
//{
//	super.PlayDying(DmgType, HitLocation);
//}

DefaultProperties
{
	SuspicionDistance = 1000
	HostileDistance = 600
	MaxFireDistance = 600
	ChaseTimer = 3
	AlertnessIncrement = 2
	DeathSoundCue = SoundCue'PRAsset.EnemySFX.DarkElf_Death1_Cue'
}
