package ppf.base.resources
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;
	
	public class LocaleManager extends EventDispatcher
	{
		public function LocaleManager()
		{
		}
		
		public static function getInstance():LocaleManager
		{
			if (_intance == null)
				_intance = new LocaleManager();
			return _intance;
		}
		
		private var _locale:String = null;
		public function load(locale:String,resources:Array):void
		{
			_locale = locale;
			loaderCnt = 0;
			for each(var resource:String in resources)
			{
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE,onComplete,false,0,true);
				loader.addEventListener(IOErrorEvent.IO_ERROR,onError,false,0,true);
				loader.load(new URLRequest("locale\\"+locale + "\\"+resource + ".xml"));
				loaderDict[loader] = resource; 
				loaderCnt++;
			}
		}
		
		public function get locale():String
		{
			return _locale;
		}
		
		private function onComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			makeResourceBundle(loaderDict[loader] as String,loader.data as String);
			
			loaderCnt --;
			if(loaderCnt == 0)
				this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onError(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			throw new Error("the locale file " +loaderDict[loader] + " loaded failed!");
		}
		
		private function makeResourceBundle(bundleName:String,xmlStr:String):void
		{
			var dict:Dictionary = new Dictionary();
			dictRes[bundleName] = dict;
			var xml:XML = new XML(xmlStr);
			var list:XMLList = xml.entry;
			for each(var entry:XML in list)
				dict[String(entry.@key)] = String(entry.text());
		}
		
		public function getString(bundleName:String,key:String,params:Array = null):String
		{
			var dict:Dictionary = dictRes[bundleName] as Dictionary;
			if(null == dict)
				return key;
			var str:String = dict[key] as String;
			if(str == null || str == "")
				return key;
			if(params == null || params.length == 0)
				return str;
			
			var array:Array = params.concat();
			array.unshift(str);
			return StringUtil.substitute.apply(null,array);
		}
		
		private var dictRes:Dictionary = new Dictionary(false);
		private var loaderDict:Dictionary = new Dictionary(true);
		private var loaderCnt:int = 0;
		private static var _intance:LocaleManager;
	}
}