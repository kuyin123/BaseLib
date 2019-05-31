package ppf.base.frame
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.messaging.AbstractConsumer;
	
	import ppf.base.object.VOObject;
	
	public class ChartItem extends VOObject implements IDispose
	{
		/**
		 * 显示提示时的精度 
		 */		
		public var precision:Number=NaN;
		
		/**
		 * 名称 
		 */		
		public var name:String;
		
		/**
		 * 对象是否可见，true 可见， false 不可见
		 */		
		public var visible:Boolean = true;
		
		/**
		 * drawer颜色 
		 */		
		public var drawerColor:Number = 0x000000;
		
		/**
		 * 单位 
		 */		
		public var unitName:String = "";
		/**
		 * 量程最大 
		 */		
		public var rangeMax:Number = 1000;
		/**
		 * 量程最小
		 */	
		public var rangeMin:Number = 0;
		/**
		 * 点数据 
		 * @param key 类型
		 * @return 
		 * 
		 */		
		private var _currentDataSource:String = "Runout数据";//默认为原始数据
		/**
		 * 数据密度
		 */
		public var dataDensity:int;
		
		/**
		 * 自定义参数包
		 */
		public var param:Object = new Object;
		
		/**
		 * 扩展参数
		 */
		public var objExt:Object = new Object;
		
		
		/**
		 *临时基准波形
		 */		
		public var interim_basewave :Array 

		
		public function getValue(key:Object):Object
		{
			return _pointDict[key];
		}
		public function setValue(key:Object,value:Object):void
		{
			_pointDict[key] = value;
		}
		
		private var _pointDict:Dictionary = new Dictionary(true);
		/**
		*  当前数据来源 
		 * 1runout数据
		 * 2原始数据
		 * 3临时runout数据
		 */		
		public  function set currentDataSource(str:String):void
		{
			_currentDataSource = str;
		}
		
		/**
		 *当前数据来源 
		 * 1runout数据
		 * 2原始数据
		 * 3临时runout数据
		 */		
		public  function get currentDataSource():String
		{
			return _currentDataSource ;
		}

		/**
		 * 释放资源 
		 */	
		public function dispose():void
		{
		}
		public function ChartItem(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}