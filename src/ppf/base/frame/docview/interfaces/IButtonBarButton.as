package ppf.base.frame.docview.interfaces
{
	import spark.components.IItemRenderer;

	public interface IButtonBarButton extends IItemRenderer
	{
		function get toggle():Boolean;
		function set toggle(value:Boolean):void
			
		function get icon():Class;
		function set icon(val:Class):void;
		
		function get iconClick():Class;
		function set iconClick(val:Class):void;
		
		function get iconHover():Class;
		function set iconHover(val:Class):void;
		
		function get iconDisable():Class;
		function set iconDisable(val:Class):void;
		
//		function set isIconOnly(val:Boolean):void;
	}
}