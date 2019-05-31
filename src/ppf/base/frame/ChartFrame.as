package ppf.base.frame
{
	import ppf.base.log.Logger;
	import ppf.base.frame.docview.mx.views.components.DockViewExtend;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;

	public class ChartFrame extends DockViewExtend	//  implements IChartFrame
	{
		/**
		 * 添加View视图 
		 * @param view
		 * 
		 */		
		public function addView(view:IChartView):void
		{
			this.implObject.addView(view);
			
			if (null == view.chartProvider)
				view.chartProvider = chartProvider;
		}

		public function clearViews():void
		{
			for each (var v:IChartView in implObject.viewList)
				v.chartProvider = null;
			this.implObject.clearViews();
		}
		
		public function delView(view:IChartView):Boolean
		{
			view.chartProvider = null;
			return this.implObject.delView(view);
		}		
		
		/**
		 * 数据提供者	
		 */
		public function get chartProvider():IChartProvider
		{
			return _chartProvider;
		}
		
		/** 设置数据支持对象
		 */
		public function set chartProvider(value:IChartProvider):void
		{
			_chartProvider = value;
			BindingUtils.bindProperty(this,"topLabel",chartProvider,"topText");
			
			if (isCreateCompleted)
				onInitUpdate();
		}
		
		/**
		 * 添加树节点到当前数据提供者
		 * @param item 树节点对象
		 * @return 
		 * 
		 */
		private function addTreeItem(item:Object):Boolean
		{
			if (null != chartProvider)
			{
				var chartitem:ChartItem = chartProvider.createItemFromTreeNode (item);
				if (null == chartitem)
				{
					Logger.debug("ChartFrame2::addItem createItemFromTreeNode return null");
					return false;
				}
				
				chartProvider.addItem(chartitem);
				if (null == chartProvider.selectedItem && chartProvider.length > 0)
					chartProvider.selectedItem = chartProvider.validArrayColl[0];
				updateAxisY();
			}
			else
			{
				Logger.debug("ChartFrame2::addItem chartProvider is null");
				return false;
			}
			
			return true;
		}
		
		/**
		 * 释放资源 
		 */		
		override public function dispose():void
		{ 
			super.dispose();
			
			_implObject.dispose();
			
			if (null != _chartProvider)
				_chartProvider.dispose();
			
			_implObject = null;
			_chartProvider = null;
		}
		
		public function ChartFrame()
		{
			super();
		}
		
		/**
		 * 框架列表的右键菜单 
		 */		
		protected var listRightMenuData:Array = [];
		protected function onDelItem(item:ChartItem):void
		{
			chartProvider.delItem(item);
			var index:Number = chartProvider.selectedIndex;
			var len:Number = chartProvider.length;
			index = (index<len?index:len-1);
			if (index != -1)
			{
				chartProvider.selectedItem = chartProvider.arrayColl[index];
			}
		}
		
		/**
		 * @private 
		 * @param event
		 */		
		private var isCreateCompleted:Boolean = false;
		override protected function _onCreationComplete(event:FlexEvent):void
		{
			super._onCreationComplete(event);
			
			if (null != chartProvider)
				onInitUpdate ();
			isCreateCompleted = true;
		}
		
		/**
		 * 拖动进入的对象的处理 
		 * @param item
		 * 
		 */		
		override protected function onDropItem(item:Object):Boolean
		{
			 addTreeItem(item);
			return true;
		}
		
		/**
		 * @private 
		 * 
		 */		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			this.percentHeight = 100;
			this.percentWidth = 100;
		}
		/**
		 * 创建完成之后初始化 
		 */		
		protected function onInitUpdate():void
		{
			
		}
		
//		/**
//		 * 框架的工具条/右键处理函数
//		 * @param cmdID
//		 *
//		 */
//		protected function menuClicked(cmdID:String):Boolean
//		{
//			return false;
//		}
		
//		/**
//		 * 框架的工具条/右键更新函数，不写default
//		 * @param cmdID
//		 * @param item
//		 *
//		 */		
//		protected function updateMenuImpl(cmdID:String,item:Object):Boolean
//		{
//			return false;
//		}
		
		/**
		 * 刷新Y轴显示
		 * 
		 */		
		protected function updateAxisY():void
		{
			
		}
				
		/**
		 * 数据提供者	
		 */
		private var _chartProvider:IChartProvider;
		
		//当前的子框架下激活的视图
		private var _activeView:IChartView;
	}
}