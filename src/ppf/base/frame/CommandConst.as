package ppf.base.frame
{
	public class CommandConst
	{
		/**
		 *  component
		 */		
		static public const ACTIONTYPE_COMPONENT:String = "component";
		
		/**
		 * cmd 
		 */		
		static public const ACTIONTYPE_CMD:String = "cmd";
		/**
		 *  global 全局可用
		 */		
		static public const ENABLETYPE_GLOBAL:String = "global";
		
		/**
		 *  part 全局不可用，单独界面时使用
		 */		
		static public const ENABLETYPE_PART:String = "part";
		
		/**
		 *  system 系统级别不需要进行权限判断
		 */		
		static public const ENABLETYPE_SYSTEM:String = "system";
		
		/**
		 *  Panel
		 */		
		static public const VIEWTYPE_PANEL:String = "Panel";
		/**
		 *  PanelInstance
		 */		
		static public const VIEWTYPE_PANELINSTANCE:String = "PanelInstance";
		/**
		 * Tab
		 */		
		static public const VIEWTYPE_TAB:String = "Tab";
		/**
		 * TabInstance
		 */		
		static public const VIEWTYPE_TABINSTANCE:String = "TabInstance";
		/**
		 * TabNavigator
		 */		
		static public const VIEWTYPE_TABNAV:String = "TabNavigator";
		/**
		 * TabNavigatorInstance
		 */		
		static public const VIEWTYPE_TABNAVINSTANCE:String = "TabNavigatorInstance";
		
		/**
		 * separator
		 */		
		static public const TYPE_SEPARATOR:String = "separator";
		/**
		 * TabInstance
		 */		
		static public const TYPE_CHECK:String = "check";
		
		
		/**
		 * cmdCallBack
		 */		
		static public const CMD_CALLBACK:String = "cmdCallBack";
		
		public function CommandConst()
		{
			throw new Error("CommandConst类只是一个静态方法类!"); 
		}
	}
}