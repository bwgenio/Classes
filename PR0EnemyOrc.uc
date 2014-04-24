class PR0EnemyOrc extends PR0EnemyGoblin;

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	super.SetCharacterClassFromInfo(Info);
	Mesh.SetSkeletalMesh(SkeletalMesh'PRAsset.EnemyGoblin.OrcMesh');
	Mesh.SetAnimTreeTemplate(AnimTree'PRAsset.EnemyGoblin.EnemyAnimTree');
	Mesh.SetPhysicsAsset(PhysicsAsset'PRAsset.EnemyGoblin.OrcMesh_Physics');
	Mesh.AnimSets = defaultAnimSet;
}

DefaultProperties
{
	defaultAnimSet(0) = AnimSet'PRAsset.EnemyGoblin.EnemyGoblinAnims'
	DeathSoundCue = SoundCue'PRAsset.EnemySFX.Orc_death1_Cue'
	SuspicionDistance = 800
	HostileDistance = 400
	MaxFireDistance = 150
	ChaseTimer = 3
	AlertnessIncrement = 3
}
