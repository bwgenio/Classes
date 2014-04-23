class PR0FamilyInfo_DarkElf extends UTFamilyInfo
    abstract;

defaultproperties
{
    	FamilyID="DarkElf"

	CharacterMesh=SkeletalMesh'PRAsset.EnemyDarkElf.DarkElf'
	AnimSets(0)=AnimSet'PRAsset.EnemyDarkElf.DarkElfAnims'
	PhysAsset=PhysicsAsset'PRAsset.EnemyDarkElf.DarkElf_Physics'
	
	//AnimTreeTemplate=AnimTree'PRAsset.EnemyGoblin.EnemyAnimTree'
	SoundGroupClass=class'PR0PawnSoundGroup_DarkElf'
	//VoiceClass=class'UTVoice_Robot'

	FamilyEmotes[19] = (CategoryName="AttackA", EmoteTag="AttackA", EmoteAnim="ATTACK", bTopHalfEmote=true)
	DefaultMeshScale=1.0
}