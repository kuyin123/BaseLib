package ppf.base.frame
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayList;
	import mx.core.Container;
	import mx.core.IContainer;
	import mx.core.INavigatorContent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.ItemClickEvent;
	import mx.events.MenuEvent;
	import mx.rpc.AsyncToken;
	
	import ppf.base.frame.docview.interfaces.ITabBar;
	import ppf.base.frame.docview.spark.components.containers.Panel;
	import ppf.base.resources.AssetsUtil;
	import ppf.base.resources.IResourceManager;
	
	import spark.components.NavigatorContent;
	
	public class CommandManager extends EventDispatcher implements ICommandManager
	{
//		/**
//		 * 远程调用 
//		 * @return 
//		 * 
//		 */		
//		public function get caller():CallResponder
//		{
//			if (null == _caller)
//				_caller = new CallResponder;
//			return _caller;
//		}
//		
//		public function call(domain:String,foo:String, ... args):void
//		{
//			var func:Function = this[domain.toLowerCase()][foo] as Function;
//			var call:AsyncToken = func.apply(null,args);
//			
//			_caller.callResponder(call,foo);
//			_caller = null;
//		}
//		
//		public function callRemoteObject(source:String,method:String, ...args):void
//		{
//			
//		}
		
		public function callCommand(id:String, ...args):void
		{
//			var item:CommandItem = this.resourceManager.getResourceItem(id) as CommandItem;
//			if (null == item)
//				throw new Error("callCommand: command id not exist!");
//			_parentClass = mainFrame;
//			_arguments = args;
//			//this.clickFunction(item,null);
			this.onCommand(new CmdEvent(id));
		}
		
		/**
		 * 设置函数调用类和参数 
		 * @param classObj 用于响应工具条/菜单的类
		 * @param args 参数数组
		 * 
		 */		
		public function setArguments(classObj:Object,...args):void
		{
			_parentClass = classObj;
			_arguments = args;
		}
		
		/**
		 * 右键菜单状态刷新回调函数 
		 * 统一右键与工具条函数接口 
		 * function rightMenuUpdateFunc(cmdID:String,item:Object):Boolean;
		 * @param func
		 * 
		 */		
		public function set rightMenuUpdateFunc(func:Function):void
		{
			_rightMenuUpdateFunc = func;
		}
		
		/**
		 * 右键菜单点击处理函数 
		 * 统一右键与工具条函数接口
		 * function rightMenuClickFunc(cmdID:String):Boolean;
		 * @param func
		 * 
		 */		
		public function set rightMenuClickFunc(func:Function):void
		{
			_rightMenuClickFunc = func;
		}

		public function get resourceManager():IResourceManager
		{
			return _resourceManager;
		}

		public function set resourceManager(value:IResourceManager):void
		{
			_resourceManager = value;
		}

		public function get mainFrame():IMainFrame
		{
			return _mainFrame;
		}

		public function set mainFrame(value:IMainFrame):void
		{
			_mainFrame = value;
		}
		
		public function onCommand(cmdEvt:CmdEvent):Boolean
		{
			if (_mainFrame && null != _mainFrame.activeFrame && _mainFrame.activeFrame.implObject.onCommand(cmdEvt))
				return true;
			else if (_mainFrame && _mainFrame.onCommand(cmdEvt))
				return true;
			else
			{
				if(resourceManager == null)
					return true;
				var item:CommandItem = this.resourceManager.getResourceItem(cmdEvt.cmdID) as CommandItem;
				if (null == item)
					throw new Error("callCommand: command id not exist!");
				_parentClass = mainFrame;
				_arguments = cmdEvt.params;
				this.clickFunction(item,null);
			}
			
			return true;
		}
		
		public function onUpdateCmdUI(cmdID:String, item:CommandItem):Boolean
		{
			if (null != _mainFrame.activeFrame &&  _mainFrame.activeFrame.implObject.onUpdateCmdUI(item.cmdID,item))
				return true;
			else if (_mainFrame.onUpdateCmdUI(item.cmdID,item))
				return true;
			
			return false;
		}
		
//		/**
//		 *	点击工具条/菜单转发处理函数
//		 *
//		 */		
//		public function command(item:Object, params:Array):Boolean
//		{
//			if (null != _mainFrame.activeFrame)
//				_mainFrame.activeFrame.implObject.onCommand(item.cmdID, params);
//			return false;
//		}
		
		/**
		 * 更新工具条/菜单转发处理函数
		 * @param item 当前的工具条/菜单项
		 * @return true：有效的项 false：无效的项
		 *
		 */		 
		public function updateCmdUI(item:CommandItem):Boolean
		{
			if(item.enableType == CommandConst.ENABLETYPE_GLOBAL){
				if (_mainFrame.onUpdateCmdUI(item.cmdID,item))
					return true; 
			}
			else if(item.enableType == CommandConst.ENABLETYPE_PART){	
				if (null != _mainFrame.activeFrame){
					_mainFrame.onUpdateCmdUI(item.cmdID,item);
					return _mainFrame.activeFrame.implObject.onUpdateCmdUI(item.cmdID,item);
				}
				else
					return false;
			}
			return false
		}

		public function getPanelInstance(classPath:String):Panel
		{
			return _instanceMap[classPath] as Panel;
		}
		
		/**
		 * 在容器库存中删除对象，避免重复使用(个别模块需刷新重建)
		 * @param classPath 对象类型字符
		 * @return true:删除成功 false:无效删除
		 */
		public function removePanelInstance(classPath:String):Boolean{
			if(!_instanceMap)
				return false;
			if(!(_instanceMap[classPath]))
				return false;
			delete _instanceMap[classPath];
			return true;
		}
		
		/**
		 * 创建实例
		 * @return
		 */
		static public  function getInstance():ICommandManager
		{
			if (_commandManager == null)
			{
				_commandManager = new CommandManager();
			}
			return _commandManager;
		}
		
		public function CommandManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * Tool菜单栏点击处理函数
		 * @param e MenuEvent
		 * 
		 */		
		public function onClickToolBar(e:MenuEvent):void
		{
			e.item.toggled = false;
			clickFunction(e.item as CommandItem,e.target);
		}
		
		/**
		 * ButtonBar菜单栏点击处理函数
		 * @param e ItemClickEvent
		 * 
		 */		
		public function onClickButtonBar(e:ItemClickEvent):void
		{
			clickFunction(e.item as CommandItem,e.target);
		}
		
		/**
		 * 统一右键与工具条点击处理函数  
		 * @param e
		 * @return true:执行成功 false：执行失败
		 * 
		 */		
		public function onRightMenuClick(e:MenuEvent):Boolean
		{
			if (null != _rightMenuClickFunc && _rightMenuClickFunc(e.item.cmdID))
				return true;
			return false;
		}
		
		public function onClick(item:Object):void
		{
			clickFunction(item as CommandItem,null);
		}
		
		/**
		 * 执行右键更新函数 
		 * @param rightMenuData 右键菜单数据源
		 * 
		 */		
		public function onRightMenuUpdate(rightMenuData:Array):void
		{
			rightMenuData.forEach(forEachRightMenuUpdate)
		}
		
		private function forEachRightMenuUpdate(item:Object,index:int,array:Array):void
		{
			if (null == _rightMenuUpdateFunc || !_rightMenuUpdateFunc(item.cmdID,item))
			{
				item.enabled = false;
				item.toggled = false;
			}
		}
		
		/**
		 * 统一不同事件统一资源按钮处理函数
		 * @param item
		 * 
		 */		
		private function clickFunction(item:CommandItem,target:Object):void
		{
			//try
			//{
				switch (item.actionType)
				{
					case CommandConst.ACTIONTYPE_COMPONENT:
					{
						if (item.classPath=="")
							break;
	
						var title:String = item.label;
						var icon:Class = AssetsUtil.stringToIcon(item.icon);
						
						var ClassReference:Class;
						var instance:UIComponent;
						switch (item.viewType)
						{
							case CommandConst.VIEWTYPE_PANELINSTANCE:
								instance = _instanceMap[item.classPath];
								if(null == instance)
								{
									ClassReference = getDefinitionByName(item.classPath) as Class;
									instance = new ClassReference();
									if(!(instance is Panel)){
										var p:Panel = new Panel();
										p.addElement(instance);
										instance = p;
										p.title = title;
										p.titleIcon = icon;
 									}
									Panel(instance).title = title;
									Panel(instance).titleIcon = icon;
									mainFrame.addPanel(Panel(instance));
									_instanceMap[item.classPath] = instance;//将单例索引添加进字典
									break;
								}
								if (null != instance)
								{
									//mainFrame.bringToFrontPanel(instance as Panel);
									mainFrame.addPanel(instance as Panel);
									break;
								}
							case  CommandConst.VIEWTYPE_PANEL:
								ClassReference = getDefinitionByName(item.classPath) as Class;
								instance = new ClassReference();
								mainFrame.addDisplayObject(instance,title,icon,NaN,NaN,item.classPath);
								if(item.classPath!="")
								{
									_instanceMap[item.classPath] = instance;//将单例索引添加进字典
								}
								break;
							case CommandConst.VIEWTYPE_TABNAVINSTANCE:
								instance = _instanceMap[item.classPath];
								if (null != instance)
								{
									mainFrame.bringToFrontTabNavigator(instance as ITabBar);
									break;
								}
							case CommandConst.VIEWTYPE_TABNAV:
								ClassReference = getDefinitionByName(item.classPath) as Class;
								instance = new ClassReference();
								mainFrame.addTabNavigator(instance as IVisualElement,title,icon);//,item.classPath);
								if(item.classPath!="")
								{
									_instanceMap[item.classPath] = instance;//将单例索引添加进字典
								}
								break;
							case CommandConst.VIEWTYPE_TABINSTANCE:
								instance = _instanceMap[item.classPath];
								if (null != instance)
								{
									if(instance.parent)
									{
										mainFrame.bringToFrontTab(instance as UIComponent);
									}
									else
									{
										mainFrame.addTab(instance,title,icon);
									}
									break;
								}
							case CommandConst.VIEWTYPE_TAB:
								ClassReference = getDefinitionByName(item.classPath) as Class;
								instance = new ClassReference();
								mainFrame.addTab(instance,title,icon);//,item.classPath);
								if(item.classPath!="")
								{
									_instanceMap[item.classPath] = instance;//将单例索引添加进字典
								}
								break;
							default:
								break;
						}
						break;
					}
					case CommandConst.ACTIONTYPE_CMD:
					{
						if (target)
						{
							if (target.hasOwnProperty("parentClass") && target.parentClass != "" && target.parentClass != null)
								setArguments(target.parentClass);
							else
								setArguments(_mainFrame);							
						}
						
						var func:Function;
						//						if (null != item.callBack)
						//						{
						//							if (item.callBack is Function)
						//								func = item.callBack;
						//							else if (item.callBack is String && String(item.callBack).length > 0 && _parentClass.hasOwnProperty(item.callBack))
						//								func = _parentClass[item.callBack] as Function;
						//						}
						//使用xml读取后没有Function
						if ("" != item.callBack && _parentClass.hasOwnProperty(item.callBack))
						{
							func = _parentClass[item.callBack] as Function;
						}
						else if ("" != item.cmdCallBack)
						{
							
							func = _parentClass[CommandConst.CMD_CALLBACK] as Function;
						}
						
						if (null != func)
						{
							if (null == _arguments)
								_arguments = [item];
							else
								_arguments.splice(0,0,item);
							func.apply(null,_arguments);
							setArguments(null);
						}
						else
						{
							_mainFrame.onCommand(new CmdEvent(item.cmdID));
//							trace("CommandManager::clickFunction func is null")
						}
						
						break;
					}
				}
			//}
			//catch(err:Error)
			//{
			//	trace("CommandManager::clickFunction"+err.message);
			//}
		}
		
		/**
		 * 置当前的子框架为有效 
		 * 
		 */
		public function frameActive():void
		{
			if (null != _mainFrame.activeFrame)
				_mainFrame.activeFrame.implObject.isActiveFrame =  true;
		}
		
		/**
		 * 置当前框架为无效
		 * 
		 */		
		public function frameInActive():void
		{
			//if (isView())
			if (null != _mainFrame.activeFrame)
				_mainFrame.activeFrame.implObject.isActiveFrame =  false;
		}
		
//		/**
//		 * 是否是IWn接口对象 
//		 * @return true：是 false：不是
//		 * 
//		 */		
//		private function isView():Boolean
//		{
//			if (null == _mainFrame)
//				return false;
//
//			var rootWnd:RootWindow = _mainFrame.rootWin;
//			if (rootWnd.numChildren == 0)
//				return false;
//			
//			var pramaryView:ViewWindow = rootWnd.primaryView;
//			if (null == pramaryView)
//				return false;
//			
//			var view:IVisualElementContainer = pramaryView.selectedChild as IVisualElementContainer;
//			
//			if (null != view)
//			{
//				if (view is IView)
//				{
//					_viewWin = view as IView;
//					return true;
//				}
//				else 
//				{
//					var child:IVisualElement = view.getElementAt(0);
//					if (child && child is IView)
//					{
//						_viewWin = child as IView;
//						return true;
//					}
//				}
//			}
//			return false;
//		}
		
		/**
		 * 自己的单例
		 */		
		static private  var _commandManager:CommandManager;
		
		/**
		 * Application的接口引用 
		 */		
		static private var _mainFrame:IMainFrame;
		
		/**
		 * 资源的引用 
		 */		
		static private var _resourceManager:IResourceManager
		
		/**
		 * 右键菜单状态刷新回调函数 
		 */		
		private var _rightMenuUpdateFunc:Function;
		
		/**
		 * 右键菜单点击处理函数
		 */		
		private var _rightMenuClickFunc:Function;
		
		/**
		 * 函数调用的参数 
		 */		
		private var _arguments:Array=[];
		
		/**
		 * 用于响应工具条/菜单的类  
		 */		
		private var _parentClass:Object;
		
		/**
		 *	单例的MDI或者TAB对象索引 
		 */		
		private var _instanceMap:Dictionary  = new Dictionary(true);
		
		// private var _viewWin:IView;
	}
}