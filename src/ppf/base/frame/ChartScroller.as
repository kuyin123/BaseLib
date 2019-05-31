package ppf.base.frame
{
	import ppf.base.frame.CmdEvent;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Scroller;
	
	public class ChartScroller extends Scroller implements IChartView
	{
		public function ChartScroller()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,this.onCreateComplete);
		}
		
		public function dispose():void
		{
			// 释放与chartProvider的关联，同时释放相关的监听
			chartProvider = null;
		}
		
		public function get isActiveView():Boolean
		{
			return _isActiveView;
		}
		
		/**
		 * 是否是激活的视图 true：激活的视图 false 未激活的视图 
		 * @return 
		 * 
		 */		
		public function set isActiveView(value:Boolean):void
		{
			_isActiveView = value;
		}
		
		public function get cmdManager():ICommandManager
		{
			return  CommandManager.getInstance();
		}
		
		public function set chartProvider(value:IChartProvider):void
		{
			if (null != _chartProvider)
			{// 去除原有的监听
				_chartProvider.removeEventListener(ChartEvent.ADD_ITEM,onItemChangedHandle);
				_chartProvider.removeEventListener(ChartEvent.DEL_ITEM,onItemChangedHandle);
				_chartProvider.removeEventListener(ChartEvent.ITEMS_CHANGED,onItemChangedHandle);
				_chartProvider.removeEventListener(ChartEvent.DATA_CHANGED,onDataChangedHander);
			}
			
			_chartProvider = value;
			if (isCreateCompleted)
			{
				if (null != value)
				{// 初始化完毕之后才注册监听
					_chartProvider.addEventListener(ChartEvent.ADD_ITEM,onItemChangedHandle,false,0,true);
					_chartProvider.addEventListener(ChartEvent.DEL_ITEM,onItemChangedHandle,false,0,true);
					_chartProvider.addEventListener(ChartEvent.ITEMS_CHANGED,onItemChangedHandle,false,0,true);
					_chartProvider.addEventListener(ChartEvent.DATA_CHANGED,onDataChangedHander,false,1,true);
					onInitUpdate();
				}
			}
		}
		
		public function get chartProvider():IChartProvider
		{
			return _chartProvider;
		}
		
		/**
		 * 视图在此进行初始化 
		 */
		protected function onInitUpdate():void
		{
		}
		
		
		/**
		 * 视图点击处理函数
		 * @param cmdID 工具条/菜单字符
		 * @return true：成功 false 失败
		 *
		 */		 
		public function onCommand(cmdEvt:CmdEvent):Boolean
		{
			if (null != chartProvider && chartProvider.onCommand(cmdEvt))
				return true;
			return false;
		}
		
		/**
		 * 视图更新处理函数
		 * @param cmdID 工具条/菜单字符
		 * @return true：成功 false 失败
		 *
		 */		 	
		public function onUpdateCmdUI(cmdID:String,item:CommandItem):Boolean
		{
			if (null != chartProvider && chartProvider.onUpdateCmdUI(cmdID, item))
				return true;
			
			return false;	
		}
		
		/**
		 * item的数据 发生变化
		 * @param item
		 */
		protected function onDataChanged(item:ChartItem):void
		{
		}
		
		/**
		 * provide 中的 Item 发生改变
		 * @param event
		 */		
		protected function onItemChanged(type:String, item:ChartItem):void
		{
			// 默认实现为 onUpdateView
			onUpdateView (item);
		}
		
		/**
		 *更新显示  
		 * @param e
		 */
		protected function onUpdateView(item:ChartItem):void
		{
		}
		
		
		public function get isCreateCompleted():Boolean
		{
			return _isCreateCompleted;
		}
		
		
		/*********************************************************************/
		/*** private            										******/
		/*********************************************************************/
		
		protected  function onCreateComplete(e:FlexEvent):void
		{
			_isCreateCompleted = true;
			// 重新设置 chartProvider，进行初始化调用
			chartProvider = _chartProvider;
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,true,0,true);
		}
		
		/**
		 * 点击视图，使视图处于激活状态
		 * @param e
		 *
		 */		
		private function onMouseDown(event:MouseEvent):void
		{
			if (!isActiveView)
			{
				isActiveView = true;
				//发送视图激活事件
				var evt:ChartEvent = new ChartEvent(ChartEvent.ACTIVE_VIEW_CHANGED,true);
				dispatchEvent(evt);
			}
		}
		
		/**
		 * item 中的数据发生变化
		 * @param event
		 */
		private function onDataChangedHander(event:ChartEvent):void
		{
			if (null == this._chartProvider)
				return;		// 刚删掉的关联，有时还会响应监听
			onDataChanged(event.ids as ChartItem);
		}
		
		private function onItemChangedHandle(event:ChartEvent):void
		{
			if (null == this._chartProvider)
				return;		// 刚删掉的关联，有时还会响应监听
			onItemChanged (event.type, event.ids as ChartItem);
		}
		
		
		/**
		 * 是否是激活的视图 true：激活的视图 false 未激活的视图 
		 */		
		private var _isActiveView:Boolean = false;
		
		private var _chartProvider:IChartProvider;
		
		private var _isCreateCompleted:Boolean = false;
	}
}