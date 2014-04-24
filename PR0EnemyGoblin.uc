class PR0EnemyGoblin extends PR0Pawn;

var AnimNodePlayCustomAnim AttackAnim;
var array<AnimSet> defaultAnimSet;

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	super.SetCharacterClassFromInfo(Info);
	Mesh.SetAnimTreeTemplate(AnimTree'PRAsset.EnemyGoblin.EnemyAnimTree');
	Mesh.SetSkeletalMesh(SkeletalMesh'PRAsset.EnemyGoblin.GoblinMesh');
	Mesh.AnimSets = defaultAnimSet;
	Mesh.SetPhysicsAsset(PhysicsAsset'PRAsset.EnemyGoblin.GoblinMesh_Physics');
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        AttackAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomAnim'));
		DeathAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('CustomDeathAnim'));
    }
}

DefaultProperties
{
	defaultAnimSet(0) = AnimSet'PRAsset.EnemyGoblin.EnemyGoblinAnims'
	DeathSoundCue = SoundCue'PRAsset.EnemySFX.Goblin_death1_Cue'
	SuspicionDistance = 800
	HostileDistance = 400
	MaxFireDistance = 150
	ChaseTimer = 3
	AlertnessIncrement = 8
}
