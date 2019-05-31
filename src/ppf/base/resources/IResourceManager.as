package ppf.base.resources
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public interface IResourceManager extends IEventDispatcher
	{
		function loadCMDXml(cmdPath:String, ver:String):void;
		function getResourceItem(str:String):Object;
		function getResources(arr:Array):Array;
		
		function getResourcesChildren(str:String,children:*):Array;
		
		function get toClassName():String;
		
	}
}