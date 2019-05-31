package ppf.base.graphics
{
	import flash.events.Event;
	
	public class EventMatrixChange extends Event
	{
		public function EventMatrixChange(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public var hasManual:Boolean = false;
	}
}