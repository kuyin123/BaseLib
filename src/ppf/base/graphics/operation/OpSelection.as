package ppf.base.graphics.operation
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.ui.Keyboard;
	
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.graphics.DataDrawer;
	import ppf.base.graphics.IOpSelection;
	import ppf.base.math.MathUtil;
	import ppf.base.resources.LocaleConst;

	/**
	 * 趋势操作对象
	 * 在当前光标位置显示一条竖线，在竖直线上显示一个或多个TIP（窗口中每个数据对象一个）
	 * 鼠标按下时可移动光标位置
	 */
	public class OpSelection extends DragDrawer implements IOpSelection
	{
		static public const EVENT_SELECT_CHANGED:String="event_select_changed";

		/**
		 * 构造函数
		 * @param canvas ChartCanvas
		 * @param bUseKeybord 是否使用键盘控制
		 *
		 */
		public function OpSelection(canvas:ChartCanvas, bUseKeybord:Boolean)
		{
			parentCanvas=canvas;
			if (bUseKeybord)
				useKeyboard=bUseKeybord;
		}
		
		public function get alwaysShowLabel():Boolean
		{
			return _alwaysShowLabel;
		}

		public function set alwaysShowLabel(value:Boolean):void
		{
			_alwaysShowLabel = value;
		}

		/**
		 *刻度文本生成函数 
		 *原型：Function(drawer:DataDrawer, pos:Point, precision:Number):String 
		 */		
		public function get onNeedText():Function
		{
			return _onNeedText;
		}

		public function set onNeedText(value:Function):void
		{
			_onNeedText = value;
		}

		private var _onNeedText:Function=onDefaultNeedText;
		private var _alwaysShowLabel:Boolean=false;
		public var renderOther:Function;

//		/**
//		 * 记录作为更新数据时光标的坐标
//		 */
//		public function set curPoint(value:Point):void
//		{
//			_settingPoint=value;
//		}

		public function get settingPoint():Point
		{
			return _settingPoint;
		}

		public function get localPoint():Point
		{
			if (null == _canvas || null == _selPos)
				return new Point(-1, -1);
			var p0:Point=new Point(_selPos.x, 0);
			p0=_canvas.worldToLocal(p0);
			return p0;
		}
		
		public function set parentCanvas(value:ChartCanvas):void
		{
//			if(null != value)
//				value.operation = this;
			_canvas = value;
		}
		
		public function set useKeyboard(has:Boolean):void
		{
			if(has)
			{
				_canvas.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				_canvas.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			}
		}

		/**
		 *
		 *
		 */
		public function get curPoint():Point
		{
			return _selPos;
		}

		public function get selPosX():Number
		{
			return (_selPos == null) ? Number.NEGATIVE_INFINITY : _selPos.x;
		}

		public function get selIndex():int
		{
			if (null == _selPosYList || _selPosYList.length == 0)
				return -1;
			return _selPosYList[0].index;
		}
		
		public function get currentDrawer():DataDrawer
		{
			if (_currentDrawer < 0 || _currentDrawer >= _canvas.dataDrawers.numChildren)
				_currentDrawer=0;
			if (_canvas.dataDrawers.numChildren == 0)
				return null;
			return _canvas.dataDrawers.getChildAt(_currentDrawer) as DataDrawer;
		}

		/**
		 * 方法
		 */

		/**
		 * 根据指定的像素坐标，确定当前趋势对象的下标
		 */
		public function selectCurrentTrend(posMouse:Point):void
		{
			var nearestY:Number=Number.POSITIVE_INFINITY;
			var drawer:DataDrawer;
			var len:int=_canvas.dataDrawers.numChildren;
			var i:Number;
			var curP:Point;
			var pos:Point;
			var y:Number;
			for (var j:int=0; j < len; j++)
			{
				drawer=_canvas.dataDrawers.getChildAt(j) as DataDrawer;
				if (null == drawer)
					continue;

				_canvas.currentAxis=drawer.axisName;
				pos=_canvas.localToWorld(posMouse);
				// find in data			
				i=drawer.indexOfWaveX(pos.x,pos.y);
				if (i == -1)
					continue;
				curP=drawer.getPointByIndex(i);
				if (null == curP)
					continue;
				y=curP.y;
				if (Math.abs(nearestY - pos.y) > Math.abs(y - pos.y))
				{
					nearestY=y;
					_currentDrawer=j;
				}
			}

			_canvas.currentAxis=null;
		}

		public function setByIndex (index:Number, needEvent:Boolean=true):Number
		{
			_settingPoint=null;
			_selPosYList=[];
			var len:Number=_canvas.dataDrawers.numChildren;
			var drawer:DataDrawer;
			var curP:Point;
			var x:Number;
			var outObj:Object;
			for (var j:int=0; j < len; j++)
			{
				drawer=_canvas.dataDrawers.getChildAt(j) as DataDrawer;
				if (null == drawer)
					continue;
				// find in data			
				curP=drawer.getPointByIndex(index);
				if (null == curP)
				{
					while (index>=1 && curP == null)
					{
						index--;
						curP = drawer.getPointByIndex(index);
					}
				}
				if (null == curP)
					continue;
				x=curP.x;
				if (drawer.hasOwnProperty("selectChangedFunction") && drawer.selectChangedFunction is Function)
					curP=drawer.selectChangedFunction(index, curP, this, drawer);
				
				if (null == curP)
					continue;
				outObj={};
				outObj.x=curP.x;
				outObj.y=curP.y;
				outObj.index=index;
				outObj.drawerId=j;
				_selPosYList.push(outObj);
			}
			
			if (_selPosYList.length)
				_selPos=new Point(_selPosYList[0].x, _selPosYList[0].y);
			else
				_selPos=null;
			
			invalidate();
			
			if (needEvent)
				disEventSelectChanged();
			
			if (null != _selPos)
				return _selPos.x;
			
			return -1;
		}
		
		public function setSelPos(posX:Number, posY:Number=NaN, needEvent:Boolean=true):Number
		{
			if (posX == Number.NEGATIVE_INFINITY || posX == Number.POSITIVE_INFINITY)
				_selPos=null;
			else
			{
				_settingPoint=new Point(posX, posY);
				var mousePoint:Point = _canvas.worldToLocal(new Point(posX, isNaN(posY) ? 0 : posY));
				_selPosYList=[];
				var nearestX:Number=Number.POSITIVE_INFINITY;
				var nearestPoint:Point;

				var len:Number=_canvas.dataDrawers.numChildren;
				var drawer:DataDrawer;
				var i:Number;
				var curP:Point;
				var x:Number;
				var outObj:Object;
				for (var j:int=0; j < len; j++)
				{
					drawer=_canvas.dataDrawers.getChildAt(j) as DataDrawer;
					if (null == drawer)
						continue;

					// find in data	
					_canvas.currentAxis = drawer.axisName;
					var drawerP:Point = _canvas.localToWorld(mousePoint);
					_canvas.currentAxis = null;
					i=drawer.indexOfWaveX(drawerP.x, isNaN(posY) ? NaN : drawerP.y);
					curP=drawer.getPointByIndex(i, drawerP.x);
					if (null == curP)
						continue;
					x=curP.x;
					if (drawer.hasOwnProperty("selectChangedFunction") && drawer.selectChangedFunction is Function)
						curP=drawer.selectChangedFunction(i, curP, this, drawer);
					if (Math.abs(nearestX - posX) > Math.abs(x - posX))
					{
						nearestX=x;
						if(curP!=null)
							nearestPoint=curP;
					}

					outObj={};
					outObj.x=curP.x;
					outObj.y=curP.y;
					outObj.index=i;
					outObj.drawerId=j;
					_selPosYList.push(outObj);
				}

				if (null == nearestPoint)
				{
					_selPos=null;
				}
			
				else
					_selPos=new Point(nearestX, nearestPoint.y);
			}

			invalidate();

			if (needEvent)
				disEventSelectChanged();

			if (null != _selPos)
				return _selPos.x;

			return -1;
		}

		protected function disEventSelectChanged():void
		{
			dispatchEvent(new Event(EVENT_SELECT_CHANGED));
		}
		
		/**
		 * 根据坐标获取刻度文本
		 * pos：目标点的值 （Point）
		 */
		public function onDefaultNeedText(drawer:DataDrawer, pos:Point, precision:Number):String
		{
			if (!isNaN(precision))
				return pos.y.toFixed(precision);//改用Number 取精度时当数字太大时会出现越界
			return pos.y.toFixed(2);//改用Number 取精度时当数字太大时会出现越界
//				return MathUtil.n2s(pos.y, precision);
//			return MathUtil.n2s(pos.y, _precision);
		}

		override protected function onRemoved():void
		{
			clearTips();
		}

		override protected function onMouseDown(e:MouseEvent):void
		{
			super.onMouseDown(e);
			_canvas.setFocus();
		}

		// 鼠标按下并移动的处理函数
		override protected function onMouseDrag(e:MouseEvent):void
		{
			super.onMouseDrag(e);
			if (null != parentCanvas)
			{
				isNewclick=false;
				var p:Point=new Point(mouseX, mouseY);
				var currP:Point=parentCanvas.localToWorld(p);
				setSelPos(currP.x, currP.y);
				selectCurrentTrend(p);
			}
		}

		override protected function onMouseUp(e:MouseEvent):void
		{
			super.onMouseUp(e);
			if (!alwaysShowLabel)
				this.invalidate();
		}

		protected function onKeyDown(e:KeyboardEvent):void
		{
			var r:ChartRect;
			var drawer:DataDrawer;
			var p:Point;
			var minX:Number;

			if (e.keyCode == Keyboard.ESCAPE) // 取消选择
			{
//				if (null != curPoint)
//					this.curPoint.x=Number.NEGATIVE_INFINITY;
				this.setSelPos(Number.NEGATIVE_INFINITY);
			}
			else if (e.ctrlKey)
			{ // 缩放
				switch (e.keyCode)
				{
					case Keyboard.LEFT: // 水平放大
						if (selPosX == Number.NEGATIVE_INFINITY)
							_canvas.zoom(_canvas.enableZoom ? 0.8 : 1, 0, new Point(_canvas.extent.left + _canvas.extent.width * 0.5, 0), false, true);
						else
							_canvas.zoom(_canvas.enableZoom ? 0.8 : 1, 0, new Point(selPosX, 0), false, true);
						break;
					case Keyboard.RIGHT: // 水平缩小
						if (selPosX == Number.NEGATIVE_INFINITY)
							_canvas.zoom(_canvas.enableZoom ? 1.2 : 1, 0, new Point(_canvas.extent.left + _canvas.extent.width * 0.5, 0), false, true);
						else
							_canvas.zoom(_canvas.enableZoom ? 1.2 : 1, 0, new Point(selPosX, 0), false, true);
						break;
					case Keyboard.DOWN: // Y方向缩小
						_canvas.zoom(0, _canvas.enableZoom ? 0.8 : 1, _canvas.extent.center, false, true);
						break;
					case Keyboard.UP: // Y方向放大
						_canvas.zoom(0, _canvas.enableZoom ? 1.2 : 1, _canvas.extent.center, false, true);
						break;
				}
			}
			else  if (e.shiftKey)
			{ // 平移
				switch (e.keyCode)
				{
					case Keyboard.DOWN: // 向上移动
					{
						if (_canvas.enableMoveY)
						{
							r=_canvas.extent.clone();
							r.offset(0, r.height * 0.1);
							_canvas.setExtent(r, true, true);
						}
						break;
					}
					case Keyboard.UP: // 向下移动
					{
						if (_canvas.enableMoveY)
						{
							r=_canvas.extent.clone();
							r.offset(0, -r.height * 0.1);
							_canvas.setExtent(r, true, true);
						}
						break;
					}
					case Keyboard.LEFT: // 向左移动
					{
						if (_canvas.enableMoveX)
						{
							r=_canvas.extent.clone();
							r.offset(r.width * 0.1, 0);
							_canvas.setExtent(r, true, true);
						}
						break;
					}
					case Keyboard.RIGHT: // 向右移动
					{
						if (_canvas.enableMoveX)
						{
							r=_canvas.extent.clone();
							r.offset(-r.width * 0.1, 0);
							_canvas.setExtent(r, true, true);
						}
						break;
					}
					case Keyboard.HOME: // 移动到第一个点
					{
						// 获取左边最近的点
						minX=Number.POSITIVE_INFINITY;
						for (var j:int=0; j < _canvas.dataDrawers.numChildren; j++)
						{
							drawer=_canvas.dataDrawers.getChildAt(j) as DataDrawer;
							p=drawer.getPointByIndex(0);
							if (null == p) // null == p 说明所有不存在，不做动作
								continue;
							else if (minX > p.x) // 移动到新的位置
								minX=p.x;
						}

						if (minX == Number.POSITIVE_INFINITY)
							break; // 无数据，无效操作

						this.setSelPos(minX);
						if (selPosX < _canvas.extent.minX || selPosX > _canvas.extent.maxX)
						{
							r=_canvas.extent;
							r.offset(selPosX - r.width * 0.1 - _canvas.extent.minX, 0);
							_canvas.setExtent(r, true, true);
						}
					}
						break;
					case Keyboard.END: // 移动到最后一个点
					{
						// 获取左边最近的点
						var maxX:Number=Number.NEGATIVE_INFINITY;
						for (var k:int=0; k < _canvas.dataDrawers.numChildren; k++)
						{
							drawer=_canvas.dataDrawers.getChildAt(k) as DataDrawer;
							p=drawer.getPointByIndex(drawer.length - 1);
							if (null == p) // null == p 说明所有不存在，不做动作
								continue;
							else if (maxX < p.x) // 移动到新的位置
								maxX=p.x;
						}

						if (maxX == Number.NEGATIVE_INFINITY)
							break; // 无数据，无效操作

						this.setSelPos(maxX);
						if (selPosX < _canvas.extent.minX || selPosX > _canvas.extent.maxX)
						{
							r=_canvas.extent;
							r.offset(selPosX - r.width * 0.9 - _canvas.extent.minX, 0);
							_canvas.setExtent(r, true, true);
						}
					}
						break;
				}
			}
			else
			{ // 移动光标
				alwaysShowLabel=true;
				switch (e.keyCode)
				{
					case Keyboard.LEFT: // 左移光标
					case Keyboard.RIGHT: // 右移光标
					{
						var invertParam:Number=1;
						if (e.keyCode == Keyboard.RIGHT)
							invertParam=-1;
						
						// 计算10个像素对应的距离 minStepSizeX
						var minStepSizeX:Number=(_canvas.extent.width / _canvas.clipRect.width) * 10;
						
						// 获取左边最近的点
						var minCurrentX:Number=Number.POSITIVE_INFINITY;
						minX=Number.POSITIVE_INFINITY;
						
						var len:Number=_selPosYList.length;
						var selObj:Object;
						var drawerId:int;
						var maxL:int = 0;
						for (var i:int=0; i < len; i++)//记录最长的条数
						{
							selObj=_selPosYList[i];
							drawerId=selObj.drawerId as int;
							drawer=_canvas.dataDrawers.getChildAt(drawerId) as DataDrawer;
							if(drawer.pointX&&drawer.pointX.length>=maxL)
								maxL = drawer.pointX.length;
						}
						
						for (var i:int=0; i < len; i++)
						{
							selObj=_selPosYList[i];
							drawerId=selObj.drawerId as int;
							drawer=_canvas.dataDrawers.getChildAt(drawerId) as DataDrawer;
							var index:Number=selObj.index;
							if ((selObj.x - selPosX) * invertParam >= 0)
								index-=invertParam;
							if (index < 0)
								index=0;
							
							p=drawer.getPointByIndex(index);
							if (null == p)
							{ // null == p 说明所有不存在，既越界了，此时回退
								if(drawer.pointX== null ||drawer.pointX.length == maxL)
									index+=invertParam;
								p=drawer.getPointByIndex(index);
							}
							
							if(null == p)
								break;
							
							if (Math.abs(minX - selPosX) > Math.abs(p.x - selPosX))
							{
								minX=p.x;
								minCurrentX=selObj.x;
							}
						}
						
						// 如果最近的点太近，小于10个像素，责按像素移动 暂时禁用此项设计  2013-1-25 17:27
//						if (Math.abs(minX - selPosX) < minStepSizeX)
//							minX=selPosX - minStepSizeX * invertParam;
						
						// 移动到新的位置
						this.setSelPos(minX);
						if (selPosX < _canvas.extent.minX || selPosX > _canvas.extent.maxX)
						{
							r=_canvas.extent;
							r.offset(selPosX - (_canvas.extent.minX + _canvas.extent.maxX) / 2, 0);
							_canvas.setExtent(r, true, true);
						}
						break;
					}
				}
			}

			//光标选择
			if (null == _canvas.operation)
				this.invalidate();

			e.updateAfterEvent();
			e.stopImmediatePropagation();
		}

		protected function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SHIFT)
			{
				alwaysShowLabel=!alwaysShowLabel;
				this.invalidate();
			}
		}

		override protected function onRender(canvas:ChartCanvas):void
		{
			try
			{
				this.clearTips();

				var r:ChartRect=canvas.extent;
 				var p0:Point=new Point(_selPos.x, r.top);
				var p1:Point=new Point(_selPos.x, r.bottom);
				p0=canvas.worldToLocal(p0);
				p1=canvas.worldToLocal(p1);
				this.graphics.lineStyle(0, selectColor);
				this.graphics.moveTo(p0.x, p0.y)
				this.graphics.lineTo(p1.x, p1.y);
				
				drawTips(canvas, selectColor);

				if (null != renderOther)
					renderOther(this, canvas);
				
				if (_isNeedEvent)
				{
					dispatchEvent(new Event(EVENT_SELECT_CHANGED));
					_isNeedEvent=false;
				}
			}
			catch (e:Error)
			{

			}
		}

		protected function sortByY(a:Object, b:Object):Number
		{
			var pa:Point=a.posLocal as Point;
			var pb:Point=b.posLocal as Point;

			if (pa.y > pb.y)
			{
				return -1;
			}
			else if (pa.y < pb.y)
			{
				return 1;
			}
			else
			{
				//aPrice == bPrice
				return 0;
			}
		}

		protected function clearTips():void
		{
			if (null != _tips && null != _tips.parent)
			{
				_tips.parent.removeChild(_tips);
				_tips=null;
			}
		}

		protected function drawTips(canvas:ChartCanvas, selColor:Number):void
		{
			if (null == _selPos || _selPos.x == Number.NEGATIVE_INFINITY)
				return;

			var obj:Object;
			var YOrderArr:Array=[];

			var len:Number=_selPosYList.length;
			var selObj:Object;
			var drawerId:int;
			var drawer:DataDrawer;
			for (var i:int=0; i < len; i++)
			{
				selObj=_selPosYList[i];
				drawerId=selObj.drawerId as int;
				drawer=canvas.dataDrawers.getChildAt(drawerId) as DataDrawer;
				canvas.currentAxis=drawer.axisName;
				var pSel:Point=new Point(selObj.x, selObj.y); //drawer.getPointByIndex(id);

				//无数据时
				if (isNaN(pSel.x) || isNaN(pSel.y))
					continue;

				obj={};
				obj.drawer=drawer;
				obj.pos=pSel;
				obj.index=selObj.index;
				pSel=canvas.worldToLocal(pSel);
				obj.posLocal=pSel;
				YOrderArr.push(obj);

				this.graphics.lineStyle(2, selColor);
				this.graphics.beginFill(selColor);
				this.graphics.drawCircle(pSel.x, pSel.y, 3);
				this.graphics.endFill();
			}

//			curPoint=pSel;
			canvas.currentAxis=null;

			// 如果没有选择总是显示标注，而且又不在拖动状态，则不显示标注
			if (!(alwaysShowLabel || isDraging))
				return;

			_tips=new Sprite;
			//	_selPosYList = [];
			// 按照选中处的Y从大到小排序
			YOrderArr.sort(sortByY);
			var limitRect:Rectangle=canvas.clipRect;
			for (var j:int=0; j < YOrderArr.length; j++)
			{
				obj=YOrderArr[j];
				//无数据时
				if (isNaN(obj.pos.x) || isNaN(obj.pos.y))
					continue;

				canvas.currentAxis=(obj.drawer as DataDrawer).axisName;

				var r:Rectangle=drawOneTip(_tips, canvas, obj.pos as Point, obj.drawer as DataDrawer, limitRect);
				limitRect.bottom=Math.min(r.top - r.height / 2 - 5, limitRect.bottom - r.height - 5); //Math.min(tip.y - 15, limitRect.bottom - 30);
			}

			_tips.mouseChildren=false;
			_tips.mouseEnabled=false;
			canvas.frontDrawers.addChild(_tips);
			canvas.currentAxis=null;
		}

		/** 绘制一个标注
		 * @param sel 标注的位置
		 * @param limitRect 外框限制，当标签在此矩形之外时自动调整到此矩形内（仅调整Y方向）
		 */
		protected function drawOneTip(drawTo:Sprite, canvas:ChartCanvas, sel:Point, drawer:DataDrawer, limitRect:Rectangle):Rectangle
		{
			const triDistance:int=7;
			const textDistance:int=7;
			const triHalfHeight:int=6;
			var pos:Point=canvas.worldToLocal(sel);
			var r:ChartRect=canvas.extent;

			var labelFillColor:Number=(labelColor == Number.MAX_VALUE) ? drawer.color : labelColor;

			// create text ----------------
			var str:String=onNeedText(drawer, sel, drawer.precision) + ((onNeedText != onDefaultNeedText) ? "" : (" " + drawer.unitName));
			var textObj:TextField=new TextField;
			var fmt:TextFormat=new TextFormat();
			fmt.font=LocaleConst.FONT_FAMILY;
			fmt.align="right";
			fmt.size=10;
			textObj.setTextFormat(fmt);
			textObj.textColor=labelTextColor; //~drawer.color;
			//textObj.autoSize = TextFieldAutoSize.CENTER;			
			// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
			textObj.text=str;
			if (textObj.width < textObj.textWidth)
				textObj.width=textObj.textWidth+5;
			textObj.selectable=false;
			var labelBox:Rectangle=new Rectangle(8, -textObj.textHeight / 2, textObj.textWidth, textObj.textHeight);
			var tip:Sprite=new Sprite;
			labelBox.inflate(10, 5);
			labelBox.x=8;
			if (sel.x > r.center.x) // left box
				labelBox.x-=(labelBox.left + labelBox.right);

			var triCenter:Number=0;
			if ((pos.y + labelBox.bottom) > limitRect.bottom)
			{
				labelBox.y=limitRect.bottom - pos.y - labelBox.height;
				if ((limitRect.bottom - pos.y) < triHalfHeight)
					triCenter=-(triHalfHeight - (limitRect.bottom - pos.y));
			}
			if ((pos.y + labelBox.top) < limitRect.top)
			{
				labelBox.y=limitRect.top - pos.y;
				if ((pos.y - limitRect.top) < triHalfHeight)
					triCenter=triHalfHeight - (pos.y - limitRect.top);
			}

			// draw back rectangle
			tip.graphics.beginFill(labelFillColor, ChartColor.alphaTip);
			tip.graphics.drawRect(labelBox.x, labelBox.y, labelBox.width, labelBox.height);

			// draw arrow
			tip.graphics.moveTo(0, 0);
			if (sel.x > r.center.x) // left box
			{
				tip.graphics.lineTo(labelBox.right, triCenter + triHalfHeight);
				tip.graphics.lineTo(labelBox.right, triCenter - triHalfHeight);
			}
			else
			{
				tip.graphics.lineTo(labelBox.left, triCenter + triHalfHeight);
				tip.graphics.lineTo(labelBox.left, triCenter - triHalfHeight);
			}

			tip.graphics.endFill();

			// draw text
			textObj.x=labelBox.x + 10;
			textObj.y=(labelBox.top + labelBox.bottom) / 2 - textObj.textHeight / 2;
			tip.addChild(textObj);

			tip.x=pos.x;
			tip.y=pos.y;
			drawTo.addChild(tip);
			labelBox.x=pos.x;
			labelBox.y=pos.y;

			return labelBox;
		}


		public function get selectColor():Number
		{
			return (_selectColor == Number.MAX_VALUE) ? ChartColor.selectLine2 : _selectColor;
		}

		public function set selectColor(color:Number):void
		{
			_selectColor=color;
		}

		public function get labelTextColor():Number
		{
			return (_labelTextColor == Number.MAX_VALUE) ? ChartColor.tipText : _labelTextColor;
		}

		public function set labelTextColor(color:Number):void
		{
			_labelTextColor=color;
		}

		// 存储选中趋势在点的坐标，数组中元素都是Object类型
		// 格式为：
		//	Object {
		//		var x:Number;
		//		var y:Number;
		//		var index:Number;
		//		var drawerId:int;
		//	}
		public function get selInfoList():Array
		{
			return _selPosYList;
		}

		public var labelColor:Number=Number.MAX_VALUE;

		// _Canvas.backDrawers[currentDrawer] 为当前鼠标选中的TrendDrawer
		// 当 _Canvas.backDrawers 发生变化时，currentDrawer 有可能是无效的
		protected var _canvas:ChartCanvas;
		private var _currentDrawer:int=0;
		protected var _selPos:Point;
		protected var _tips:Sprite=new Sprite;
		private var _selectColor:Number=Number.MAX_VALUE;
		private var _labelTextColor:Number=Number.MAX_VALUE;

		/**
		 * 存储选中趋势在点的坐标，数组中元素都是Object类型
		 * 格式为：
		 * Object {
		 * var x:Number;
		 * 	var y:Number;
		 *  var index:int;
		 *  var drawerId:int;
		 * }
		 */
		protected var _selPosYList:Array=[];

		private var _isNeedEvent:Boolean=false;

		protected var _precision:int=5; //显示精度

		private var _settingPoint:Point;
	}
}
