package ppf.base.frame
{
	import flash.events.Event;
	
	public dynamic class ChartEvent extends Event
	{
		/**
		 * 当容器中添加新对象时触发
		 */		
		public static const ADD_ITEM:String = "add_item";
		/**
		 *  当容器中移除对象时触发
		 */		
		public static const DEL_ITEM:String = "del_item";
		/**
		 *  当容器中添加、删除、或者重置item对象时均会，涵盖ADD_ITEM、DEL_ITEM
		 */		
		public static const ITEMS_CHANGED:String = "items_changed";

		/**
		 * 当ITEM中的数据发生变化时触发
		 */		
		public static const DATA_CHANGED:String = "data_changed";
		
		/**
		 * 当前选中的ITEM发生变化时触发
		 */		
		public static const SEL_CHANGED:String = "sel_changed";
		
		/**
		 * 图谱的光标位置发生变化时触发
		 */
		public static const POINT_CHANGED:String = "point_changed";
		
		/**
		 * 当前激活视图被改变
		 */		
		public static const ACTIVE_VIEW_CHANGED:String = "active_view_changed";
		
		public var subType:Object;
		public var ids:Object;
		public function ChartEvent(type:String, _item:Object = null)
		{
			super(type);
			ids = _item;
		}
	}
}