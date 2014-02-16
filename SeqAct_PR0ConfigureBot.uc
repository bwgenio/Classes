// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_PR0ConfigureBot extends SequenceAction;

var(Patrol) Actor StartNode;
var(Patrol) Actor EndNode;

defaultproperties
{
	ObjName="Configure a PR0 bot"
	ObjCategory="PR0"
	HandlerName = "PR0ConfigureBot"

	VariableLinks(1) = (ExpectedType=class'SeqVar_Object', LinkDesc="Patrol Starting Point", bWriteable=true, PropertyName=StartNode)
	VariableLinks(2) = (ExpectedType=class'SeqVar_Object', LinkDesc="Patrol Ending Point", bWriteable=true, PropertyName=EndNode)
}
