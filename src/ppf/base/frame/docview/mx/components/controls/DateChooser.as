package ppf.base.frame.docview.mx.components.controls
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.DateChooser;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.NumericStepperEvent;
	
	use namespace mx_internal;
	public class DateChooser extends mx.controls.DateChooser
	{
		[Bindable]
		[Embed(source="/assets/delete.gif")]
		protected var _img_close:Class;
		
		[Bindable]
		[Embed(source="/assets/Hook.png")]
		protected var _img_success:Class;
		
		protected var _timeBox:HBox = new HBox;
		protected var _hourInput:NumericStepper = new NumericStepper;
		protected var _minuteInput:NumericStepper = new NumericStepper;
		protected var _secondInput:NumericStepper = new NumericStepper;
		
		protected var _btnClose:Button = new Button;
		protected var _btnSuccess:Button = new Button;
		
		/**
		 * 是否显示秒数 
		 */		
		public var isShowSecond:Boolean = false;
		
		public function DateChooser()
		{
			super();
			this.visible = false;
			var tmpDate:Date = new Date;
			//设置当前选中的背景色时DateChooser钟的CalendarLayout的是根据 selectableRange计算判断，但是计算判断不需要时分秒
			var rangeEnd:Date = new Date(tmpDate.fullYear,tmpDate.month,tmpDate.date);
			selectableRange = {rangeStart : new Date(1970, 0, 1), rangeEnd : rangeEnd};
			yearNavigationEnabled = true;
			dayNames = ["日", "一", "二", "三", "四", "五", "六"];
			monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"];
			monthSymbol = "";
//			FLEX_TARGET_VERSION::flex4
//			{
//				monthNames = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"];
//			}
//			FLEX_TARGET_VERSION::flex3
//			{
//				dayNames = ["日", "一", "二", "三", "四", "五", "六"];
//				monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"];
//			}
			
			this.addEventListener(Event.ADDED_TO_STAGE, initApp);
			this.showToday = false;
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			addChild(_timeBox);
			_timeBox.percentWidth = 100;
			_timeBox.height = 30;
			_timeBox.horizontalScrollPolicy = "off";
			_timeBox.verticalScrollPolicy = "off";
			_timeBox.setStyle("horizontalGap","-2");
			_timeBox.setStyle("horizontalAlign","center");
			_timeBox.setStyle("paddingLeft","3");
			_timeBox.setStyle("paddingRight","3");
			
			_timeBox.addChild(_hourInput);
			_hourInput.maximum=23;
			_hourInput.width=45;
			_hourInput.minimum=0;
			_hourInput.maxChars=2;
			_hourInput.setStyle("textAlign", "right");
			
			var tmptextfield:UITextField = new UITextField;
			tmptextfield.text = ":";
			tmptextfield.selectable = false;
			_timeBox.addChild(tmptextfield);
			
			_timeBox.addChild(_minuteInput);
			_minuteInput.maximum=59;
			_minuteInput.width=45;
			_minuteInput.minimum=0;
			_minuteInput.maxChars=2;
			_minuteInput.setStyle("textAlign", "right");
			
			if (isShowSecond)
			{
				var tmptextfield2:UITextField = new UITextField;
				tmptextfield2.text = ":";
				tmptextfield2.selectable = false;
				_timeBox.addChild(tmptextfield2);
		
				_timeBox.addChild(_secondInput);
				_secondInput.maximum=59;
				_secondInput.width=45; 
				_secondInput.minimum=0;
				_secondInput.maxChars=2;
				_secondInput.setStyle("textAlign", "right");
			}
			
			var tmptextfield3:UITextField = new UITextField;
			tmptextfield3.text = " ";
			tmptextfield3.selectable = false;
			_timeBox.addChild(tmptextfield3);
			
			_timeBox.addChild(_btnClose);
			_btnClose.setStyle("icon", _img_success);
			_btnClose.setStyle("cornerRadius", 0);
			_btnClose.minHeight = 5;
			_btnClose.minWidth = 5;
			_btnClose.width = 25;
			_btnClose.height = 25;
			_btnClose.buttonMode=true;
			
			_hourInput.addEventListener(NumericStepperEvent.CHANGE, onNumChange);
			_minuteInput.addEventListener(NumericStepperEvent.CHANGE, onNumChange);
			
			if (isShowSecond)
				_secondInput.addEventListener(NumericStepperEvent.CHANGE, onNumChange);
			
			_btnClose.addEventListener(MouseEvent.CLICK, onBtnClick);
			this.invalidateDisplayList();
		}
		
		
		protected function initApp(e:Event):void
		{
			onAddStage(e);
		}
		
		protected function onAddStage(e:Event):void
		{
			try
			{
				switch (e.type)//onStageClick
				{
					case Event.ADDED_TO_STAGE:
						stage.addEventListener(MouseEvent.CLICK, onStageClick, false, 0, true);
						break;
				}
			}
			catch (err:Error)
			{ 
				trace("DateChooser::onAddOrRemoved error...");
			}
		}
		
		
		private var _selectedDate:Date;
		
//		override public function get selectedDate():Date
//		{
//			_selectedDate = super.selectedDate;
//			_selectedDate.hours = _hourInput.value;
//			_selectedDate.minutes = _minuteInput.value;
//			_selectedDate.seconds = _secondInput.value;
//			return _selectedDate;
//		}
		public function  getSelectedDate():Date
		{
			_selectedDate.fullYear = selectedDate.fullYear;
			_selectedDate.month = selectedDate.month;
			_selectedDate.date = selectedDate.date;
			_selectedDate.hours = _hourInput.value;
			_selectedDate.minutes = _minuteInput.value;
			if (isShowSecond)
				_selectedDate.seconds = _secondInput.value;
			return _selectedDate;
		}
		
		override public function set selectedDate(value:Date):void
		{
			_selectedDate = value;
			// 设置当前选中的背景色时DateChooser钟的CalendarLayout的是根据 selectableRange计算判断，但是计算判断不需要时分秒
			var d:Date = new Date(_selectedDate.fullYear,_selectedDate.month,_selectedDate.date);
			super.selectedDate = d;
			
			_hourInput.value = _selectedDate.hours;
			_minuteInput.value = _selectedDate.minutes;
			
			if (isShowSecond)
				_secondInput.value = _selectedDate.seconds;
		}
		
		protected function onBtnClick(e:MouseEvent):void
		{
			try
			{
				displayCloseEvent();
			}
			catch (err:Error)
			{ 
				trace("DateChooser::onBtnClick error...");
			}
		}
		
		protected function onStageClick(e:MouseEvent):void
		{
			if (isHitThisObject(e))
				return;
			displayCloseEvent();
		}
		
		protected function isHitThisObject(e:MouseEvent):Boolean
		{
			try
			{
				return this.hitTestPoint(e.stageX, e.stageY, true);
			}
			catch (err:Error)
			{ 
				trace("DateChooser::isHitThisObject error...");
			}
			return true;
		}
		
		protected function onNumChange(e:NumericStepperEvent):void
		{
			switch (e.target)
			{
				case _hourInput:
					_selectedDate.hours = _hourInput.value;
					break;
				case _minuteInput:
					_selectedDate.minutes = _minuteInput.value;
					break;
				case _secondInput:
					_selectedDate.seconds = _secondInput.value;
					break;
			}
			super.selectedDate = _selectedDate;
			displayChangeEvent();
		}
		
		/**
		 * @private
		 * 
		 */		
		override protected function measure():void
		{
			super.measure();
			
			measuredHeight += _timeBox.height;
			measuredMinHeight += _timeBox.height;
			
			var borderThickness:Number = getStyle("borderThickness");
			var tmpWidth:Number = _timeBox.getExplicitOrMeasuredWidth() + borderThickness*2;
			measuredWidth = measuredWidth > tmpWidth ? measuredWidth : tmpWidth;
			measuredMinWidth = measuredWidth;
		}
		
		/**
		 * @private
		 * @param unscaledWidth
		 * @param unscaledHeight
		 * 
		 */		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var borderThickness:Number = getStyle("borderThickness");
			var w:Number = unscaledWidth - borderThickness*2;
			var h:Number = unscaledHeight - borderThickness*2;
			
			mx_internal::dateGrid.setActualSize(w, h - 30 - 30);
			mx_internal::dateGrid.move(borderThickness, 30 + borderThickness);
			
			_timeBox.setActualSize(w, 30);
			_timeBox.move(borderThickness, 30 + borderThickness + mx_internal::dateGrid.height);
		}
		
		/**
		 * 发送事件
		 * 
		 */		
		protected function displayChangeEvent():void
		{
			var evt:CalendarLayoutChangeEvent = new 
				CalendarLayoutChangeEvent(CalendarLayoutChangeEvent.CHANGE);
			evt.newDate = _selectedDate;
			dispatchEvent(evt);
		}
		
		public function displayCloseEvent():void
		{
			try
			{
				this.visible = false;
				stage.removeEventListener(MouseEvent.CLICK, onStageClick);
				var evt:Event = new Event(Event.CLOSE);
				dispatchEvent(evt);
			}
			catch (err:Error)
			{ 
				trace("DateChooser::displayCloseEvent error...");
			}
		}
	}
}