class PR0FamilyInfo_Ghost extends UTFamilyInfo
    abstract;

defaultproperties
{
    	FamilyID="GHOST"

	CharacterMesh=SkeletalMesh'PRAsset.SkeletalMeshes.PrGhost'
	//AnimSets(0)=AnimSet'PlayerCharacter.Anims.OldMageAnims'
	//PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	SoundGroupClass=class'UTPawnSoundGroup_Liandri'
	VoiceClass=class'UTVoice_Robot'

	DefaultMeshScale=20.0
	BaseTranslationOffset=-50.0

	//HeroLight = new(PR0PlayerPawn)class'PointLightComponent';
	//HeroLight.SetLightProperties(5,LightColor);
	//HeroLight.Radius = 100;
	//CharacterMesh.AttachComponent(HeroLight, 'HatTip');
	//HeroLight.SetEnabled(TRUE);
}