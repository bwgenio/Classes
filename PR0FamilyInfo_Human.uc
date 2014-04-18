class PR0FamilyInfo_Human extends UTFamilyInfo
    abstract;

defaultproperties
{
    	FamilyID="Human"

	CharacterMesh=SkeletalMesh'PRAsset.EnemyGoblin.GoblinMesh'
	AnimSets(0)=AnimSet'PRAsset.EnemyGoblin.EnemyGoblinAnims'
	PhysAsset=PhysicsAsset'PRAsset.EnemyGoblin.GoblinMesh_Physics'
	
	//AnimTreeTemplate=AnimTree'PRAsset.EnemyGoblin.EnemyAnimTree'
	SoundGroupClass=class'UTPawnSoundGroup_Liandri'
	VoiceClass=class'UTVoice_Robot'

	DefaultMeshScale=1.0
}