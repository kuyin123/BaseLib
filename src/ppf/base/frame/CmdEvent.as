package ppf.base.frame
{
	import flash.events.Event;
	
	public class CmdEvent
	{
		private var _cmdID:String;
		public var params:Array;
		public function CmdEvent(id:String, ...args)
		{
			_cmdID = id;
			params = args;
		}
		
		public function get cmdID():String
		{
			return _cmdID;
		}
	}
}