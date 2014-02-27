// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_TriggerAlarm extends SequenceEvent;

defaultproperties
{
	ObjName="Trigger an Alarm"
	ObjCategory="PR0"
	bPlayerOnly = true
	MaxTriggerCount=0
}
