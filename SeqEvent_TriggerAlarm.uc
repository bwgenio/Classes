// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_TriggerAlarm extends SequenceEvent;

var Actor Alarm;

defaultproperties
{
	ObjName="Trigger an Alarm"
	ObjCategory="PR0"
	bPlayerOnly = true
	MaxTriggerCount=0

	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Closest Alarm to the bot",bWriteable=true,PropertyName=Alarm);
}
