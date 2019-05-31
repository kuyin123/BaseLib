package ppf.base.frame
{
	import ppf.base.frame.CmdEvent;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.DataDrawer;
	import ppf.base.log.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.messaging.messages.ErrorMessage;
	import ppf.base.object.ColorItem;
	
	public class ChartProvider extends EventDispatcher implements IChartProvider
	{
		public function onCommand(cmdEvt:CmdEvent):Boolean
		{
			return false;
		}
		
		public function onUpdateCmdUI(cmdID:String,item:CommandItem):Boolean
		{
			return false;
		}

		public function setOpPoint(type:String, p:Point, index:int):void
		{
			_paramsDict[type+"OpPoint"] = { pos:p, index:index };
			disEvent(ChartEvent.POINT_CHANGED, type);
		}
		
		public  function getOpPoint(type:String):Point
		{
			var o:Object = _paramsDict[type+"OpPoint"];
			if (o)
				return o.pos;
			else
				return null;
		}
				
		public function getOpIndex(type:String):int
		{
			var o:Object = _paramsDict[type+"OpPoint"];
			if (o)
				return o.index;
			else
				return -1;
		}
		
		public function get tipClassPath():String
		{
			return _tipClassPath;
		}

		public function set tipClassPath(value:String):void
		{
			_tipClassPath = value;
		}

		public function set beginTime(value:Date):void
		{
			_beginTime = value;
		}
		public function get beginTime():Date
		{
			return _beginTime;
		}
		
		public function get endTime():Date
		{
			return _endTime;
		}
		public function set endTime(value:Date):void
		{
			_endTime = value;
		}
		
		/**
		 * 顶部文本 
		 */		
		[Bindable]
		public function set topText(value:String):void
		{
			_topText = value;
		}
		public function get topText():String
		{
			return _topText;
		}
		
		public function initUpdate (args:Array):void
		{
			
		}
		/**
		 *  
		 * @param info
		 * 
		 */		
		public function addItem(chartItem:ChartItem):void
		{
			if (null == chartItem)
			{
				Logger.debug("ChartProvider2::createChartItem(item) is null, you need do something");
				return;
			}
			chartItem.drawerColor = getColor();
			
			_arrayColl.addItem(chartItem);
			this.selectedItem = chartItem;
			meragrRange(chartItem);

			// 发送事件
			disEvent(ChartEvent.ADD_ITEM, chartItem);
			disItemsChangedEvent(ChartEvent.ADD_ITEM, chartItem);
			// disDataChangedEvent();
		}
		
		/**
		 * 删除 FXChartItem
		 * @param item FXChartItem
		 * 
		 */		
		public function delItem(item:ChartItem):void
		{
			//删除时改变颜色使用状态
			setColorUseStatu(item.drawerColor);
			
			_arrayColl.removeItemAt(_arrayColl.getItemIndex(item));
			
			//当删除测点时需要重新计算合并单位的量程 
			updateRange();
			
			var len:Number = length;
			var index:int = (_selectedIndex<length?_selectedIndex:length-1);
			if (index != -1)
			{
				selectedItem = _arrayColl.getItemAt(index) as ChartItem;
			}
			else
			{
				selectedItem=null;
			}
			
			// 发送删除事件
			disEvent(ChartEvent.DEL_ITEM, item);
			disItemsChangedEvent(ChartEvent.DEL_ITEM, item);
		}
		
		// 如果要使用树节点拖动到框架的功能，此方法必须被覆盖
		public function createItemFromTreeNode(item:Object):ChartItem
		{
				throw new Error("createItemFromTreeNode not impl !");
				return null;
		}			
		
		/**
		 * 发送刷新事件 
		 * @param item
		 * @param ids 附加参数
		 */
		public function disDataChangedEvent(item:ChartItem = null, data:Object=null):void
		{
			var event:ChartEvent = new ChartEvent(ChartEvent.DATA_CHANGED, item);
			event.data = data;
			this.dispatchEvent(event);
		}
		
		public function disItemsChangedEvent(subType:String=ChartEvent.ITEMS_CHANGED, item:Object = null):void
		{
			var event:ChartEvent = new ChartEvent(ChartEvent.ITEMS_CHANGED, item);
			event.subType = subType;
			this.dispatchEvent(event);
		}
		
		
		/**
		 * 请求数据，具体实现由继承类实现
		 * @param item
		 * @param ids 附加参数
		 * @param isAllChange 是否作用于所有
		 */
		public function updateData(item:ChartItem = null, ids:Object = null , isAllChange:Boolean=false):void
		{
		}
		
//		/**
//		 * 更新Drawer
//		 * @param item
//		 * 
//		 */		
//		public function onUpdateDrawer(item:ChartItem):void
//		{
//			updateRange();//必须先改变单位的量程的数组
//			
//			onUpdateEvent(item);
//		}
		
		/**
		 * 设置是否显示 
		 * @param item
		 * 
		 */		
		public function onActiveDrawer(item:ChartItem):void
		{
			/*if (item.visible)
				disEvent(ChartEvent.ADD_ITEM,item);
			else
				disEvent(ChartEvent.DEL_ITEM,item);
			disDataChangedEvent();*/
		}
		
		/**
		 * datagrid中被选中的项 
		 * @return 
		 * 
		 */		
		public function get selectedItem():ChartItem
		{
			return _selectedItem;
		}
		
		/**
		 * datagrid中上次被选中的项 
		 * @return 
		 * 
		 */		
		public function get lastSelectedItem():ChartItem
		{
			return _lastSelectedItem;
		}
		
		/**
		 * @private
		 */
		public function set selectedItem(value:ChartItem):void
		{
			if (_selectedItem != value)
			{
				if (null == value)
					_selectedIndex = -1;
				else
				{
					_lastSelectedItem = value;//记录上一次选项
					_selectedIndex = arrayColl.getItemIndex(value);
				}
					
				
				_selectedItem = value;
				disEvent(ChartEvent.SEL_CHANGED);
			}
		}
		
		/**
		 *  被选中的索引
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		/**
		 * @private
		 */
		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex != value)
			{
				_selectedIndex = value;
				if (value != -1)
				{
					if (length > 0)
						_selectedItem = _arrayColl.getItemAt(value) as ChartItem;
					else
					{
						Logger.debug("ChartProvider2::set selectedIndex length=0");
					}
				}
				else
				{
					_selectedItem = null;
				}
			}
		}
		
		/**
		 * 数据源 
		 * @return 
		 * 
		 */	
		public function get arrayColl():ArrayList
		{
			return _arrayColl;
		}
		
		public function set arrayColl(value:ArrayList):void
		{
			_arrayColl = value;
		}
		
		public function get length():int
		{
			if (null != _arrayColl)
				return _arrayColl.length;
			return 0;
		}
		
		/**
		 * 获取有效的数据行数组
		 * @return
		 *
		 */		
		public function get validArrayColl():Array
		{
			var returnArr:Array = _arrayColl.source.filter(validFilte);
			return returnArr;
		}
		
		
		/**
		 *  总的颜色数据 
		 * @return 
		 * 
		 */		
		public function get colorArrayColl():ArrayCollection
		{
			return _colorArrayColl;
		}
		
		public function set colorArrayColl(value:ArrayCollection):void
		{
			_colorArrayColl = value;
		}
		
		/**
		 * 获取单位量程范围 
		 * @return 
		 * 
		 */		
		public function get rangeArr():Array
		{
			return _rangeArr;
		}
		
		/**
		 * 释放资源 
		 */	
		public function dispose():void
		{
			_selectedItem = null;
		}
		
		public function ChartProvider(target:IEventDispatcher=null)
		{
			super(target);
			//获取颜色数据源
			formatColor();
		}
		
		/**
		 * 当删除测点、修改测点单位时时需要重新计算合并单位的量程 
		 * 
		 */		
		protected function updateRange():void
		{
			_rangeArr = [];
			
			for each (var item:ChartItem in _arrayColl)
			{
				meragrRange(item);
			}
		}
		
		/**
		 * 数据源有效地过滤函数
		 * @param item
		 * @param index
		 * @param array
		 * @return 
		 * 
		 */		
		private function validFilte(item:*, index:int, array:Array):Boolean
		{
			if (item.visible)
				return true;
			return false;
		}
		
		/**
		 * 获取颜色
		 * @return  颜色
		 * 
		 */		
		protected function getColor():uint
		{
			//设置颜色使用状态
			_colorArrayColl.refresh();
			var colorItem:ColorItem = _colorArrayColl.getItemAt(0) as ColorItem;
			colorItem.used = true;
			return colorItem.color;
		}
		
		/**
		 * 改变颜色数据的使用状态
		 * @param curColor 要改变状态的颜色
		 * 
		 */		
		private function setColorUseStatu(curColor:uint):void
		{
			for each (var colorItem:ColorItem in _colorArrayColl.source)
			{
				if (colorItem.color == curColor)
					colorItem.used = !colorItem.used;
			}
		}
		
		/**
		 * 格式化颜色数据源 
		 * 
		 */		
		private function formatColor():void
		{
			var colorArr:Array = ChartColor.getColors();
			
			if (null == _colorArrayColl)
				_colorArrayColl = new ArrayCollection;
			
			var item:ColorItem;
			for each (var color:uint in colorArr)
			{
				item = new ColorItem;
				item.used = false;
				item.color = color;
				
				_colorArrayColl.addItem(item);
			}
			_colorArrayColl.filterFunction = colorFilter;
		}
		
		/**
		 * 颜色数据的过滤函数 
		 * @param item
		 * @return 
		 * 
		 */		
		private function colorFilter(item:ColorItem):Boolean
		{
			if (item.used)
				return false;
			return true;
		}
		
		/**
		 * 合并当前单位量程
		 * @param chartItem
		 * 
		 */		
		protected function meragrRange(chartItem:ChartItem):void
		{
			for each (var item:Object in _rangeArr)
			{
				if (item.unit == chartItem.unitName)
				{
					item.min = Math.min(item.min,chartItem.rangeMin);
					item.max = Math.max(item.max,chartItem.rangeMax);
					return;
				}
			}
			
			var obj:Object = {};
			obj.min = chartItem.rangeMin
			obj.max = chartItem.rangeMax;
			obj.unit = chartItem.unitName;
			_rangeArr.push(obj);
		}
		
		/**
		 * 统一发送ChartEvent
		 * @param type 事件的类型
		 */
		protected function disEvent(type:String, item:Object=null):void
		{
			var event:ChartEvent = new ChartEvent(type, item);
			this.dispatchEvent(event);
		}
		
		/**
		 * 数据源
		 */		
		private var _arrayColl:ArrayList = new ArrayList;
		
		/**
		 *  总的颜色数据
		 */		
		private var _colorArrayColl:ArrayCollection;
		
		/**
		 *  被选中的项 
		 */		
		private var _selectedItem:ChartItem = null;
		
		/**
		 *  上一次被选中的项 
		 */		
		private var _lastSelectedItem:ChartItem = null;
		/**
		 * 被选中的索引
		 */		
		private var _selectedIndex:int = -1;
		
		/**
		 * 单位量程范围 
		 */		
		private var _rangeArr:Array=[];
		
		//顶部文本
		private var _topText:String;
		
		private var _beginTime:Date;
		private var _endTime:Date;
		
		private var _tipClassPath:String;
		
		private var _paramsDict:Dictionary = new Dictionary(true);
	}
}