package ppf.base.graphics.axis
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.IOpSelection;
	import ppf.base.graphics.operation.OpSelection;
	import ppf.base.resources.LocaleConst;
	
	import spark.primitives.Graphic;
	
	/**
	 * X刻度上的选中游标对象
	 *  
	 * @author luoliang
	 * 
	 */	
	public class AxisXFocus extends UIComponent
	{
		private var _selPos : Number = Number.NEGATIVE_INFINITY;
		private var _tips:Sprite = new Sprite;
		private var _op:IOpSelection;
		public var initClipRect : Rectangle;
		public var lableString : String;
		
		public function AxisXFocus(o:IOpSelection = null)
		{
			super();
			if(o) this.selection = o;
			onNeedText = defaultNeedText;
		}
		
		/**
		 * 根据坐标获取刻度文本 (axis:AxisBase,op:IOpSelection):String
		 * @param axis
		 * @param op
		 * @return
		 */		
		public var onNeedText:Function;
		
		public function set selection(o:IOpSelection):void
		{
			_op = o;
			o.addEventListener(OpSelection.EVENT_SELECT_CHANGED, onSelectionChanged, false, 0, true);
			var cav:ChartCanvas = o.parentCanvas;
			cav.addEventListener(ChartCanvas.EVENT_MATRIX_CHANGED, onSelectionChanged, false, 0, true);
		}
		
		private function onSelectionChanged(e:Event):void
		{
			if (null == _op)
				return;
			var cav:ChartCanvas = _op.parentCanvas;
			
			if(null == cav)
				cav = e.target as ChartCanvas;
			if(null == cav)
				return;
			var axisx:AxisX=this.parent as AxisX;
			
			var lp:Point;
			if(null!=axisx)
			{
				cav.currentAxis=axisx.axisName;
				lp = cav.worldToLocal(new Point(_op.selPosX, 0));
			}
				
			cav.currentAxis=null;
			this.selPos = lp.x;
		}

		public function draw () : void
		{
			if (null != _tips && contains(_tips)){
				removeChild(_tips);
			}
			
//			if (null != _op.parentCanvas.operation)
//				return;
			
			if (null != parent)
				initClipRect = new Rectangle(0, 0, parent.width, parent.height); 
				
			if (_selPos == Number.NEGATIVE_INFINITY)
				return;
			//修改日期2013-6-24 下标应先加边框再判断是否在屏幕内  否则导致部分点看不到下标
			_selPos=_selPos+_op.parentCanvas.borderWidth;
				
			if (_selPos < initClipRect.left || _selPos > initClipRect.right)
				return;
							
			try {
				var color : Number = ChartColor.selectLine;
				//刻度文本向右移动BorderWidth个像素
				//修改者：taonengcheng
//				_selPos=_selPos+_op.parentCanvas.borderWidth;
				var tip:Sprite = drawOneTip(_selPos, color, initClipRect);
				_tips = new Sprite;
				_tips.addChild(tip);
				_tips.alpha = ChartColor.alphaTip;
				addChild(_tips);
			}
			catch (e:Error)
			{
				
			}	
		}

		public function get selPos() : Number			{ return _selPos; 		}
		public function set selPos(pos : Number) : void	{	_selPos = pos;	 draw();	}
		
		/** 绘制一个标注
		 * @param sel 标注的位置
		 * @param color 颜色
		 * @param limitRect 外框限制，当标签在此矩形之外时自动调整到此矩形内（仅调整Y方向）
		 */
		protected function drawOneTip(sel:Number, color:Number, limitRect:Rectangle) : Sprite
		{
			const triDistance : int = 7;
			const textDistance : int = 7;
			const triHalfWidth : int = 8;
			var pos : Point = new Point(sel, limitRect.top);
			
			// create text ----------------
			var str:String = onNeedText(this.parent,_op);
			var textObj:TextField = new TextField;
			var fmt:TextFormat = new TextFormat;
			fmt.font=LocaleConst.FONT_FAMILY;
			fmt.size = 10;
			textObj.setTextFormat(fmt);
//			textObj.textColor = ChartColor.axisText;
			textObj.textColor = ChartColor.tipText;
			//textObj.autoSize = TextFieldAutoSize.CENTER;			
			// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
			textObj.text = str;
			if (textObj.width < textObj.textWidth)
				textObj.width = textObj.textWidth+5;
			textObj.selectable=false;
			var labelBox : Rectangle = new Rectangle(-textObj.textWidth/2, 0, textObj.textWidth, textObj.textHeight);
			var tip:Sprite = new Sprite;
			labelBox.height = 20;
			labelBox.inflate(10, 0);
			labelBox.y = triDistance;
			
			var triCenter : Number = 0;
			if ((selPos + labelBox.right) > limitRect.right)
			{
				labelBox.x = limitRect.right - selPos - labelBox.width;
				if ((limitRect.right - selPos) < triHalfWidth)
					triCenter = - (triHalfWidth - (limitRect.right - selPos));
			}
			if ((selPos + labelBox.left) < limitRect.left)
			{
				labelBox.x = limitRect.left - selPos;
				if ((selPos - limitRect.left) < triHalfWidth)
					triCenter = triHalfWidth - (selPos - limitRect.left);
			}
			
			// draw back rectangle
			
			var obj: Object =labelBox ;
			//画黑色边框
			tip.graphics.lineStyle(1,ChartColor.selectLine2,1);
			tip.graphics.beginFill(ChartColor.waveLine);
			tip.graphics.drawRect(labelBox.x, labelBox.y, labelBox.width, labelBox.height - 3);
			tip.graphics.moveTo(0, 0);
			tip.graphics.lineTo(triCenter - triHalfWidth, labelBox.top);
			tip.graphics.lineTo(triCenter + triHalfWidth, labelBox.top);
			tip.graphics.endFill();	
			tip.graphics.lineStyle(1,ChartColor.waveLine,1);
			tip.graphics.moveTo(triCenter - triHalfWidth, labelBox.top);
			tip.graphics.lineTo(triCenter + triHalfWidth, labelBox.top);
			
		
			// draw text
			textObj.x = labelBox.left + (labelBox.width - textObj.textWidth)/ 2;
			textObj.y = textDistance;
			textObj.background=true;
			textObj.backgroundColor=ChartColor.waveLine;
			//使用位图画文字 旋转之后文字不能显示
			var bitmapdata:BitmapData=new BitmapData(textObj.textWidth+2,textObj.textHeight);
			bitmapdata.draw(textObj);
			var bitmap:Bitmap=new Bitmap(bitmapdata);
			bitmap.smoothing=true;
			bitmap.x=textObj.x;
			bitmap.y=textObj.y+1;//对y向下移动 不让文字与边框重叠

			tip.addChild(bitmap);
			
			tip.x = pos.x;
			tip.y = pos.y;
			
			return tip;				
		}		
		
		private function defaultNeedText(axis:AxisBase,op:IOpSelection):String
		{
			if (null != lableString)
				return lableString;
			if (null == axis)
				return "error";
			
			return axis.onNeedText(new Point(op.selPosX*axis.axisScale, 0), true);
		}
	}
}