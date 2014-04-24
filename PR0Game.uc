class PR0Game extends UTGame;

var PR0PlayerController currentPlayer;

/*function RestartPlayer(Controller aPlayer)
{
	super.RestartPlayer(aPlayer);
	`Log("Player restarted");
	currentPlayer = PR0PlayerController(aPlayer);
	currentPlayer.ghostForm();
}*/

DefaultProperties
{
	DefaultPawnClass = class'PR0.PR0PlayerPawn'
	PlayerControllerClass = class'PR0.PR0PlayerController'
	PlayerReplicationInfoClass=Class'PR0.PR0PlayerReplicationInfo'
	HUDType=class'PR0.PR0HUDGfx'
	bUseClassicHUD = true
	bDelayedStart = false
	bRestartLevel = false
	MessageClass = none
	GameMessageClass = none
	DeathMessageClass = none
	VictoryMessageClass = none
}
