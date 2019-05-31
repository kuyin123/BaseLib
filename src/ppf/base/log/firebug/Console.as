package ppf.base.log.firebug
{
	import flash.external.*;
	import flash.system.*;
	import flash.system.Security;

	/**
	 * Console.dump({ name:"debug_demo", author:"kk", date:"2010-10" });<br/>
	 * Console.log("This a flash debug demo!");<br/>
	 * @author wangke
	 * 
	 */	
	public class Console 
	{
		// used by the object dump
		public static var od_count:int = 0;
		public static var tab_string:String = "";

		public function Console(){}	

		/**
		 *	Basic log trace. Multiple arguments can be passed in that will be
		 *	joined into one string with a ' : ' as a separator.
		 */
		public static function log(...args):void
		{
			var logString:String = (args.length > 1) ? args.join(" : ") : args[0];
			Console.send("console.log" , logString);
		}

		/**
		 *	Writes a message to the console with the visual "info" icon and
		 *	color coding and a hyperlink to the line where it was called.
		 */
		public static function info(o:*):void
		{
			Console.send("console.info" , o);
		}

		/**
		 *	Writes a message to the console with the visual "error" icon and
		 *	color coding and a hyperlink to the line where it was called.
		 */
		public static function error(o:*):void
		{
			Console.send("console.error" , o);
		}

		/**
		 *	Writes a message to the console with the visual "warning" icon and
		 *	color coding and a hyperlink to the line where it was called.
		 */
		public static function warn(o:*):void
		{
			Console.send("console.warn" , o);
		}

		/**
		 *	Prints an interactive listing of all properties of the object.
		 */
		public static function dump(o:*):void
		{
			Console.send("console.dir" , o);
		}

		public static function send(typeString:String , o:*=""):void
		{
			// make ExternalInterface call if the flash is in a browser
			switch (Capabilities.playerType)
			{
	            case "PlugIn":
	            case "ActiveX":

	                try {
						ExternalInterface.call(typeString, o);
					} catch (e:Error) {}

	                break;
				default :
					if(typeString == "console.dir") Console.objectDump(o);
					else trace(o);
	        }
		}

		/**
		 *	properties of an object will be traced out recursively
		 */
		public static function objectDump(o:*):void
		{
			var obj:Object = o as Object;
			for (var prop:String in obj)
			{
				var tab:String = Console.getTabString();
				trace(tab+"   • "+prop+" : "+obj[prop]);

				if(o[prop] is Object) {
					od_count++;
					Console.objectDump(obj[prop]);
					od_count--;
				}
			}
		}

		public static function getTabString():String
		{
			var str:String = "";
			for (var i:int = 0; i<od_count; i++) str += "\t";

			return str
		}
	}
}