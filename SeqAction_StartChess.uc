// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAction_StartChess extends SequenceAction;

var() int Level;

defaultproperties
{
	ObjName="Start Knight's tour minigame"
	ObjCategory="PR0"
	HandlerName = "StartChessGame"
	Level = 0
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int', LinkDesc="Chess Game Level", bWriteable=true, PropertyName=Level)
}
