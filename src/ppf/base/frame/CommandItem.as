package ppf.base.frame
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * cmdID:	规范为大写！！两个单词之间必须加入下划线区分！！！<br/>
	 * label: 提示<br/>
	 * icon：图标<br/>
	 * toggledIcon: 是否有切换状态true：有 false：无<br/>
	 * iconToggle：切换状态图标  设置toggledIcon=true时使用此图标<br/>
	 * labelToggle:切换状态提示  设置toggledIcon=true时使用此提示<br/>
	 * enableType：使用范围 global：全局可用 part：全局不可用，单独界面时使用system:系统级别不需要进行权限判断<br/>
	 * actionType：component：组件模块，需要指定classPath和viewType 字段(*Instance是单例)<br/>
	 * 			   cmd：函数命令模块 使用callBack<br/>
	 * classPath：调用模块的路径 !!（注意：需要到引入反射路径 或者 增加编译参数-includes）<br/>
	 * viewType: 显示的方式 Window：弹出式窗口 tab：tab页面<br/>
	 * callBack：function：静态回调函数 <br/>
	 * 	 		 string：右键时调用类public函数,需要设置函数调用类和参数setArguments(classObj:Object,...args) <br/>
	 * cmdCallBack：function：静态回调函数 <br/>
	 * 	 		 string：右键时调用类public函数,需要设置函数调用类和参数setArguments(classObj:Object,...args) <br/>
	 * type:类型 separator：分隔符<br/>
	 * actionID:权限值enableType=global时可用<br/>
	 * actionTooggleID:权限值enableType=global时可用，切换状态图标  设置toggledIcon=true时使用<br/>
	 * eventStr:cmdOP的操作事件定义<br/>
	 * @author wangke
	 * 
	 */	
	public final class CommandItem extends EventDispatcher
	{
		/**
		 *  
		 */		
		public var cmdID:String = "";
		/**
		 * 提示
		 */		
		public var label:String = "";
		/**
		 * 图标 
		 */		
		public var icon:String = "";
		public var iconMini:String = "";
		public var iconHover:String = "";
		public var iconClick:String = "";
		public var iconEnable:String = "";
		/**
		 * 可用 
		 */		
		public var enabled:Boolean = true;
		 
		/**
		 * 使用范围
		 * <br/>CommandConst.ENABLETYPE_GLOBAL  全局可用
		 * <br/>CommandConst.ENABLETYPE_PART 全局不可用，单独界面时使用
		 * <br/>CommandConst.ENABLETYPE_SYSTEM 系统级别不需要进行权限判断
		 */		
		public var enableType:String = "";
		
		public var toggled:Boolean = false;
		/**
		 * 切换图标标志位 
		 * true:使用 labelToggle、iconToggle、actionTooggleID
		 * false:使用 label、icon 、actionID
		 */		
		public var toggledIcon:Boolean = false;
		/**
		 * 切换使用的提示
		 */		
		public var labelToggle:String = "";
		/**
		 * 切换使用的图标
		 */		
		public var iconToggle:String = "";
		/**
		 * 调用模块的路径 
		 */		
		public var actionType:String = "";
		/**
		 * 调用模块的路径 
		 */		
		public var classPath:String = "";
		/**
		 * 显示的方式 
		 * Window：弹出式窗口 
		 * tab：tab页面 
		 * PanelInstance：
		 */		
		public var viewType:String = "";
		/**
		 *  单独处理的回调函数
		 */		
		public var callBack:String = "";
		/**
		 *  直接调用Application的cmdCallBack回调函数
		 */		
		public var cmdCallBack:String = "";
		/**
		 * separator：分隔符 
		 */		
		public var type:String = "";
		/**
		 * cmdOP的权限使用
		 */		
		public var actionID:int = int.MIN_VALUE;
		/**
		 * cmdOP的权限使用
		 */		
		public var actionTooggleID:int = int.MIN_VALUE;
		
		public var children:*;
		/**
		 * cmdOP使用
		 */		
		public var eventStr:String = "";
		/**
		 *父类菜单id 
		 */		
		public var parentMenuID = "";
		public var value:Object;
		
		public function clone():CommandItem
		{
			var item:CommandItem=new CommandItem;
			item.cmdID=cmdID;
			item.actionTooggleID=actionTooggleID;
			item.actionType=actionType;
			item.callBack=callBack;
			item.classPath=classPath;
			item.cmdCallBack=cmdCallBack;
			item.actionID=actionID;
			item.enabled=enabled;
			item.enableType=enableType;
			item.eventStr=eventStr;
			item.icon=icon;
			item.iconMini=iconMini;
			item.iconClick=iconClick;
			item.iconHover=iconHover;
			item.iconEnable=iconEnable;
			item.iconToggle=iconToggle;
			item.label=label;
			item.labelToggle=labelToggle;
			item.toggled=toggled;
			item.toggledIcon=toggledIcon;
			item.type=type;
			item.value=value;
			item.viewType=viewType;
			item.parentMenuID = parentMenuID;
			if(children)
			{   //children需要特别处理
				var newChildren:Array = new Array;;
				for each(var cmdItem:CommandItem in children)
					newChildren.push(cmdItem.clone());
				item.children=newChildren;
			}
			return item;
		}
		
				
		override public function toString():String
		{
			return "cmdID:"+cmdID+",enabled:"+enabled.toString();
		}
		
		public function CommandItem(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}