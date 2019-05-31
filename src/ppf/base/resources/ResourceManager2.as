package ppf.base.resources
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.resources.Locale;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import ppf.base.frame.CmdEvent;
	import ppf.base.frame.CommandItem;
	import ppf.base.graphics.ArrowLable;
	
	public class ResourceManager2 extends EventDispatcher implements IResourceManager
	{
		public function ResourceManager2()
		{
			super();
		}
		
		/**
		 * 加载cmd的XMl，有可能使用不同文件定义，减少用户一次加载 
		 * @param cmdPath
		 * 
		 */		
		public function loadCMDXml(path:String, ver:String):void
		{
			LoadManager.loadXML(path, ver, onCMDComplete,true);
			var separatorCMD:CommandItem = new CommandItem;
			separatorCMD.type = "separator";
			cmdDict["-"] = separatorCMD;
		}
		
		/**
		 * 根据字符获取cmd 
		 * @param str
		 * @return 
		 * 
		 */		
		public function getResourceItem(str:String):Object
		{
			return cmdDict[str];
		}
		
		/**
		 * 根据字符数据获取cmd数组 
		 * @param arr
		 * @return 
		 * 
		 */		
		public function getResources(arr:Array):Array
		{
			var tmpArr:Array = [];
			var obj:CommandItem;
			for each(var it:Object in arr)
			{
				if (it is String)
				{
					var str:String = it as String;
					obj = cmdDict[str];
					if (null != obj)
						tmpArr.push(obj);
					else
					{
						trace("ResourceManager2::getResources(arr) cmd:"+str+" is not exist");
					}
				}
				else if (it.hasOwnProperty("children"))
				{
					if (it.children is Array && it.hasOwnProperty("label"))
					{
						var popup:Array = getResources(it.children as Array);
						var labelitem:CommandItem = cmdDict[it.label];
						var subMenu:Object = {};
						if (null == labelitem)
						{
							//							subMenu.label = it.label;
							subMenu = it ;
						}
						else
						{
							subMenu = labelitem;
							//							subMenu.label = labelitem.label;
							//							subMenu.icon = labelitem.icon;
						}
						subMenu.children = popup;
						tmpArr.push(subMenu);
					}
					else
					{
						
					}
				}
			}
			return tmpArr;
		}
		
		/**
		 * 根据字符获取cmd的子数组 
		 * @param str
		 * @param children
		 * @return 
		 * 
		 */		
		public function getResourcesChildren(str:String, children:*):Array
		{
			var tmpArr:Array=[];
			var obj:CommandItem = cmdDict[str];
			if (null != obj)
			{
				obj.children = children;
				tmpArr.push(obj);
			}
			else
			{
				trace("ResourceManager2::getResourcesChildren() cmd:"+str+" is not exist");
			}
			return tmpArr;
		}
		
		public function get toClassName():String
		{
			return "com.shengu.managers.ResourceManager2";
		}
		
		protected function get cmdPath():String
		{
			return "";
		}
		protected function onCMDComplete(obj:Object):void
		{
			var xml:XML = XML(obj.asset);
			var xmlList:XMLList = xml.children();
			var cmd:CommandItem;
			var str:String;
			var eventStr:String = obj.asset.@event;
			for each (var item:XML in xmlList)
			{
				cmd = new CommandItem;
				cmd.cmdID = item.@cmdID;
				cmd.label = getLabel(item.@label);//item.@label;
				cmd.icon = item.@icon;
				cmd.iconMini = item.@iconMini;
				cmd.iconClick = item.@iconClick;
				cmd.iconHover = item.@iconHover;
				cmd.iconEnable = item.@iconEnable;
				cmd.enableType = item.@enableType;
				cmd.labelToggle = getLabel(item.@labelToggle);
				cmd.iconToggle = item.@iconToggle;
				cmd.actionType = item.@actionType;
				cmd.classPath = item.@classPath;
				cmd.viewType = item.@viewType;
				cmd.callBack = item.@callBack;
				cmd.cmdCallBack = item.@cmdCallBack;
				cmd.eventStr = item.@eventStr;
				cmd.enabled = Boolean("true" == item.@enabled);
				str = item.@actionID;
				if ("" != str)
					cmd.actionID = int(str);
				str = item.@actionTooggleID;
				if ("" != str)
					cmd.actionTooggleID = int(str);
				cmdDict[cmd.cmdID] = cmd;
			}
			dispatchEvent(new Event(eventStr));
		}
		
		protected function getLabel(resourceName:String):String
		{
			return resourceName;
		}
		
		private var cmdDict:Dictionary = new Dictionary(true);
	}
}