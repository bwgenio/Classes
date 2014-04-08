class PR0FamilyInfo_Ghost extends UTFamilyInfo
    abstract;

defaultproperties
{
    	FamilyID="GHOST"

	CharacterMesh=SkeletalMesh'PlayerCharacter.Mesh.Mage'
	AnimSets(0)=AnimSet'PlayerCharacter.Anims.OldMageAnims'
	//PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	SoundGroupClass=class'UTPawnSoundGroup_Liandri'
	VoiceClass=class'UTVoice_Robot'

	DefaultMeshScale=1.0
	BaseTranslationOffset=-50.0
	LightColor = (R=255,G=255,B=255,A=0)

	//HeroLight = new(PR0PlayerPawn)class'PointLightComponent';
	//HeroLight.SetLightProperties(5,LightColor);
	//HeroLight.Radius = 100;
	//CharacterMesh.AttachComponent(HeroLight, 'HatTip');
	//HeroLight.SetEnabled(TRUE);
}