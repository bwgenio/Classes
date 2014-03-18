class DamagingLight extends SpotLightToggleable

HideCategories(Object, Debug, Advanced, Mobile, Physics, Attachment, Collision);

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	LightComponent.SetEnabled(true);
	//sets the brightness of the light
	LightComponent.SetLightProperties(150.0f);
}

DefaultProperties
{
	
}
