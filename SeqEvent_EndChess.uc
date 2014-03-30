// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_EndChess extends SequenceEvent;

defaultproperties
{
	ObjName="Chess game ending"
	ObjCategory="PR0"
	bPlayerOnly = true
	MaxTriggerCount = 0
}
