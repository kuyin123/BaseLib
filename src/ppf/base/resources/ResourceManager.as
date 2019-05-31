package ppf.base.resources
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * 工具条/菜单资源类
	 * cmdID:命令ID
	 * label: 提示
	 * icon：图标
	 * iconToggle：切换状态图标  设置toggled=true时使用此图标
	 * labelToggle:切换状态提示  设置toggled=true时使用此提示
	 * enableType：使用范围 global：全局可用 view：全局不可用，单独界面时使用
	 * 				
	 * actionType：component：组件模块，指定classPath，viewType
	 * 			   cmd：函数命令模块 使用callBack
	 * classPath：调用模块的路径 !!注意：需要到TopMenuBar进行反射路径
	 * viewType: 显示的方式 Window：弹出式窗口 tab：tab页面
	 * callBack：function：静态回调函数 
	 * 			 string：右键时调用类public函数,需要设置函数调用类和参数setArguments(classObj:Object,...args) 
	 * type:类型 separator：分隔符
	 * actionID:权限值enableType=global时可用
	 * 
	 * @author wangke
	 *
	 */	
	public class ResourceManager extends EventDispatcher implements IResourceManager
	{
		public function ResourceManager()
		{
		}
		
		public function loadCMDXml(cmdPath:String, ver:String):void{}
		
		public function getResourceItem(str:String):Object
		{
			var tmpClass:Class = getDefinitionByName(toClassName) as Class;
			return tmpClass[str.toLowerCase()];
		}
		
		/**
		 * 获取工具条/菜单资源
		 * @param arr command列表
		 * @return
		 *
		 */		
		public function getResources(arr:Array):Array
		{
			var tmpArr:Array=[];
			for each(var str:String in arr)
			{
				var tmpClass:Class = getDefinitionByName(toClassName) as Class;
				tmpArr.push(tmpClass[str.toLowerCase()]);
			}
			return tmpArr;
		}
		
		/**
		 * 
		 * @param arr command列表
		 * @return
		 *
		 */
		/**
		 * 获取有children的工具条/菜单资源 
		 * @param arr command列表
		 * @param children command的children列表
		 * @return 
		 * 
		 */		
		public function getResourcesChildren(str:String,children:*):Array
		{
			var tmpArr:Array=[];
			var tmpClass:Class = getDefinitionByName(toClassName) as Class;
			var obj:Object = tmpClass[str.toLowerCase()];
			obj.children = children;
			tmpArr.push(obj);
			return tmpArr;
		}
		
		public function get toClassName():String
		{
			return "com.grusen.managers.ResourceManager";
		}
	}
}