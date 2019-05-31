package ppf.base.math
{
	public interface IHashMap
	{
		function clear():void;  
		function containsKey(key:Object):Boolean;  
		function containsValue(value:Object):Boolean;  
		function get(key:Object):Object;  
		function put(key:Object,value:Object):Object;  
		function remove(key:Object):Object;  
		function putAll(map:IHashMap):void;  
		function size():uint;  
		function isEmpty():Boolean;  
		function values():Array;  
		function keys():Array;  
	}
}