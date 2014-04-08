class PR0FamilyInfo_Human extends UTFamilyInfo
    abstract;

defaultproperties
{
    	FamilyID="Human"

	CharacterMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	//PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	
	AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	SoundGroupClass=class'UTPawnSoundGroup_Liandri'
	VoiceClass=class'UTVoice_Robot'

	DefaultMeshScale=1.0
}