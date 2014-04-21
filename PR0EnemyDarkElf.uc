class PR0EnemyDarkElf extends PR0Pawn;

var AnimNodePlayCustomAnim ArrowShootAnim;

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
    }
}

DefaultProperties
{

}
