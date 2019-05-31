package ppf.base.jabbypanda.controls
{
	import ppf.base.jabbypanda.event.HighlightItemListEvent;
	
	import flash.debugger.enterDebugger;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.core.FlexVersion;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.List;

	use namespace mx_internal;

	[Style(name="highlightBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]
	[Event(name="itemClick", type="mx.events.ItemClickEvent")]
	[Event(name="lookupValueChange", type="ppf.base.jabbypanda.event.HighlightItemListEvent")]
	/**
	 *  The color of the background for highlighted text segments
	 *
	 *   @default 0#FFCC00
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public final class HighlightItemList extends List
	{

		[SkinPart(required="false")]
		public var bgFill:SolidColor;
		
		public function HighlightItemList()
		{
			super();parent
		}
		
		override public function parentChanged(p:DisplayObjectContainer):void
		{
			super.parentChanged(p);
			trace(p);
		}

		public var searchMode:String;

		public function focusListUponKeyboardNavigation(event:KeyboardEvent):void
		{
			adjustSelectionAndCaretUponNavigation(event);
		}

		public function get lookupValue():String
		{
			return _lookupValue;
		}

		public function set lookupValue(lookupValue:String):void
		{
			_lookupValue=lookupValue;
			dispatchEvent(new HighlightItemListEvent(HighlightItemListEvent.LOOKUP_VALUE_CHANGE));
		}

		override protected function dataProvider_collectionChangeHandler(event:Event):void
		{
			super.dataProvider_collectionChangeHandler(event);

			if (event is CollectionEvent)
			{
				var ce:CollectionEvent=CollectionEvent(event);

				// workaround to set caretIndex to 0 if selection is required
				if (ce.kind == CollectionEventKind.REFRESH)
				{
					if (requireSelection)
					{
						setCurrentCaretIndex(0);
					}
				}
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,200,true);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,200,true);
			systemManager.getSandboxRoot().
				addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, onMouseDown, false,200, true);
		}
		
//		override protected function partAdded(partName:String, instance:Object):void
//		{
//			super.partAdded(partName, instance);
//			
//			if (instance == bgFill)
//			{
//				bgFill.color = 0xFF0000;
//			}
//		}
		
		
		protected function onMouseDown(event:Event):void
		{
			// TODO Auto-generated method stub
			trace("a");
		}
		
		private var _lookupValue:String="";
	}
}