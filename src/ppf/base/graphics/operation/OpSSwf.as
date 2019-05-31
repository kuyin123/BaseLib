package ppf.base.graphics.operation
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.graphics.DataDrawer;
	import ppf.base.resources.LocaleConst;

	public class OpSSwf extends OpSelection
	{
		public function OpSSwf(canvas:ChartCanvas, bUseKeybord:Boolean)
		{
			super(canvas, bUseKeybord);
		}
		public function get selPos2():Number{return (_selPos2==null)?Number.NEGATIVE_INFINITY:_selPos2.x}
		
		public function get selectColor2():Number
		{
			return (_selectColor2==Number.MAX_VALUE)?0xFF0000:_selectColor2;
		}
		
		public function set selectColor2(color:Number):void
		{
			_selectColor2=color;
		}
		
		
		
		override public function setSelPos(posX:Number,posY:Number=NaN,needEvent:Boolean = true) : Number
		{
			if (posX == Number.NEGATIVE_INFINITY || posX == Number.POSITIVE_INFINITY)
				_selPos=null;
			else
			{
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
					i=drawer.indexOfWaveX(posX, posY);
					curP=drawer.getPointByIndex(i, posX);
					if (null == curP)
						continue;
					x=curP.x;
					if (drawer.hasOwnProperty("selectChangedFunction") && drawer.selectChangedFunction is Function)
						curP=drawer.selectChangedFunction(i, curP, this, drawer);
					if (Math.abs(nearestX - posX) > Math.abs(x - posX))
					{
						nearestX=x;
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
					_selPos=null;
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
		
		
		override protected function onRender(canvas:ChartCanvas):void
		{
			try 
			{
				if (null != _tips2 && null != _tips2.parent)
				{
					_tips2.parent.removeChild(_tips2);
					_tips2 = null;
				}
				
				var r:ChartRect = canvas.extent;
				var p0 : Point = new Point (_selPos.x, r.top);
				var p1 : Point = new Point (_selPos.x, r.bottom);
				p0 = canvas.worldToLocal(p0);
				p1 = canvas.worldToLocal(p1);
				this.graphics.lineStyle(0, _frontPos2?selectColor2:selectColor);
				this.graphics.moveTo(p0.x, p0.y)
				this.graphics.lineTo(p1.x, p1.y);
				
				drawTips(canvas, selectColor);
				
				if (null != renderOther)
					renderOther(this, canvas);
			}
			catch (e:Error)
			{
				
			}
		}
		public function getObjArrIndex(arr:Array):Object
		{
			if(arr.length<1)
				return null;
			var curMouse:Point=new Point(mouseX,mouseY);
			var curpY:Number=parentCanvas.localToWorld(curMouse).y;
			var obj:Object;
			var lenabs:Number=Math.abs(arr[0].pos.y-curpY);
			var len:int=arr.length;
			var i:int=0;
			var index:int=-1;
			for(;i<len;i++)
			{
				obj=arr[i];
				if(Math.abs(obj.pos.y-curpY)<lenabs)
				{
					lenabs=Math.abs(obj.pos.y-curpY);
					index=i;
				}
			}
			return arr[index];
		}
		override protected function drawTips(canvas:ChartCanvas, selColor:Number):void
		{
			if (null == _selPos || _selPos.x == Number.NEGATIVE_INFINITY)
				return;
			
			var obj:Object;
			var YOrderArr : Array = [];
			
			var len:Number = _selPosYList.length;
			var selObj:Object;
			var drawerId:int;
			var drawer:DataDrawer;
			for (var i:int=0; i<len; i++)
			{
				selObj = _selPosYList[i];
				drawerId = selObj.drawerId as int;
				drawer = canvas.dataDrawers.getChildAt(drawerId) as DataDrawer;
				canvas.currentAxis = drawer.axisName;
				var pSel : Point = new Point(selObj.x, selObj.y);	//drawer.getPointByIndex(id);
				pointforZ=new Point(selObj.x, selObj.y);
				//无数据时
				if (isNaN(pSel.x)|| isNaN(pSel.y))
					continue;
				
				obj = {};
				obj.drawer = drawer;
				obj.pos = pSel;
				obj.index = selObj.index;
				pSel = canvas.worldToLocal (pSel);
				obj.posLocal = pSel;
				YOrderArr.push(obj);
				
				this.graphics.lineStyle(2, selColor);
				this.graphics.beginFill(selColor);
				this.graphics.drawCircle (pSel.x, pSel.y, 3);//在曲线上绘制当前选中的点
				this.graphics.endFill();
			}
			
			//curPoint = pSel;
			canvas.currentAxis = null;
			
			// 如果没有选择总是显示标注，而且又不在拖动状态，则不显示标注
			if (!(alwaysShowLabel || isDraging))
				return;
			
			_tips2 = new Sprite;
			//	_selPosYList = [];
			// 按照选中处的Y从小到大排序
			YOrderArr.sort(sortByY);
			var limitRect:Rectangle = canvas.clipRect;
//			for (var j:int = 0; j<YOrderArr.length; j++)
//			{
//				obj = YOrderArr[j];
//				//无数据时
//				if (isNaN(obj.pos.x)|| isNaN(obj.pos.y))
//					continue;
//				
//				canvas.currentAxis = (obj.drawer as DataDrawer).axisName;
//				
//				
//				//				var datadrawerforZ:DataDrawer=obj.drawer as DataDrawer;
//				//				posvalueY=onNeedText(datadrawerforZ, obj.pos as Point,datadrawerforZ.precision);
//				
//				
//				var r:Rectangle = drawOneTip(_tips2, canvas, obj.pos as Point, obj.drawer as DataDrawer,
//					limitRect);
//				limitRect.bottom = Math.min(r.top - r.height/2 - 5, limitRect.bottom - r.height - 5);	//Math.min(tip.y - 15, limitRect.bottom - 30);
//			}
			var objnearest:Object=getObjArrIndex(YOrderArr);
			canvas.currentAxis=(objnearest.drawer as DataDrawer).axisName;
			var r:Rectangle= drawOneTip(_tips2, canvas, objnearest.pos as Point, objnearest.drawer as DataDrawer,
									limitRect);
			_tips2.mouseChildren = false;
			_tips2.mouseEnabled = false;
			canvas.frontDrawers.addChild(_tips2);
			canvas.currentAxis = null;
		}
		
		private function getZ(point:Point,drawer:DataDrawer):Number
		{
			if(drawer.pointArr==null)
				return Number.NEGATIVE_INFINITY;
			var i:int=0;
			var len:int=drawer.pointArr.length;
			var point3darr:Array=drawer.pointArr;
			for(;i<len;i++)
			{
				if(point3darr[i].X==point.x&&point3darr[i].Y==point.y)
					return point3darr[i].Z;
			}
			return -1;
			
		}
		override protected function drawOneTip(drawTo:Sprite, canvas:ChartCanvas, sel:Point, drawer:DataDrawer, limitRect:Rectangle):Rectangle
		{
			const triDistance : int = 7;
			const textDistance : int = 7;
			const triHalfHeight : int = 6;			
			var pos : Point = canvas.worldToLocal(sel);
			var r:ChartRect = canvas.extent;
			
			var labelFillColor:Number =
				(labelColor == Number.MAX_VALUE) ? drawer.color : labelColor;
			
			// create text ----------------
			var str:String =getZ(sel,drawer).toString();
			//			var str:String = onNeedText(drawer, sel,drawer.precision)+((onNeedText != onDefaultNeedText)?"":(" "+drawer.unitName));
			//			var str:String="test";
			var textObj:TextField = new TextField;
			var fmt:TextFormat = new TextFormat();
			fmt.font=LocaleConst.FONT_FAMILY;
			fmt.align="right";
			fmt.size = 10;
			textObj.setTextFormat(fmt);
			textObj.textColor = labelTextColor; //~drawer.color;
			//textObj.autoSize = TextFieldAutoSize.CENTER;			
			// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
			textObj.text = str;
			if (textObj.width < textObj.textWidth)
				textObj.width = textObj.textWidth+5;
			textObj.selectable=false;
			var labelBox : Rectangle = new Rectangle(8, -textObj.textHeight/2, textObj.textWidth, textObj.textHeight);
			var tip:Sprite = new Sprite;
			labelBox.inflate(10, 5);
			labelBox.x = 8;
			if (sel.x > r.center.x)	// left box
				labelBox.x -= (labelBox.left + labelBox.right); 
			
			var triCenter : Number = 0;
			if ((pos.y + labelBox.bottom) > limitRect.bottom)
			{
				labelBox.y = limitRect.bottom - pos.y - labelBox.height;
				if ((limitRect.bottom - pos.y) < triHalfHeight)
					triCenter = - (triHalfHeight - (limitRect.bottom - pos.y));
			}
			if ((pos.y + labelBox.top) < limitRect.top)
			{
				labelBox.y = limitRect.top - pos.y;
				if ((pos.y - limitRect.top) < triHalfHeight)
					triCenter = triHalfHeight - (pos.y - limitRect.top);
			}
			
			// draw back rectangle
			tip.graphics.beginFill(labelFillColor, ChartColor.alphaTip);
			tip.graphics.drawRect(labelBox.x, labelBox.y, labelBox.width, labelBox.height);
			
			// draw arrow
			tip.graphics.moveTo(0, 0);
			if (sel.x > r.center.x)	// left box
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
			textObj.x = labelBox.x + 10;
			textObj.y = (labelBox.top + labelBox.bottom)/2 - textObj.textHeight/2;
			textObj.background=true;
			textObj.backgroundColor=labelFillColor;//设置文字的背景色与矩形框一致
			//使用位图画文字 旋转之后文字不能显示
			var bitmapdata:BitmapData=new BitmapData(textObj.textWidth+2,textObj.textHeight);
			bitmapdata.draw(textObj);
			var bitmap:Bitmap=new Bitmap(bitmapdata);
			bitmap.smoothing=true;
			bitmap.x=textObj.x;
			bitmap.y=textObj.y;
			
			tip.addChild(bitmap);	
			
			tip.x = pos.x;
			tip.y = pos.y;
			
			drawTo.addChild(tip);
			
			labelBox.x = pos.x;
			labelBox.y = pos.y;
			
			return labelBox;
		}
		/**
		 *鼠标当前选中的点
		 */  
		protected var _selPos2:Point;
		
		/**
		 * 当前的移动光标点在 _selPos2前面 true是 false不是
		 */		
		private var _frontPos2:Boolean = false;
		
		private var _selectColor2:Number = Number.MAX_VALUE;
		
		private var _tips2:Sprite = new Sprite;

		private var pointforZ:Point;
	}
}