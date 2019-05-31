package ppf.base.frame.docview.mx.views.components
{
	import ppf.base.frame.IDispose;
	import ppf.base.frame.docview.mx.views.events.ViewToolBarEvent;
	
	import flash.display.DisplayObject;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.Box;
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;
	
	public class DockView extends Box implements IDispose
	{
		/**
		 * 是否使用 HtmlTest显示
		 */		
		public var useHtmlTest:Boolean = false;
		
		/**
		 * html显示顶部信息栏标志 true：显示 false：隐藏 默认：true 
		 * @return 
		 * 
		 */	
		[Bindable]
		public function get topLabelHtmlText():String
		{
			return _topLabelHtmlText;
		}
		public function set topLabelHtmlText(value:String):void
		{
			_topLabelHtmlText = value;
		}
		
		/**
		 * 显示顶部信息栏标志 true：显示 false：隐藏 默认：true 
		 * @return 
		 * 
		 */
		[Bindable]
		public function get showTopControl():Boolean
		{
			return _showTopControl;
		}
		
		public function set showTopControl(value:Boolean):void
		{
			_showTopControl = value;
		}
		
		/**
		 * 顶部信息栏显示信息 
		 */		
		[Bindable]
		public function get topLabel():String
		{
			return _topLabel;
		}

		public function set topLabel(value:String):void
		{
			_topLabel = value;
		}

		public function set toolBarDataProvider(value:Object):void
		{
			_toolBarDataProvider=value;
		}
		
		public function get toolBarDataProvider():Object
		{
			return _toolBarDataProvider;
		}
		
		public function DockView()
		{
			super();
			
			/** common */
			this.label="untitled";
//			this.icon=defaultViewIconClass;
			/** effects */ /** events */
			
			/** size */ /** styles */
			this.setStyle("horizontalGap", 0);
			this.setStyle("verticalGap", 0);
			this.setStyle("backgroundColor",0xffffff);
			this.verticalScrollPolicy=ScrollPolicy.OFF;
			this.horizontalScrollPolicy=ScrollPolicy.OFF;
			
			/** other */
			this.addEventListener(FlexEvent.CREATION_COMPLETE,_onCreationComplete,false,0,true);
		}
		
		/**
		 * 释放资源 
		 */		
		public function dispose():void
		{
			if (null != toolBar)
				toolBar.removeEventListener(ViewToolBarEvent.CLICK, onToolBarClick);
			
			controlBar = null;
			toolBar = null;
			viewLabel = null;
			_toolBarDataProvider = null;
			_viewMenuDataProvider = null;
		}
		
		public function onToolBarClick(event:ViewToolBarEvent):void
		{
			
		}
		
		public function get viewWindow():ViewWindow
		{
			var object:DisplayObject=this;
			while (!(object is ViewWindow))
			{
				object=object.parent;
			}
			return ViewWindow(object);
		}
		
//		[Embed(source="assets/execute.png")]
//		protected var defaultViewIconClass:Class;
		
		protected var controlBar:HBox;
		
		protected var toolBar:ViewToolBar;
		
		protected var viewLabel:Label;
		
		/**
		 * 顶部HBOX容器
		 * 
		 */		
		protected function createControlBar():void
		{
			if (null == controlBar)
			{
				controlBar=new HBox();
				
				controlBar.setStyle("borderThickness", 1);
				controlBar.setStyle("borderStyle", "solid");
				controlBar.setStyle("borderSides", "bottom");
				controlBar.setStyle("verticalAlign", "top");
				//  horizontalAlign="center"
				controlBar.setStyle("paddingTop", 0);
				controlBar.setStyle("paddingBottom", 0);
				controlBar.setStyle("backgroundColor", 0xEBEBEB);
				controlBar.setStyle("horizontalGap", 0);
				controlBar.setStyle("verticalGap", 0);
				//				labelCtrl.text="Problems";
				controlBar.percentWidth=100;
				controlBar.height=24; //toolbar height + bottom line(borderThickness)
				this.addChildAt(controlBar,0);
				BindingUtils.bindProperty(controlBar,"visible",this,"showTopControl");
				BindingUtils.bindProperty(controlBar,"includeInLayout",this,"showTopControl");
			}
			createControlBarChildren();
		}
		
		/**
		 *创建标签和工具条条 
		 * 
		 */		
		protected function createControlBarChildren():void
		{
			createViewLabel();
			createToolBar();
		}
		
		/**
		 * 创建标签 
		 * 
		 */		
		protected function createViewLabel():void
		{
			if (null == viewLabel)
			{
				viewLabel=new Label();
				viewLabel.setStyle("backgroundColor", 0x0000FF);
				viewLabel.setStyle("paddingTop", 3);
				viewLabel.percentWidth=100;
				viewLabel.percentHeight=100;
				
				this.controlBar.addChild(viewLabel);
			}
		}
		
		/**
		 * 创建工具条
		 * 
		 */		
		protected function createToolBar():void
		{
			if (null == toolBar)
			{
				toolBar=new ViewToolBar();
				toolBar.addEventListener(ViewToolBarEvent.CLICK, onToolBarClick,false,0,true);
				_toolBarDataProvider=toolBarData();
				BindingUtils.bindProperty(toolBar, "dataProvider", this, "toolBarDataProvider");
				this.controlBar.addChild(toolBar);
			}
		}
		
		/**
		 * 工具条数据源 
		 * @return 
		 * 
		 */		
		protected function toolBarData():Array
		{
			return [];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			createControlBar();
		}
		
		/**
		 * FlexEvent.CREATION_COMPLETE 事件处理函数
		 * 
		 */		
		protected function onComplete():void
		{
			
		}
		/**
		 * FlexEvent.CREATION_COMPLETE 事件处理函数
		 * @param event
		 * 
		 */		
		protected function _onCreationComplete(event:FlexEvent):void
		{
			if (this.hasEventListener(FlexEvent.CREATION_COMPLETE))
				this.removeEventListener(FlexEvent.CREATION_COMPLETE,_onCreationComplete);
			
			if (useHtmlTest)
				BindingUtils.bindProperty(viewLabel,"htmlText",this,"topLabelHtmlText");
			else
				BindingUtils.bindProperty(viewLabel,"text",this,"topLabel");
			
			onComplete();
		}
		
		[Bindable]
		private var _toolBarDataProvider:Object=null;
		[Bindable]
		private var _viewMenuDataProvider:Object=null;
		
		[Bindable]
		private var _topLabel:String="";
		
		[Bindable]
		private var _topLabelHtmlText:String = "";
		
		//显示顶部信息栏 true：显示 false 隐藏
		private var _showTopControl:Boolean = false;
	}
}