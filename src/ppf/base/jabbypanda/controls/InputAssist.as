package ppf.base.jabbypanda.controls
{
	import ppf.base.jabbypanda.data.SearchModes;
	import ppf.base.jabbypanda.event.InputAssistEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ItemClickEvent;
	import mx.managers.SystemManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleProxy;
	
	import spark.components.PopUpAnchor;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	import spark.utils.LabelUtil;

	use namespace mx_internal;

	[Style(name="highlightBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]
	[Event(name="change", type="ppf.base.jabbypanda.event.InputAssistEvent")]
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
	public final class InputAssist extends SkinnableComponent
	{
		/**
		 * 设置文本框为是否“不可修改”状态，可复制内容，建议使用该属性替换enabled
		 * @private
		 * 
		 */	    
		public function set editable(value:Boolean):void
		{
			inputTxt.editable = value;
		}
		/**
		 * 是否允许新值 不在下拉列表里
		 */
		public function get allowNewValues():Boolean
		{
			return _allowNewValues;
		}

		/**
		 * @private
		 */
		public function set allowNewValues(value:Boolean):void
		{
			_allowNewValues = value;
		}

		public function get text():String
		{
			return enteredText;
		}
		public function set text(value:String):void
		{
			enteredText= value;
		}
		
		public function InputAssist()
		{
			super();
			this.mouseEnabled=true;
			dataProvider=null;
		}

		public var forceOpen:Boolean=true;

		[SkinPart(required="true", type="com.grusen.spark.components.controls.TextInput")]
		public var inputTxt:TextInput;

		[SkinPart(required="true", type="odyssey.common.component.HighlightItemList")]
		public var list:HighlightItemList;

		[Bindable]
		public var maxRows:Number=6;

		[SkinPart(required="true", type="com.jabbypanda.controls.PopUpAnchorFixed")]
		public var popUp:PopUpAnchorFixed;

		[Bindable]
		public var processing:Boolean=false;

		public var requireSelection:Boolean=false;

		public function get dataProvider():Object
		{
			return _collection;
		}

		[Bindable]
		public function set dataProvider(value:Object):void
		{

			if (value is Array)
			{
				_collection=new ListCollectionView(new ArrayList(value as Array));
			}
			else if (value is ArrayList)
			{
				ArrayList(value).addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false, 0, true);
				_collection=new ListCollectionView(value as ArrayList);
			}
			else if (value is ArrayCollection)
			{
				ArrayCollection(value).addEventListener(CollectionEvent.COLLECTION_CHANGE, onDataProviderCollectionChange, false, 0, true);
				_collection=new ListCollectionView((value as ArrayCollection).list);
			}
			else
			{
				_collection=new ListCollectionView();
			}

			if (isOurFocus(this.getFocus()))
			{
				filterData();
			}

			_dataProviderChanged=true;
			invalidateProperties();
		}

		override public function set enabled(value:Boolean):void
		{
			super.enabled=value;
			_enabledChanged=true;
			invalidateProperties();
		}

		public function get errorMessage():String
		{
			return _errorMessage;
		}

		public function set errorMessage(value:String):void
		{
			_errorMessage=value;
			_errorMessageChanged=true;
			invalidateProperties();
		}

		/**
		 * 过滤函数，返回用于过滤的条件字符 </br>
		 * function filterFunc(item:Object):String 
		 */		
		public var filterFunc:Function;

		// default filter function         
		public function filterFunction(item:Object):Boolean
		{
			var itemLabel:String=itemToLabel(item).toLowerCase();

			if (null != filterFunc)
				itemLabel = filterFunc(item);
			
			switch (searchMode)
			{
				case SearchModes.PREFIX_SEARCH:
					if (itemLabel.substr(0, enteredText.length) == enteredText.toLowerCase())
					{
						return true;
					}
					else
					{
						return false;
					}
					break;
				case SearchModes.INFIX_SEARCH:

					if (itemLabel.indexOf(enteredText.toLowerCase()) != -1)
					{
						return true;
					}
					break;
			}

			return false;
		}

		public function get labelField():String
		{
			return _labelField;
		}

		public function set labelField(field:String):void
		{
			_labelField=field;
			if (list)
			{
				list.labelField=field;
			}
		}

		public function get labelFunction():Function
		{
			return _labelFunction;
		}

		public function set labelFunction(func:Function):void
		{
			_labelFunction=func;
			if (list)
			{
				list.labelFunction=func;
			}
		}

		public function get prompt():String
		{
			return _prompt;
		}

		public function set prompt(value:String):void
		{
			_prompt=value;
			_promptChanged=true;
			invalidateProperties();
		}

		public function get searchMode():String
		{
			return _searchMode;
		}

		public function set searchMode(searchMode:String):void
		{
			_searchMode=searchMode;
			if (list)
			{
				list.searchMode=searchMode;
			}
		}

		[Bindable]
		public function get selectedItem():Object
		{
			return _selectedItem;
		}

		public function set selectedItem(item:Object):void
		{
			if (!_collection || isSelectedItemValid(item))
			{
				_selectedItem=item;
			}
			else
			{
				_selectedItem=null;
			}

			_selectedItemChanged=true;
			invalidateProperties();
		}
		
		override public function get baselinePosition():Number
		{
			//FormItem的label的y是以baselinePosition计算，解决label错位问题
			if (null != inputTxt)
				return inputTxt.baselinePosition;
			
			return super.baselinePosition;
		}

		override public function setFocus():void
		{
			if (inputTxt)
			{
				inputTxt.setFocus();
			}
		}

		override protected function commitProperties():void
		{
			if (_dataProviderChanged)
			{
				//reset selectedItem to null if it is anymore present in dataProvider 
				if (!isSelectedItemValid(selectedItem))
				{
					selectedItem=null;
				}

				list.dataProvider=_collection;

				if (!dataProvider || dataProvider.length == 0 && !_allowNewValues)
				{
					enabled=false;
					displayErrorMessage();
				}
				else
				{
					enabled=true;
					if (!selectedItem && prompt)
					{
						displayPromptMessage();
					}
					else
					{
						displayInputTextText(selectedItem);
					}
				}

				_dataProviderChanged=false;
			}

			if (_selectedItemChanged)
			{
				if (!selectedItem && prompt)
				{
					displayPromptMessage();
				}
				else
				{
					displayInputTextText(selectedItem);
				}
				_selectedItemChanged=false;
			}

			if (_promptChanged)
			{
				if (!selectedItem && prompt)
				{
					displayPromptMessage();
				}
				_promptChanged=false;
			}

			if (_errorMessageChanged)
			{
				displayErrorMessage();
				_errorMessageChanged=false;
			}

			if (_enabledChanged)
			{
				inputTxt.enabled=enabled;
				_enabledChanged=false;
			}


			// Should be last statement.
			// Don't move it up.
			super.commitProperties();
		}

		protected function get enteredText():String
		{
			return _enteredText;
		}

		protected function set enteredText(t:String):void
		{
			_enteredText=t;
			if (inputTxt)
			{
				inputTxt.text=t;
				inputTxt.selectRange(t.length,t.length);
			}

			if (list)
			{
				list.lookupValue=_enteredText;
			}

			filterData();
		}

		protected function filterData():void
		{
			if (_collection)
			{
				_collection.filterFunction=filterFunction;
				_collection.refresh();
			}
		}

		protected function get isDropDownOpen():Boolean
		{
			return popUp.displayPopUp;
		}

		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			if (!inputTxt)
			{
				return false;
			}

			return target == inputTxt.textDisplay || super.isOurFocus(target);
		}

		protected function itemToLabel(item:Object):String
		{
			if (!item)
			{
				return "";
			}
			else
			{
				return LabelUtil.itemToLabel(item, labelField, labelFunction);
			}
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance)

			if (instance == inputTxt)
			{
				inputTxt.addEventListener(FocusEvent.FOCUS_IN, onInputFieldFocusIn, false, 0, true);
				inputTxt.addEventListener(FocusEvent.FOCUS_OUT, onInputFieldFocusOut, false, 0, true);
				inputTxt.addEventListener(TextOperationEvent.CHANGE, onInputFieldChange, false, 0, true);
				inputTxt.addEventListener(KeyboardEvent.KEY_DOWN, onInputFieldKeyDown, false, 0, true);
			}

			if (instance == list)
			{
				list.labelField=labelField;
				list.labelFunction=labelFunction;
				list.searchMode=searchMode;
				list.requireSelection=requireSelection;
				list.styleName=new StyleProxy(this, {});

				list.addEventListener(ItemClickEvent.ITEM_CLICK, onListItemClick, false, 0, true);
				list.addEventListener(FlexEvent.UPDATE_COMPLETE, onListUpdateComplete, false, 0, true);
			}
		}

		private function acceptCompletion():void
		{
			var proposedSelectedItem:Object;
			if (_collection && _collection.length > 0 && list.selectedIndex >= 0)
			{
				_completionAccepted=true;
				proposedSelectedItem=_collection.getItemAt(list.selectedIndex);
			}
			else
			{
				_completionAccepted=false;
				proposedSelectedItem=null;
				displayInputTextText(null);
			}

			if (proposedSelectedItem != selectedItem)
			{
				selectedItem=proposedSelectedItem;
				var e:InputAssistEvent=new InputAssistEvent(InputAssistEvent.CHANGE, _selectedItem);
				dispatchEvent(e);
				hidePopUp();
			}
			else
			{
				showPreviousTextAndHidePopUp(true);
			}
		}

		private function displayErrorMessage():void
		{
			if (_collection && _collection.length == 0)
			{
				inputTxt.text=_errorMessage;
			}
		}

		private function displayInputTextText(selectedItem:Object):void
		{
			var str:String = itemToLabel(selectedItem as Object);
			if (_allowNewValues)
			{
				if (null != selectedItem)
					enteredText = str;
			}
			else
			{
				_previouslyDisplayedText = enteredText = str;
			}
		}

		private function displayOptionsList():void
		{
			if (null != _collection)
			{
				if (_collection.length == 0)
				{
					hidePopUp();
				}
				else if (forceOpen || enteredText.length > 0)
				{
					showPopUp();
					filterData();
				}
			}
		}

		private function displayPromptMessage():void
		{
			if (!_collection || _collection.length > 0)
			{
				inputTxt.text=_prompt;
			}
		}

		private function hidePopUp():void
		{
			if (isDropDownOpen)
			{
				popUp.popUp.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
				systemManager.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				popUp.displayPopUp=false;
			}
		}

		private function isSelectedItemValid(proposedSelectedItem:Object):Boolean
		{
			for each (var item:Object in _collection)
			{
				if (proposedSelectedItem == item)
				{
					return true;
				}
			}
			return false;
		}

		private function onDataProviderCollectionChange(event:CollectionEvent):void
		{
			_dataProviderChanged=true;
			invalidateProperties();
		}

		private function onInputFieldChange(event:TextOperationEvent=null):void
		{
			_completionAccepted=false;
			enteredText=inputTxt.text;
			//允许新值置为null，有可能选中后又修改，造成focusIn时bug
			if (_allowNewValues)
				selectedItem = null;
			displayOptionsList();
		}

		private function onInputFieldFocusIn(event:FocusEvent):void
		{
			displayInputTextText(selectedItem);
			if (forceOpen)
			{
				displayOptionsList();
			}
			
			callLater(inputTxt.selectRange,[_enteredText.length,_enteredText.length]);
		}

		private function onInputFieldFocusOut(event:FocusEvent):void
		{
			if (!selectedItem && prompt)
			{
				displayPromptMessage();
				hidePopUp();
			}
			else
			{
				showPreviousTextAndHidePopUp(!_completionAccepted);
			}
		}

		private function onInputFieldKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
					list.focusListUponKeyboardNavigation(event);
					break;
				case Keyboard.ENTER:
					acceptCompletion();

					break;
				case Keyboard.TAB:
				case Keyboard.ESCAPE:
					showPreviousTextAndHidePopUp(!_completionAccepted);
					break;
			}
		}


		private function onListItemClick(event:ItemClickEvent):void
		{
			acceptCompletion();
			event.stopPropagation();
		}

		private function onListUpdateComplete(event:FlexEvent):void
		{
			popUp.updatePopUpTransform();
		}

		private function onMouseDownOutside(event:FlexMouseEvent):void
		{
			var mouseDownInsideComponent:Boolean=false;
			var clickedObject:DisplayObject = event.relatedObject as DisplayObject;

			while (!(clickedObject.parent is SystemManager))
			{
				if (clickedObject == this)
				{
					mouseDownInsideComponent=true;
					break;
				}

				clickedObject=clickedObject.parent;
			}

			if (!mouseDownInsideComponent)
			{
				showPreviousTextAndHidePopUp(!_completionAccepted);
			}
		}

		private function onMouseWheel(event:MouseEvent):void
		{
			if (!(DisplayObjectContainer(list).contains(DisplayObject(event.target)) && event.isDefaultPrevented()))
			{
				hidePopUp();
			}
		}

		private function setListOptionsSelectedIndex():void
		{
			var selectedIndex:int=_collection.getItemIndex(selectedItem);
			if (selectedIndex != -1)
			{
				list.selectedIndex=selectedIndex;
			}
			else
			{
				list.selectedIndex=0;
			}
		}

		private function showPopUp():void
		{
			if (!isDropDownOpen)
			{
				popUp.displayPopUp=true;

				//dg使用该组件关键句，否则会在造成无法选中下拉项
				//在dg的private function editorMouseDownHandler(event:Event):void中的判断owner
				list.owner = this;
				
				if (requireSelection)
				{
					setListOptionsSelectedIndex();
				}
				else
				{
					list.selectedIndex=-1;
				}

				popUp.popUp.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
				systemManager.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
		}

		private function showPreviousTextAndHidePopUp(showPreviousText:Boolean):void
		{
			if (showPreviousText)
			{
				//不允许新值，焦点退出时，恢复前一个显示
				if (!allowNewValues)
					enteredText=_previouslyDisplayedText;
			}

			hidePopUp();
		}
		
		// Define a static variable.
		private static var classConstructed:Boolean=classConstruct();
		
		// Define a static method.
		private static function classConstruct():Boolean
		{
			var customListStyles:CSSStyleDeclaration;
			
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.jabbypanda.controls.InputAssist"))
			{
				// If there is no CSS definition for InputAssist 
				// then create one and set the default value.
				customListStyles=new CSSStyleDeclaration();
				customListStyles.defaultFactory=function():void
				{
					this.highlightBackgroundColor=0xFFCC00;
				}
				
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.jabbypanda.controls.InputAssist", customListStyles, true);
			}
			
			return true;
		}
		
		private var _collection:ListCollectionView;
		
		private var _completionAccepted:Boolean;
		
		private var _dataProviderChanged:Boolean;
		
		private var _enabledChanged:Boolean;
		
		private var _enteredText:String="";
		
		private var _errorMessage:String="No available options";
		
		private var _errorMessageChanged:Boolean;
		
		private var _labelField:String = "label";
		
		private var _labelFunction:Function;
		
		private var _previouslyDisplayedText:String="";
		
		/**
		 * 提示
		 */		
		private var _prompt:String;
		
		private var _promptChanged:Boolean;
		
		/**
		 * 查找下拉的模式  
		 */		
		private var _searchMode:String=SearchModes.INFIX_SEARCH;
		
		/**
		 * 下拉选中项 
		 */		
		private var _selectedItem:Object;
		
		private var _selectedItemChanged:Boolean;
		
		/**
		 * 是否允许新值 不在下拉列表里
		 */
		private var _allowNewValues:Boolean = true;
	}

}
