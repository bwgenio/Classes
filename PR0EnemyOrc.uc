class PR0EnemyOrc extends PR0Pawn;

var array<AnimSet> defaultAnimSet;

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
}
