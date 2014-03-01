// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_GhastlyVision extends SequenceAction;

var PR0PlayerController PlayerPawn;

event Activated()
{
	local Camera MainCamera;

	`log("PLAYER PAWN"$PlayerPawn);
	MainCamera = PlayerPawn.PlayerCamera;
	`log("CAMERA "$PlayerPawn.PlayerCamera);

	MainCamera.SetDesiredColorScale(Vect(0,0,255), 1.0f);
	MainCamera.bEnableColorScaleInterp = true;
}

defaultproperties
{
	ObjName="SeqAct_GhastlyVision"
	ObjCategory="PR0"
	VariableLinks(0) = (ExpectedType=class'SeqVar_Object', LinkDesc = "Player", bWriteable = True, PropertyName=PlayerPawn)
}
