class PR0PlayerInput extends PlayerInput within PR0PlayerController
	config(PR0PlayerInput);

event PlayerInput( float DeltaTime )
{
	// update any other player input info.
	Super.PlayerInput( DeltaTime );
}