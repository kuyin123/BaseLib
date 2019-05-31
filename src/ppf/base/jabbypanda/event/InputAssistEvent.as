package ppf.base.jabbypanda.event
{
	import flash.events.Event;
	/**
	 * <P>Custom event class.</P>
	 * stores custom data in the <code>data</code> variable.
	 */
	public final class InputAssistEvent extends Event
	{
		public static const CHANGE:String="change";

		public static const VALUE_CHANGE:String="valueChange";

		public function InputAssistEvent(type:String, mydata:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data=mydata;
		}

		public var data:Object;
	}
}