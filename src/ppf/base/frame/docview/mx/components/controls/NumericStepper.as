package ppf.base.frame.docview.mx.components.controls
{
	import flash.events.Event;
	
	import mx.controls.NumericStepper;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	/**
	 * 自定义 NumericStepper
	 * @author 王珂
	 * 
	 */	
	public class NumericStepper extends mx.controls.NumericStepper
	{
		/**
		 * 显示工具提示
		 * @param object 输入控件
		 * @param valid 输入验证控件
		 * @return 
		 * 
		 */		
		static private function getToolTip(object:Object):String
		{
			return "可输入数字的范围：" + object.minimum + " 到 " + object.maximum;
		}
		
		/**
		 *  NumericStepper 控件的文本区域显示的当前值
		 */		
		[Bindable]
		public var _value:String;
		[Bindable]
		private var _text:String;
		/**
		 * 构造函数 
		 * 
		 */		
		public function NumericStepper()
		{
			super();
			super.maximum=65535;
			super.minimum=-65535;
			this.addEventListener(Event.CHANGE,onChange);
			toolTip = getToolTip(this);
		}
		
		override protected function commitProperties():void
		{
			toolTip = getToolTip(this);
			super.commitProperties();
		}
		
		/**
		 * NumericStepper 控件的文本区域显示的当前值 
		 * @param v
		 * 
		 */		
		public function set Value(v:String):void
		{
			super.value = Number(v);
			_value = v;
			_text = v;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(v:String):void
		{
			_text = v;
			_value = v;
			value = Number(v);
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			mx_internal::inputField.addEventListener(Event.SCROLL, textField_scrollHandler);
			setStyle("textAlign", "right");
		}
		
		protected function textField_scrollHandler(e:Event):void
		{
			this.callLater(setScrollPosition);
		}
		
		protected function setScrollPosition():void
		{
			mx_internal::inputField.horizontalScrollPosition = 0;
		}
		
		/**
		 * 当 NumericStepper 控件的值由于用户交互操作而发生更改时事件处理函数
		 * @param event
		 * 
		 */		
		private function onChange(event:Event):void
		{
			_value = String(value);
			_text = String(value);
		}
	}
}