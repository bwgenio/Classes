// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_StateChange extends SequenceEvent;

defaultproperties
{
	ObjName="State Change"
	ObjCategory="PR0"
	bPlayerOnly=true
	MaxTriggerCount=0
}
