package ppf.base.frame.docview.mx.components.containers
{
	import ppf.base.frame.docview.mx.components.controls.Button;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.containers.DividedBox;
	import mx.containers.dividedBoxClasses.BoxDivider;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.Resize;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	use namespace mx_internal;
	[Style(name="btnCornerRadius",type="Number",inherit="no")]
	[Style(name="dividerThickness",type="Number",inherit="no")]
	[Style(name="buttonLen",type="Number",inherit="no")]
	[Style(name="barFillColors",type="Array",format="Color",inherit="no")]
	[Style(name="barBorderColor",type="uint",format="Color",inherit="no")]
	public class DividerBox extends mx.containers.DividedBox
	{
		public function DividerBox()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,initApp,false,0,true);
		}
		
		public function get button():Button
		{
			return _button;
		}

		public function set button(value:Button):void
		{
			_button = value;
		}

		public function get containerIsVisable():Boolean
		{
			return _containerIsVisable;
		}
		
		public function set ButtonOnIndexs(value:Array):void
		{
			_ButtonOnIndexs=value
		}
		
		public function get ButtonOnIndexs():Array
		{
			return _ButtonOnIndexs;	
		}
		
		/**
		 * 是否显示按钮
		 * @param value true:是 false：否
		 *
		 */
		public function set showButton(value:Boolean):void
		{
			_showButton=value
		}
		public function get showButton():Boolean
		{
			return _showButton;	
		}
		
		/**
		 * 按钮选中状态 
		 * @param value
		 * 
		 */
		public function set ButtonSelected(value:Boolean):void
		{
			_containerIsVisable = !value;
			if (_button)
			{
				_button.selected=value;
			}
		}
		public function get ButtonSelected():Boolean
		{
			if (_button)
			{
				return _button.selected;	
			}
			else{
				return false;
			}
		}
		[Inspectable(category="General", enumeration="top,bottom,left,right")]
		/**
		 * 收缩样式 
		 * @param value
		 * 
		 */
		public function set dvStyle(value:String):void
		{
			_dvStyle=value;
		}
		
		public function get dvStyle():String
		{
			return _dvStyle;	
		}
		/**
		 *收缩的对象 
		 * @param value
		 * 
		 */		
		public function set resizeTarget(value:UIComponent):void
		{
			_resizeTarget=value;
			
			setResize();
		}
		
		public function get resizeTarget():UIComponent
		{
			return _resizeTarget;	
		}
		/**
		 * 收缩的长度 
		 * @param value
		 * 
		 */		
		public function set shrinkLen(value:Number):void
		{
			_shrinkLen = value;
			
			if (_shrinkLen > 0 && this.initialized)
				initApp(null);
		}
		
		public function get shrinkLen():Number
		{
			return _shrinkLen;	
		}
		
		/**
		 * 缩放的事件处理 
		 * @param e
		 * 
		 */
		public function onButtonClick(e:DvBtnClickEvent=null):void
		{
			if (_containerIsVisable==true)
			{
				switch(_dvStyle)
				{
					case "top":
						this._curLen = this.getChildAt(0).height;
						if (_curLen > 10)
							_openResize.heightTo = _curLen;
						else
							_openResize.heightTo = _shrinkLen;
						break;
					case "bottom":
						this._curLen = this.getChildAt(1).height;
						if (_curLen > 10)
							_openResize.heightTo = _curLen;
						else
							_openResize.heightTo = _shrinkLen;
						break;
					case "left":
						this._curLen = this.getChildAt(0).width;
						if (_curLen > 10)
							_openResize.widthTo = _curLen;
						else
							_openResize.widthTo = _shrinkLen;
						break;
					
					case "right":
						this._curLen = this.getChildAt(1).width;
						if (_curLen > 10)
							_openResize.widthTo = _curLen;
						else
							_openResize.widthTo = _shrinkLen;
						break;
				}
				_closeResize.play();
				this.ButtonSelected = true;
			}
			else
			{
				_openResize.play();
				this.ButtonSelected = false;
			}
		}
		
		override public function styleChanged(styleProp:String):void 
		{
			
			super.styleChanged(styleProp);
			
			// Check to see if style changed. 
			if (styleProp=="barFillColors" || styleProp=="barBorderColor") 
			{
				_barBorderColor=0;
				_barFillColors=null;
				invalidateDisplayList();
				return;
			}
			
			
		}
		/**
		 * don't allow dragging if over a button
		 * */		
		
		override mx_internal function startDividerDrag(divider:BoxDivider,trigger:MouseEvent):void
		{
			
			//ignore if we are over a button
			if(_showButton && _isOverButton)
			{
				return;			
			}
			
			super.mx_internal::startDividerDrag(divider,trigger);
			
		}
		
		/**
		 * don't show splitter cursor when over a button
		 * */	
		override mx_internal function changeCursor(divider:BoxDivider):void
		{
			
			//ignore if we are over a button
			if(_showButton && _isOverButton)
			{
				return;			
			}
			
			super.mx_internal::changeCursor(divider);
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var dnum:int = this.numDividers;
			//if (dnum == 0 && _BoxDivider.length != 0)
				//_BoxDivider = [];
			//if (_BoxDivider.length == 0)
			//{
				for(var i:int=0;i < dnum;i++) 
				{
					var divbar:BoxDivider = getDividerAt(i);
					if(!divbar)
						continue;
					divbar.addEventListener("resize",handleResize,false,0,true);
					if(_BoxDivider.indexOf(divbar)<0)
					   _BoxDivider.push(divbar);
					
					//see if the current index is in the array or if the array is 0 then
					//all have buttons this will allow us to have buttons only on selected
					//parts of a multi part splitter
					var _hasbutton:Boolean=true;//default true if no indexs
					if (_ButtonOnIndexs)
					{
						if (_ButtonOnIndexs.length !=0)
						{
							_hasbutton= verifyButtonIndex(i)
						}
					}
					
					if(_showButton && _hasbutton)
					{
						if (dnum == 1 && null == _button)
							_button = new Button();
						_button.name = "SplitterButton" + i;
						_button.toggle =true;
  						//this.ButtonSelected = _button.selected;
						
						//_button.selected = !this._containerIsVisable;
						_button.setStyle("cornerRadius",getStyle("btnCornerRadius"));
						divbar.setStyle("dividerSkin",null);
						var buttonLen:Number = getStyle("buttonLen");
						if (buttonLen)
							_buttonLen = buttonLen;
						/*var dividerThickness:Number = getStyle("Thickness");
						if (dividerThickness)
						_dividerThickness = dividerThickness;*/
						_button.x = 0;
						_button.y = 0;
						_button.useHandCursor = true;
						
						switch (_dvStyle)
						{
							case "top":
								_button.width = _buttonLen;
								_button.height= _dividerThickness+1;
								_button.x = (unscaledWidth/2) - (_button.width/2);
								_button.setStyle("icon",Arrow_Up);
								_button.setStyle("selectedOverIcon",Arrow_Down);
								_button.setStyle("selectedUpIcon",Arrow_Down);
								_button.setStyle("selectedDownIcon",Arrow_Down);
								_button.selected = (this._resizeTarget.height <=0);
								break;
							case "bottom":
								_button.width = _buttonLen;
								_button.height= _dividerThickness+1;
								
								_button.x = (unscaledWidth/2) - (_button.width/2);
								_button.y = -1;
								_button.setStyle("icon",Arrow_Down);
								_button.setStyle("selectedOverIcon",Arrow_Up);
								_button.setStyle("selectedUpIcon",Arrow_Up);
								_button.setStyle("selectedDownIcon",Arrow_Up);
								_button.selected = (this._resizeTarget.height <=0);
								break;
							case "left":
								_button.width = _dividerThickness+1;
								_button.height= _buttonLen;
								
								_button.y = (unscaledHeight/2) - (_button.height/2);
								
								_button.setStyle("icon",Arrow_Left);
								_button.setStyle("selectedOverIcon",Arrow_Right);
								_button.setStyle("selectedUpIcon",Arrow_Right);
								_button.setStyle("selectedDownIcon",Arrow_Right_Click);
								_button.selected = (this._resizeTarget.width <=0);
								break;
							case "right":
								_button.width = _dividerThickness+1;
								_button.height= _buttonLen;
								
								_button.y = (unscaledHeight/2) - (_button.height/2);
								_button.x = -1;
								_button.setStyle("icon",Arrow_Right);
								_button.setStyle("selectedOverIcon",Arrow_Left);
								_button.setStyle("selectedUpIcon",Arrow_Left);
								_button.setStyle("selectedDownIcon",Arrow_Left_Click);
								_button.selected = (this._resizeTarget.width <=0);
								break;
							default:
								break;
						}
						
						//add events to change the mouse pointer 
						//and handle the click (open or close children)
						_button.addEventListener(MouseEvent.CLICK, handleClick,false,0,true);
						_button.addEventListener(MouseEvent.MOUSE_OVER, handleOver,false,0,true);
						_button.addEventListener(MouseEvent.MOUSE_OUT, handleOut,false,0,true);
						//						_button.setStyle("cornerRadius",0);
						divbar.addChild(_button);
						
						this.ButtonSelected = _button.selected;
					}
				}
			//} 
 			Draw_Gradient_Fill();
		}

		private function setResize():void
		{
			_openResize = new Resize();
			_openResize.target = _resizeTarget;
			_openResize.duration = _duration;
			
			_closeResize = new Resize();
			_closeResize.target = _resizeTarget;
			_closeResize.duration = _duration;
			
			(_resizeTarget as UIComponent).addEventListener(Event.RESIZE,onResize,false,0,true);
		}
		
		//create the gradient and apply tothe box controle
		private var _fillType:String = GradientType.LINEAR;
		private var _alphas:Array = [1,1];
		private var _ratios:Array = [0,255];
		private var _spreadMethod:String = SpreadMethod.REFLECT;
		
		//private var _button:Button; 
		
		private var _BoxDivider:Array = [];
		
		private var _barFillColors:Array;	
		
		private var _barBorderColor:uint;	
		
		[Embed(source="/assets/Arrow_Down.png")]
		private var Arrow_Down:Class;
		
		[Embed(source="/assets/Arrow_Up.png")]
		private var Arrow_Up:Class;
		
//		[Embed(source="/assets/Arrow_Left.png")]
		[Embed(source="/assets/DividerLeft.png")]
		private var Arrow_Left:Class;
		
//		[Embed(source="/assets/Arrow_Right.png")]
		[Embed(source="/assets/DividerRight.png")]
		private var Arrow_Right:Class;
		
		[Embed(source="/assets/DividerLeftClick.png")]
		private var Arrow_Left_Click:Class;
		
		//		[Embed(source="/assets/Arrow_Right.png")]
		[Embed(source="/assets/DividerRightClick.png")]
		private var Arrow_Right_Click:Class;
		
		private var _ButtonOnIndexs:Array;
		private var _showButton:Boolean=true;
		private var _isOverButton:Boolean;
		
		private var _button:Button;
		
		private var _closeResize:Resize;
		private var _openResize:Resize;
		
		private var _duration:Number = 100;
		
		//		[Bindable]
		private var _containerIsVisable:Boolean = true;
		
		//收缩的目标
		private var _resizeTarget:UIComponent;
		
		//收缩样式 top：往上  bottom：往下 left：往左 right：右
		private var _dvStyle:String;
		
		//按钮宽度
		private var _buttonLen:Number = 80;
		//按钮高度和分隔符宽度
		private var _dividerThickness:Number = 6;
		//收缩的宽带
		private var _shrinkLen:Number = 300;
		
		private var _curLen:Number = 0;
		
		private function initApp(e:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE,initApp);
			
			var tmpDivThickness:Number = getStyle("dividerThickness");
			if (!isNaN(tmpDivThickness))
				_dividerThickness = tmpDivThickness;
			
			this.setStyle("dividerThickness",_dividerThickness);
			//实时刷新
			//this.liveDragging = true;
			this.resizeToContent = true;
			
			switch (_dvStyle)
			{
				case "top":
				case "bottom":
					this.direction = "vertical"
					_openResize.heightTo = _shrinkLen;
					_closeResize.heightTo = 0;
					break;
				case "left":
				case "right":
					this.direction = "horizontal"
					_openResize.widthTo = _shrinkLen;
					_closeResize.widthTo = 0;
					break;
				default:
					break;
			}
			
			this.addEventListener(DvBtnClickEvent.DV_BTN_CLICK_EVENT,onButtonClick,false,0,true);
		}
		
		/**
		 *
		 * @param e
		 *
		 */
		private function onResize(e:Event):void
		{
			switch (_dvStyle)
			{
				case "top":
				case "bottom":
					if (e.currentTarget.height > _dividerThickness && this.ButtonSelected != false)
					{
						this.ButtonSelected=false;
					}
					else
					{
						if (e.currentTarget.height <= _dividerThickness)
						{
							this.ButtonSelected=true;
							e.currentTarget.height = 0;
						}
					}
					break;
				case "left":
				case "right":
					if (e.currentTarget.width > _dividerThickness)
					{
						if(this.ButtonSelected != false)
						   this.ButtonSelected=false;
					}
					else
					{
						if (e.currentTarget.width <= _dividerThickness)
						{
							this.ButtonSelected=true;
							e.currentTarget.width = 0;
						}
					}
					break;
				default:
					break;
			}
		}
		
		
		private function verifyButtonIndex(value:int):Boolean
		{
			
			for(var i:int=0;i < _ButtonOnIndexs.length;i++)
			{
				if (value == _ButtonOnIndexs[i]){
					return true;
				}
			}
			
			return false;
			
		}		
		
		/**
		 * 分隔符大小改变时，改变button的位置
		 * @param event
		 *
		 */
		private function handleResize(event:ResizeEvent):void
		{
			if(!_showButton)
				return;
			
			if (event.currentTarget.width != event.oldWidth || event.currentTarget.height != event.oldHeight)
			{
				for(var i:int=0;i < numDividers;i++) 
				{
					var divbar:BoxDivider = getDividerAt(i);
					
					var tempButton:Button = Button(divbar.getChildByName("SplitterButton" + i));
					
					if (tempButton)
					{
						if (direction == "vertical")
						{
							tempButton.x = (unscaledWidth/2) - (tempButton.width/2);
						}
						else
						{
							tempButton.y = (unscaledHeight/2) - (tempButton.height/2);
						}
					}	
				}
			}
		}
		
		//event handlers for the button
		private function handleClick(event:MouseEvent):void
		{
			dispatchEvent(new DvBtnClickEvent(DvBtnClickEvent.DV_BTN_CLICK_EVENT,event.currentTarget,Boolean(event.currentTarget.selected)));
		}
		
		//trap these event when around the button to make the 
		//extended slider behave as we require
		private function handleOut(event:MouseEvent):void
		{
			_isOverButton=false;
		}
		private function handleOver(event:MouseEvent):void
		{
			_isOverButton=true;
		}
		
		/**
		 * 重绘分隔符
		 *
		 */
		private function Draw_Gradient_Fill():void
		{
			//return;
			graphics.clear();
			
			for(var i:int=0;i < _BoxDivider.length;i++) 
			{
				if (null == _barFillColors)
				{
					_barFillColors = getStyle("barFillColors");
					/*if (!_barFillColors)
					{
					_barFillColors =[0x000000,0x0099FF]; // if no style default to orange
					}*/
				}
				
				if (!isNaN(_barBorderColor))
				{
					_barBorderColor = getStyle("barBorderColor");
					/*if (!_barBorderColor)
					{
					_barBorderColor =0x0099FF; // if no style default to orange
					}*/
				}
				
				if (!isNaN(_barBorderColor))
					graphics.lineStyle(0, _barBorderColor);
				
				if (null == _barFillColors)
					continue;
				var divwidth:Number = _BoxDivider[i].getStyle("dividerThickness");
				
				if (divwidth==0)
					divwidth=10;
				
				var matr:Matrix = new Matrix();
				graphics.lineStyle(1,0xF1F1F1);
				if (direction == "vertical")
				{
					matr.createGradientBox(_BoxDivider[i].width,divwidth,Math.PI/2, _BoxDivider[i].x, _BoxDivider[i].y);
					
					graphics.beginGradientFill(_fillType, _barFillColors, _alphas, _ratios, matr,_spreadMethod);
					graphics.drawRect(_BoxDivider[i].x,_BoxDivider[i].y,_BoxDivider[i].width,divwidth);
					graphics.endFill();
				}
				else
				{
 					graphics.beginGradientFill(_fillType, _barFillColors, _alphas, _ratios, matr,_spreadMethod);
					graphics.drawRect(_BoxDivider[i].x,_BoxDivider[i].y,divwidth, _BoxDivider[i].height);
					graphics.endFill();
					matr.createGradientBox(divwidth,_BoxDivider[i].height ,0, _BoxDivider[i].x, _BoxDivider[i].x+10);
				}
				
				
			}			
		}
		
		
	}
}