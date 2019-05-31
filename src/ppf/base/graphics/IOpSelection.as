package ppf.base.graphics
{
	
	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	/**
	 * 光标查询接口 
	 * @author wangke
	 * 
	 */	
	public interface IOpSelection extends IEventDispatcher
	{
		/**
		 *  获取/设置 所属的Canvas
		 * @return 
		 */
		function get parentCanvas():ChartCanvas;
		function set parentCanvas(value:ChartCanvas):void;

		/**
		 *  设置光标的当前位置（数据坐标）
		 * @param posX x坐标，NaN则清除光标
		 * @param posY y坐标，设置为NaN时被忽略
		 * @param needEvent 是否发送事件
		 * @return 
		 */
		function setSelPos(posX:Number,posY:Number=NaN,needEvent:Boolean=true):Number;

		/**
		 * 根据数据索引值，直接设置光标位置 
		 * @param index 基于0的索引值
		 * @param needEvent 是否发送事件
		 * @return 如果返回-1，表示未选中
		 */
		function setByIndex (index:Number, needEvent:Boolean=true):Number;
		
		/**
		 * 获取光标的设置值，或认为是鼠标点击时的位置
		 * @return 
		 */
		function get settingPoint():Point;
		/**
		 * 获取光标选中的位置（经过校正后的实际位置） 
		 * @param value
		 */
		function get curPoint():Point;
		function get selPosX():Number;
		function get selIndex():int;

		/**
		 * 获取光标当前的像素位置 
		 * @return 
		 */
		function get localPoint():Point;
		/**
		 * 是否允许键盘操作
		 * @param has
		 */
		function set useKeyboard(has:Boolean):void;
		
		// function get currentDrawer():DataDrawer;
		
		/**
		 * 是否总是显示标注，默认为鼠标按下时才显示标注
		 * @return 
		 */
		function get alwaysShowLabel():Boolean;
		function set alwaysShowLabel(value:Boolean):void;
		
		/**
		 *  设置、获取 TIP所显示文本的回调函数
		 *  原型：Function(drawer:DataDrawer, pos:Point, precision:Number):String
		 * @return 
		 */
		function get onNeedText():Function;
		function set onNeedText(value:Function):void;
	}
} 