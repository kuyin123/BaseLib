/**
 * Trace: execute trace function in firebug console
 * 
 * Usage: 
 * flash side(in class Main):
 * Trace.bind('main', this); 
 * firebug console:
 * $('flash_object_id').trace('main');
 * 
 */
package ppf.base.log.firebug
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.external.ExternalInterface;	

	/**
	 * Trace.bind('main', this); 
	 * @author wangke
	 * 
	 */	
	public class Trace 
	{
		private static var version:String = "1.0";
		private static var _instance:Trace;
		private var _target:*;
		private var _bind:Dictionary = new Dictionary(true);		
		
		getInstance().addCallBack("trace", getInstance().traceDump);
		
		public static function bind(name:String, target:*):void
		{
			getInstance()._bind[name] = target;
		}		
		
		public function traceDump(...args):String
		{			
			var dump:String = "";
			for (var i:int = 0; i < args.length; i++)
			{
				if (dump) dump += ", ";
				var arg:String = args[i];
				var argArr:Array = arg.split(".");
				var argName:String = argArr[0];
				var argValue:*;
				
				try
				{
					if (_bind.hasOwnProperty(argName))
					{
						argValue = _bind[argName];
					}else
					{
						argValue = getDefinitionByName(argName) as Class;
					}
				}catch (e:Error)
				{						
					dump += e;
				}
				
				try
				{
					if (argValue != null)
					{
						var m:int = 1;
						while (m < argArr.length)
						{
							argValue = argValue[argArr[m]];
							m++;
						}
						dump += objectDump(argValue);
					}					
				}catch (e:Error)
				{
					dump += e;
				}
			}
			if (dump) return dump;
			return null;
		}
		
		private function objectDump(o:*):String
		{
			if ((o is String) || (o is Number) || !(o is Object)) return o;
			var dump:String = "";
			for (var p:String in o)
			{
				if (dump) dump += ", ";
				dump += p + ": " + objectDump(o[p]);
			}
			if (dump)
			{
				dump = o.toString() + " -> {" + dump + "}";
			}else
			{
				dump = o.toString();
			}			
			return dump;
		}
		
		private function addCallBack(func:String, closure:Function):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback(func, closure);
			}
		}
		
		private static function getInstance():Trace
		{
			if (_instance == null) 
			{
				_instance = new Trace();			
			}
			return _instance;
		}
	}	
}