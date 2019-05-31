package ppf.base.frame.docview.interfaces
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.core.IVisualElement;
	
	public interface ITabBar extends IVisualElement
	{
		function get title():String;
		
		function set title(value:String):void;
		
		function get icon():Class;
		
		function set icon(value:Class):void;
	}
}