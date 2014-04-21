class PR0EnemyGoblin extends PR0Pawn;

var array<AnimSet> defaultAnimSet;

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	super.SetCharacterClassFromInfo(Info);
	Mesh.SetAnimTreeTemplate(AnimTree'PRAsset.EnemyGoblin.EnemyAnimTree');
	Mesh.SetSkeletalMesh(SkeletalMesh'PRAsset.EnemyGoblin.GoblinMesh');
	Mesh.AnimSets = defaultAnimSet;
	Mesh.SetPhysicsAsset(PhysicsAsset'PRAsset.EnemyGoblin.GoblinMesh_Physics');
}

DefaultProperties
{
	defaultAnimSet(0) = AnimSet'PRAsset.EnemyGoblin.EnemyGoblinAnims'
	GroundSpeed = 500;
}
