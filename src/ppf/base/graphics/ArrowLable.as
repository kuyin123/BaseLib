package ppf.base.graphics
{
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.controls.Button;
	import mx.events.FlexEvent;
 	import mx.utils.ColorUtil;
	
	import ppf.base.math.MathUtil;
	import ppf.base.resources.LocaleConst;
	
	/**
	 * 带引线的动态标注类
	 * 创建此对象后,可通过 text 属性设置标注文本内容，矩形框的像素位置，指引点在数据坐标的位置
	 * 将对象添加到视图中即可
	 * 
	 * 此类支持鼠标挪动，通过 enabelEdit 控制是否允许拖动
	 * 
	 * @author luoliang
	 * 
	 */
	public class ArrowLable extends Sprite
	{
		/**
		 * 构造函数
		 */		
		public function ArrowLable()
		{
			super();
			_fmt.font=LocaleConst.FONT_FAMILY;
			_fmt.size = 12;
			this.addChild(rectObj);
			this.addChild(textObj);
			this.addChild(btn_back);
			
			this.addChild(btn);
			btn_back.visible = false;
			
			btn.graphics.beginFill(0xFF0000);
			btn.graphics.drawRect(0, 0, 12, 12);
			btn.graphics.endFill();
			
			btn.graphics.lineStyle(2,0xFFFFFF);
			btn.graphics.moveTo(1,1);
			btn.graphics.lineTo(11,11);
			btn.graphics.moveTo(0,11);
			btn.graphics.lineTo(11,1);
			btn.visible = false;
			
			this.hitArea = rectObj;
//			textObj.mouseEnabled = false;//禁用鼠标事件   否则会导致热点区域范围不准确
//			mouseChildren = false;
			if (_enabelEdit)
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 10, true);
			
		}
		//删除按钮
		private var btn:Sprite = new Sprite;
		//删除按钮的背景
		private var btn_back:Sprite = new Sprite;
		/// 记录指引点在世界坐标系中的位置，此值由外部使用，在本类中没有用到
		public var worldPosition:Point;
		/// 当此值设置为true，当点击此对象时，自动将此对象的显示顺序到最前面
		public var frontWhenClicked:Boolean = false;
		public var unitName:String;
		/// 是否允许编辑，设置为true时可以用鼠标拖动标注的位置
		public function get enabelEdit():Boolean
		{
			return _enabelEdit;
		}
		/**
		 * 是否允许编辑 
		 * @param ena
		 */		
		public function set enabelEdit(ena:Boolean):void
		{
			if (_enabelEdit == ena)
				return;
				
			_enabelEdit = ena;
			if (ena)
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			else
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/**
		 * 设置标注的文本内容 
		 * @param str : 标注的文本内容
		 */
		public function set text(str:String):void
		{
			textObj.setTextFormat(_fmt);
			textObj.textColor = textColor;
			textObj.selectable=false;
			textObj.text = str;
			textObj.autoSize = TextFieldAutoSize.CENTER;
			textObj.x = (_bkRect.left + _bkRect.right)/2 - textObj.width/2;//设置成上下居中
			textObj.y = (_bkRect.top + _bkRect.bottom)/2 - textObj.height/2;
			
			apply();
		}
		
		/**
		 * 设置标注的像素矩形外框
		 * @param r 矩形外框
		 */
		public function set rect(r:Rectangle):void
		{
			_bkRect = r.clone();
			apply();
		}
		
		/**
		 * 矩形框的位置
		 * rectPosition: 0: cenetr	1: left	2: top	3: right 4: bottom
		 */
		public function autoRect(distance:Number, rectPosition:uint = 0):Rectangle
		{
			var w:Number = textObj.width + 10;//* 1.2  改成左右各占5个像素
			var h:Number = textObj.height + 10;
			var center:Point = new Point;
			_distance = distance;
			_rectPosition = rectPosition;
			
			switch (rectPosition)
			{
				case 0:
					break;
				case 1:
					center.x = -(w/2 + distance);
				break;
				case 2:
					center.y = -(h/2 + distance);
				break;
				case 3:
					center.x = (w/2 + distance);
				break;
				case 4:
					center.x = (h/2 + distance);
				break;
			}
			
			_bkRect = new Rectangle(center.x - w/2, center.y - h/2, w, h);
			textObj.x = (_bkRect.left + _bkRect.right)/2 - textObj.width/2;
			textObj.y = (_bkRect.top + _bkRect.bottom)/2 - textObj.height/2;
			apply();
			return _bkRect;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			beginPoint = new Point(mouseX, mouseY);
  			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp,true,20150119, true); 
			this.parent.parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
 			if (frontWhenClicked)
				this.parent.setChildIndex(this, parent.numChildren - 1);
		}

		private function onMouseUp(e:Event):void
		{
			try
			{
				this.parent.parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
 			}
			catch(e:Error)	{}
		}
		
		private  function onMouseMove(e:MouseEvent):void
		{
			if(!e.buttonDown)
			{
				return
			}
			_bkRect.offset(mouseX - beginPoint.x, mouseY - beginPoint.y);
			beginPoint.x = mouseX;
			beginPoint.y = mouseY;
			
			textObj.x = rectObj.x + (_bkRect.left + _bkRect.right)/2 - textObj.width/2;
			textObj.y = rectObj.y + (_bkRect.top + _bkRect.bottom)/2 - textObj.height/2;
			apply();
		}
		//当鼠标滑过tip时显示删除按钮
		private function onMouseOver(e:MouseEvent):void
		{
			btn_back.width = rectObj.width;
			btn_back.visible = true;
			btn.visible = true;
			btn.addEventListener(MouseEvent.MOUSE_DOWN,btn_Close);
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			btn_back.visible = false;
			btn.visible = false;
			
			btn.removeEventListener(MouseEvent.CLICK,btn_Close);
		}
		
		private function btn_Close(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			if(parent)
				parent.removeChild(this);
			if(btn)
				btn.removeEventListener(MouseEvent.CLICK,btn_Close);
		}

		/**
		 * 当参数修改后，重新生成图形
		 */
		private function apply() : void
		{
			if(!this.parent)
			{
				return
			}
			if(!this.parent["parentCanvas"])
			{
				return
			}
  			var rec:Rectangle=this.parent["parentCanvas"].clipRect
		
			
			//计算label能出现的矩形范围
			var wordPoint:Point=this.parent["parentCanvas"].localToGlobal(new Point(rec.x,rec.y))
			var localPoint1:Point=this.globalToLocal(new Point(wordPoint.x,wordPoint.y))//左上的点
			wordPoint=this.parent["parentCanvas"].localToGlobal(new Point(rec.x+rec.width,rec.y+rec.height))
			var localPoint2:Point=this.globalToLocal(new Point(wordPoint.x,wordPoint.y))	//右下的点

			//限制能出现的范围
			if(this._bkRect.x<localPoint1.x)
			{
				_bkRect.x=localPoint1.x
 				textObj.x = _bkRect.x+5
 			}
			if(this._bkRect.x+_bkRect.width>localPoint2.x)
			{
				_bkRect.x=localPoint2.x-textObj.width-5
				textObj.x = _bkRect.x
			}	
			if(this._bkRect.y<localPoint1.y)
			{
				_bkRect.y=localPoint1.y
				textObj.y = _bkRect.y+5
			}if(this._bkRect.y+_bkRect.height>localPoint2.y)
			{
				_bkRect.y=localPoint2.y-_bkRect.height-5
				textObj.y = _bkRect.y 
			}	
			
			
			rectObj.graphics.clear();
			// 绘制背景矩形
			var colors:Array = [0xffeaa2,0xffe178,0xffe178];
			var alphas:Array = [100,100,100];
			var ratios:Array = [0,0xF8,0xFF];
			var myMatrix:Matrix = new Matrix();
			myMatrix.createGradientBox(_bkRect.width, _bkRect.height,Math.PI/2, _bkRect.x, _bkRect.y);
			//			rectObj.graphics.beginFill(color);
			rectObj.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,myMatrix,SpreadMethod.PAD);
			rectObj.graphics.drawRoundRect(_bkRect.x, _bkRect.y, _bkRect.width, _bkRect.height,5,5);
			rectObj.graphics.endFill();
			
			var center:Point = new Point((_bkRect.left + _bkRect.right)/2,
				(_bkRect.top + _bkRect.bottom)/2);
			// 计算从矩形中点到 0，0 点的连线与各边界求交
			// 确定出口中心点
			var dist:Point = new Point(0, 0);
			var ret0:Point = new Point;
			var ret1:Point = new Point;
			var nIntersection:uint = 0;
			var topRight:Point = new Point(_bkRect.right, _bkRect.top);
			var bottomLeft:Point = new Point(_bkRect.left, _bkRect.bottom);
			nIntersection = MathUtil.line2line(center, dist, _bkRect.bottomRight, bottomLeft, ret0, ret1);
			if (nIntersection == 0)
				nIntersection = MathUtil.line2line(center, dist, _bkRect.topLeft, topRight, ret0, ret1);
			
			var p1:Point;
			var p2:Point;
			if (nIntersection > 0)
			{// 水平方向有交点
				var w2:Number = _bkRect.width/4;
				if ((ret0.x - _bkRect.left) < w2/2)
				{
					p1 = new Point (_bkRect.left, ret0.y);
					p2 = new Point (_bkRect.left + w2, ret0.y);
				}
				else if ((_bkRect.right - ret0.x) < w2/2)
				{
					p1 = new Point (_bkRect.right - w2, ret0.y);
					p2 = new Point (_bkRect.right, ret0.y);
				}
				else
				{
					p1 = new Point(ret0.x - w2/2, ret0.y);
					p2 = new Point(ret0.x + w2/2, ret0.y);
				}
			}
			else
			{
				nIntersection = MathUtil.line2line(center, dist, _bkRect.bottomRight, topRight, ret0, ret1);
				if (nIntersection == 0)
					nIntersection = MathUtil.line2line(center, dist, _bkRect.topLeft, bottomLeft, ret0, ret1);
				
				if (nIntersection > 0)
				{// 竖直方向有交点
					var h2:Number = _bkRect.height/4;
					if ((ret0.y - _bkRect.top) < h2/2)
					{
						p1 = new Point (ret0.x, _bkRect.top);
						p2 = new Point (ret0.x, _bkRect.top + h2);
					}
					else if ((_bkRect.bottom - ret0.y) < h2/2)
					{
						p1 = new Point (ret0.x, _bkRect.bottom - h2);
						p2 = new Point (ret0.x, _bkRect.bottom);
					}
					else
					{
						p1 = new Point(ret0.x, ret0.y - h2/2);
						p2 = new Point(ret0.x, ret0.y + h2/2);
					}
				}
			}
			
			graphics.clear();
			if (nIntersection > 0)
			{
				graphics.beginFill(0xffe178);
				graphics.moveTo(p1.x, p1.y);
				graphics.lineTo(p2.x, p2.y);
				graphics.lineTo(dist.x, dist.y);
				graphics.endFill();
			}
			
			btn_back.graphics.beginFill(color);
			btn_back.graphics.drawRoundRect(0,0,rectObj.width,btn.height,1,1);
			btn_back.graphics.endFill();
			
			btn_back.x = _bkRect.left;
			btn_back.y = _bkRect.top - btn.height/2;
			
			btn.x = _bkRect.right - btn.width;
			btn.y = _bkRect.top - btn.height/2;//- btn.height/2;
			
		}
		
		private function on_TextInputFocusHander(e:FocusEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			textObj.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			event.stopImmediatePropagation();
		}
		
		private function _onTextChange20150112(e:Event):void
		{
			_bkRect.width=textObj.width+10
			_bkRect.height=textObj.height+10	
			_bkRect.x=textObj.x-5
			_bkRect.y=textObj.y-5
			
			textObj.x = rectObj.x + (_bkRect.left + _bkRect.right)/2 - textObj.width/2;
			textObj.y = rectObj.y + (_bkRect.top + _bkRect.bottom)/2 - textObj.height/2;
			apply();
		}
		private function on_TextFocusOutHander(e:Event):void
		{
			textObj.selectable = false;
			textObj.type = TextFieldType.DYNAMIC;
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			textObj.removeEventListener(FocusEvent.FOCUS_IN,on_TextInputFocusHander);
			textObj.removeEventListener(FocusEvent.FOCUS_OUT,on_TextFocusOutHander);
			textObj.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			
			_onTextChange20150112(null)
		}
		
		private function on_TextDoubleClick(e:MouseEvent):void
		{
			textObj.selectable = true;
			textObj.type = TextFieldType.INPUT;
			textObj.addEventListener(FocusEvent.FOCUS_IN,on_TextInputFocusHander);
			textObj.addEventListener(FocusEvent.FOCUS_OUT,on_TextFocusOutHander);
			textObj.addEventListener(Event.CHANGE,_onTextChange20150112,false,0,true)
		}
		
		private var _text:String;
		private var _bkRect:Rectangle = new Rectangle(0, 100, 200, 50);	// 背景矩形位置（相对于当前坐标原点）
		private	var _fmt:TextFormat = new TextFormat;
		private var textObj:TextField = new TextField;//文字
		private var rectObj:Sprite = new Sprite;//热点区域
//		private var color:Number = ChartColor.selectLine;
		private var color:Number = 0xffeaa2;
		private var textColor:Number = ~ChartColor.selectLine;
		private var _enabelEdit:Boolean = true;
		private var beginPoint : Point; 	// 拖动编辑时用来记录起点位置
		private var _showCloseBtn:Boolean = false;
		private var _enabelInput:Boolean = false;
		private var _distance:Number = 0;
		private var _rectPosition:uint = 0;

		/**
		 * 是否允许输入 
		 * @param value
		 */		
		public function set enabelInput(value:Boolean):void
		{
			_enabelInput = value;
			
			if(_enabelInput)
			{
				textObj.doubleClickEnabled = true;
				textObj.multiline = true;
				textObj.addEventListener(MouseEvent.DOUBLE_CLICK,on_TextDoubleClick);
			}
		}

		/**
		 * 是否显示删除按钮 
		 * @param value
		 */		
		public function set showCloseBtn(value:Boolean):void
		{
			_showCloseBtn = value;
			
			if(value)
			{
				addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
				addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
			}
		}

	}
}