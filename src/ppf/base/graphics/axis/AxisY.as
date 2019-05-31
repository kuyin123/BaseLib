package ppf.base.graphics.axis
{
//	import com.siloon.plugin.rightClick.RightClickManager;

//	import com.siloon.plugin.rightClick.RightClickManager;

	import flash.display.*;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.*;
	import flash.text.*;
	
	import mx.core.UIComponent;
	import mx.events.MenuEvent;
	
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.math.MathUtil;

	/**
	 * 坐标类，垂直刻度：对象响应指定波形容器的"matrixChanged"事件，并产生刻度
	 * @author wangke
	 *
	 */
	public class AxisY extends AxisBase
	{

		/**
		 * 绘图用的画板
		 */
		private var _canvas:Sprite;
		private var myBitmapData:BitmapData;
		private var bmp:Bitmap;
		private var _bUseBitmap:Boolean=false;
		private var unitTextObj:TextField;
		private var _unitVisible:Boolean = true;
		private var _max_width:Number = 80;
		private var _min_width:Number = 40;
		private var _fixWidth:Boolean = false;
		
		private var _isHasTopBottom:Boolean = false;
		private var _rtop:Number;
		private var _rbottom:Number;
		
		/**
		 * 设置单位的可见
		 * @param value
		 */		
		public function set unitVisible(value:Boolean):void
		{
			_unitVisible = value;
		}
		
		public function get unitVisible():Boolean
		{
			return _unitVisible;
		}
		/**
		 * 是否使用位图（解决旋转问题）
		 */
		public function get bUseBitmap():Boolean
		{
			return _bUseBitmap;
		}

		public function set bUseBitmap(isuse:Boolean):void
		{
			_bUseBitmap=isuse;
		}
		
		/**
		 * 设置固定Y坐标的取值范围
		 */ 
		public function setTopAndBottom(top:Number , bottom:Number):void{
			_isHasTopBottom = true;
			_rtop = top;
			_rbottom = bottom;
		}
		
		override public function get maxWidth():Number
		{
			return _max_width;
		}

		/**
		 * 设置刻度最大宽度 
		 * @param value
		 */		
		override public function set maxWidth(value:Number):void
		{
			_max_width = value;
			onReSize(null);
		}

		override public function get minWidth():Number
		{
			return _min_width;
		}

		/**
		 * 设置刻度的最小宽度 
		 * @param value
		 */		
		override public function set minWidth(value:Number):void
		{
			_min_width = value;
			onReSize(null);
		}
		
		/**
		 * 是否固定宽度 
		 * @param value
		 */		
		public function set fixWidth(value:Boolean):void
		{
			_fixWidth = value;
		}


		/**
		 * 构造函数
		 *
		 */
		public function AxisY()
		{ //初始化
			super();
			// 注册右键菜单，选择Y坐标系
//			addEventListener(RightClickManager.RIGHT_CLICK, onRightDown);
		}
		
		override public function set style(s:int):void
		{
			super.style = s;	
		}

		override protected function get isX():Boolean
		{
			return false;
		}
		
		override protected function get isY():Boolean
		{
			return true;
		}

		override protected function onsetExtent(old_r:ChartRect, new_r:ChartRect):ChartRect
		{
			new_r.left=old_r.left;
			new_r.right=old_r.right;
			return new_r;
		}

		/**
		 * 波形状态改变发出的Event的Y轴处理函数
		 * @param e
		 *
		 */
		override protected function onRedrawAxis(e:Event):void
		{
			_bHasNegative = true;		// 当数值较大时，计算存在精度问题，暂不支持此选项
			
			if (style == AxisBase.STYLE_DATETIME || style == AxisBase.STYLE_UTCTIME)
			{
				redrawDateTime();
				return;
			}
			// 调用基类的方法，创建字体
			var fmt:TextFormat=CreateTextFormat();

			// 根据wave的x坐标范围生成刻度
			var scale:Number=axisScale; //得到waveScaleY的值
			var min_sep:int=minStep; //刻度最小步长
			var text_arr:Array; //
			var rect_arr:Array; //
			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle=getMyRect(this); //frameBox.getRect(this);	
			// r = 当前图框的外框，使用像素坐标，即相对与舞台的矩形
			var Rect:Rectangle=getMyRect(); //frameBox.getRect(myStage);

			// 通过多次迭代，计算刻度尺的位置和间距
			while (1)
			{
				// r = 指定wave的值范围
				var r:Rectangle=new Rectangle();
				r.topLeft=chartBox.globalToWorld(Rect.topLeft);
				r.bottomRight=chartBox.globalToWorld(Rect.bottomRight);
				//如果是固定Y轴范围则以固定值为准
				if(_isHasTopBottom){
					r.top = _rtop;
					r.bottom = _rbottom;
					if(r.topLeft)
					   r.topLeft = new Point( r.topLeft.x , _rtop );
					if(r.bottomRight)
					   r.bottomRight = new Point( r.bottomRight.x , _rbottom);
				}
				
				// 对Y方向缩放
				r.top*=scale;
				r.bottom*=scale;

				// 绘制纵坐标
				var seg:Number = calculateStep(Math.abs(r.height), false, min_sep);
				if (seg <= 0)
					return;
				
				// pDC->SetTextAlign(TA_LEFT|TA_TOP);
				var dd:Number=seg * int(Math.min(r.top, r.bottom) / seg);
				var num:int=(Math.max(r.bottom, r.top) - dd) / seg + 3;
				var max_text_sizeX:int=0;
				var max_text_sizeY:int = 0;
				text_arr=[];
				rect_arr=[];
				// 临时文本shape对象，用来获取文字的宽高，辅助计算
				var tf:TextField=new TextField();
				var p0:Point;
				var str:String;

				for (var istep:int=0; istep < num; istep++)
				{
					// 根据步长计算出当前步的Y值
					p0=new Point(r.left, dd + seg * istep);
					str=onNeedText(p0, false);
					p0.y/=scale;
					// 将波形空间的值转换到刻度对象的坐标
					p0=chartBox.worldToGlobal(p0);
					p0=this.globalToLocal(p0);

					// 设置y到刻度对象的顶部
					p0.x=0; //getMyRect(this).x;//frameBox.getRect(this).left;
					//	if ((p0.x) >= Rect.left() && (p0.x) <= Rect.right())
					{
						tf.x=p0.x;
						tf.y=p0.y;
						tf.text=str;
						tf.setTextFormat(fmt);
						tf.autoSize=TextFieldAutoSize.CENTER;

						text_arr.push(str);
						rect_arr.push(new Rectangle(p0.x, p0.y, tf.textWidth, tf.textHeight));
						max_text_sizeX=Math.max(tf.textWidth, max_text_sizeX);
						max_text_sizeY=Math.max(tf.textHeight, max_text_sizeY);
					}
				}

				max_text_sizeY*=1.5; // 前后增加2毫米的间隔
				if (max_text_sizeY > min_sep)
					min_sep=max_text_sizeY;
				else
					break;
			}

			if (_canvas != null && this.contains(_canvas))
				_body.removeChild(_canvas);
			if(bmp!=null&&this.contains(bmp))
				_body.removeChild(bmp);
			_canvas=new Sprite;
//			_body.addChildAt (_canvas, 0);

			var unitNameX:int=int.MIN_VALUE;
			if (null != _unitName)
			{ // add unit name
				var fmtUnit:TextFormat=CreateTextFormat();
				fmtUnit.bold=true;
				var unitTextObj:TextField=new TextField();
				//unitTextObj.textColor = ChartColor.axisText;
				unitTextObj.autoSize=TextFieldAutoSize.RIGHT;
				// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
				unitTextObj.x=clipRect.right - 7; // - text_r.width/2;
				unitTextObj.y=clipRect.top + 5;
				unitTextObj.text=_unitName;
				unitTextObj.setTextFormat(fmtUnit);
				unitTextObj.selectable=false;
				addFontFilter(unitTextObj);
				_canvas.addChild(unitTextObj);

				unitNameX=clipRect.top + unitTextObj.height + 5;
			}

			//绘制刻度
			_canvas.graphics.lineStyle(0, ChartColor.axisBorder, 1.0, true, LineScaleMode.NONE, null, null, 1);
			var p00:Point=chartBox.worldToGlobal(new Point(0, 0));
			p00 = this.globalToLocal(p00);// 将canvas的(0,0)转换到刻度对象的坐标
//			var p00:poin = chartBox.worldToLocal(new Point(0, 0));
			var gridArray:Array=[];
			var len:int=text_arr.length;
			var text_r:Rectangle;
			var next:Number;
			var prev:Number;
			var f_sub_seg:Number;
			var j:int;
			var yy:Number;
			var textObj:TextField;
			for (var i:int=0; i < len; i++)
			{
				text_r=rect_arr[i];
				p0.x=text_r.left + clipRect.width;
				p0.y=text_r.top;
				var p_global:Point=localToGlobal(p0);
				gridArray.push(p_global.y);

				if (!_bHasNegative && p0.y > p00.y)
					continue;

				if (_subStepNumber > 0)
				{ //绘制刻度线
					if (i < (rect_arr.length - 1))
					{
						next=rect_arr[i + 1].top;
						prev=p0.y;
						f_sub_seg=(prev - next) / _subStepNumber; // 计算刻度线的位置
						j=0;
						for (; j < _subStepNumber; j++)
						{
							yy=prev - f_sub_seg * j;
//							if (yy >= Math.min(clipRect.top, clipRect.bottom) && yy <= Math.max(clipRect.top, clipRect.bottom))
							if (i == 0) //在绘制第一个点的同时绘制完补充的点
							{
								if (j == 0)
								{
									_canvas.graphics.moveTo(p0.x - 5, yy);
									_canvas.graphics.lineTo(p0.x, yy);
									_canvas.graphics.moveTo(p0.x - 5, yy + (prev - next));
									_canvas.graphics.lineTo(p0.x, yy + (prev - next));
								}
								else
								{
									_canvas.graphics.moveTo(p0.x - 3, yy);
									_canvas.graphics.lineTo(p0.x, yy);
									if(((p0.y - p00.y) < 0.000000001) && !_bHasNegative)//当前可见范围内最后一个刻度文字 且又不显示负数时  不再往下画
										continue;
									_canvas.graphics.moveTo(p0.x - 3, yy + (prev - next));
									_canvas.graphics.lineTo(p0.x, yy + (prev - next));
								}
							}
							else
							{
								if (j == 0)
									_canvas.graphics.moveTo(p0.x - 5, yy);
								else
									_canvas.graphics.moveTo(p0.x - 3, yy);
								_canvas.graphics.lineTo(p0.x, yy);
							}
						}
					}
				}
				// 创建刻度文本
				if ((p0.y) >= clipRect.top && (p0.y) <= clipRect.bottom)
				{
					textObj = new TextField();
					if ((p0.y - text_r.height/2) < clipRect.top)
					{
						p0.y=clipRect.top + text_r.height / 2;
					}
					else if ((p0.y + text_r.height / 2) > clipRect.bottom)
					{
						p0.y=clipRect.bottom - text_r.height / 2;
					}

					textObj.autoSize = TextFieldAutoSize.RIGHT;
					// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
					textObj.x = p0.x - 7;	// - text_r.width/2;
					textObj.y = p0.y - text_r.height/2;
					textObj.text = text_arr[i];
					textObj.setTextFormat(fmt);
					textObj.selectable=false;
					addFontFilter (textObj);
					if (textObj.y > (unitNameX + 5))
						_canvas.addChild (textObj);
				}
			}

			//使用位图画刻度
			if (_bUseBitmap == true)
			{
				myBitmapData=new BitmapData(_canvas.width , chartBox.height);
				myBitmapData.draw(_canvas);
				bmp=new Bitmap(myBitmapData);
				bmp.smoothing=true;
				
				//			_body.addChild(_canvas);
				_body.addChild(bmp);
			}
			else
			{
				_body.addChildAt(_canvas, 0);
			}

			if (isGridLine) //当Y轴缩放 、改变之后更新画布
				chartBox.updateGridLineY(gridArray);

			if (!_fixWidth)
			{//不固定宽度时自动调整
				//刻度宽度自适应  在最大宽度与最小宽度之间自动调整  
				if((max_text_sizeX + 10) > maxWidth)
					this.width = maxWidth;
				else if((max_text_sizeX + 10) < minWidth)
					this.width = minWidth;
				else
				{//this.width = max_text_sizeX + 10;//此处来回设置回导致不停调用updateDisplayList，造成环路
					max_text_sizeX += 10;
					if (Math.abs(width - max_text_sizeX) <= 10)//当像素差在10个像素范围内时取大的
						width = Math.max(this.width,max_text_sizeX);
					else
						width = max_text_sizeX;
				}
			}
		}

		/**
		 * 绘制日期、时间刻度
		 */
		protected function redrawDateTime():void
		{

			// 创建字体
			var fmt:TextFormat=CreateTextFormat();

			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle=getMyRect(this); //frameBox.getRect(this);	
			clipRect.offset(-clipRect.x, -clipRect.y); // !!! 强制把x、y置0

			// 创建刻度序列
			var itemArray:Array=createDateTimeAxisItems(fmt);

			//绘制刻度
			if (null != _canvas && null != _canvas.parent)
				_body.removeChild(_canvas);
			if(bmp!=null&&this.contains(bmp))
				_body.removeChild(bmp);
			_canvas=new Sprite;
//			_body.addChildAt (_canvas, 0);

			var unitNameX:int=int.MAX_VALUE;
			if (null != _unitName)
			{ // add unit name
				var fmtUnit:TextFormat=CreateTextFormat();
				fmtUnit.bold=true;
				unitTextObj = new TextField();
				unitTextObj.visible = _unitVisible;
				unitTextObj.autoSize=TextFieldAutoSize.RIGHT;
				// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
				unitTextObj.x=clipRect.right - 5;
				unitTextObj.y=clipRect.top + 7;
				unitTextObj.text=this._unitName;
				unitTextObj.setTextFormat(fmtUnit);
				unitTextObj.selectable=false;
				addFontFilter(unitTextObj);
				_canvas.addChild(unitTextObj);

//				unitNameX = clipRect.right - unitTextObj.textWidth - 5;
			}

			_canvas.graphics.lineStyle(0, ChartColor.axisBorder, 1.0, true, LineScaleMode.NONE, null, null, 1);
			var p00:Point=chartBox.worldToLocal(new Point(0, 0));
			var gridArray:Array=[];


			var item:Object;
			var text_r:Rectangle;
			var p0:Point;
			var p_global:Point;
			var len:int=itemArray.length;

			var next:Number;
			var prev:Number;
			var sub_step:int;
			var f_sub_seg:Number;
			var xx:int;
			var textObj:TextField;
			var spriteRight:Sprite=new Sprite;
			var max_text_size:Number = 0;
			for (var i:int=0; i < len; i++)
			{
				item=itemArray[i];
				text_r=item.rect;
				p0=text_r.topLeft;
				p_global=localToGlobal(p0);
				gridArray.push(p_global.x);

				if (!_bHasNegative && p0.x < p00.x)
					continue;
				// 创建刻度文本
				if ((p0.y) >= clipRect.top && (p0.y) <= clipRect.bottom)
				{
					//fmt.color=0xff0000;
					textObj = new TextField();
					if ((p0.y - text_r.height / 2) < clipRect.top)
					{
						p0.y=clipRect.top + text_r.height / 2;
					}
					else if ((p0.y + text_r.height / 2) > clipRect.bottom)
					{
//						p0.y=clipRect.bottom - text_r.height / 2;
						p0.y=clipRect.bottom - text_r.height/2;
					}
					// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
					textObj.autoSize=TextFieldAutoSize.RIGHT;
					textObj.setTextFormat(fmt);
					textObj.selectable=false;
					textObj.text=item.text;
					textObj.x=clipRect.width-textObj.width; // - text_r.width/2;
					textObj.y=p0.y-text_r.height/2;
					if(textObj.width > max_text_size)//获取文字的最大宽度
						max_text_size = textObj.width;

					addFontFilter(textObj);

					if ((textObj.y) < (unitNameX - 5))
						_canvas.addChild(textObj);
				}
			}

			//使用位图画刻度
			if (_bUseBitmap == true)
			{
//				_canvas.x=clipRect.width-_canvas.width;
				myBitmapData=new BitmapData(clipRect.width  , chartBox.height);
				myBitmapData.draw(_canvas);
				bmp=new Bitmap(myBitmapData);
				bmp.smoothing=true;
//				bmp.x=clipRect.width-_canvas.width;
				//			_body.addChild(_canvas);
				_body.addChild(bmp);
			}
			else
			{
				_body.addChildAt(_canvas, 0);
			}
			chartBox.updateGridLineY(gridArray);
			
			if (!_fixWidth)
			{
				//刻度宽度自适应  在最大宽度与最小宽度之间自动调整  
				if((max_text_size + 10) > maxWidth)
					this.width = maxWidth;
				else if((max_text_size + 10) < minWidth)
					this.width = minWidth;
				else
					this.width = max_text_size + 10;
			}
//			//限制缩放范围
//			var Step:Number=MathUtil.abs(Number(itemArray[0].value.time) - Number(itemArray[1].value.time));
//			if (Step < chartBox.maxScaleX * 2) //先缩放在刷新坐标轴
//				chartBox.isZoomMaxX=false;
//			else
//				chartBox.isZoomMaxX=true;
//
//			if (Step > chartBox.minScaleX * 0.5) //先缩放在刷新坐标轴
//				chartBox.isZoomMinX=false;
//			else
//				chartBox.isZoomMinX=true;
		}

		/**
		 * 等间距的刻度分布
		 * @param fmt
		 * @param startTime
		 * @param endTime
		 * @param interval
		 * @param outArray
		 * @return
		 *
		 */
		private function getOneLevelAxis(fmt:TextFormat, startTime:Date, endTime:Date, interval:Number, outArray:Array):Number
		{
			var tmpTime:Date;
			var tmpObj:Object;
			var p:Point;
			var max_text_size:Number=0;

			tmpTime=new Date(startTime.fullYear, 0);
			if (interval < 31 * 24 * 60 * 60 * 1000)
				tmpTime.month=startTime.month;
			if (interval < 24 * 60 * 60 * 1000)
				tmpTime.date=startTime.date;
			if (interval < 60 * 60 * 1000)
				tmpTime.hours=startTime.hours;
			if (interval < 60 * 1000)
				tmpTime.minutes=startTime.minutes;
			if (interval < 1000)
				tmpTime.time=startTime.time;
			while (tmpTime < endTime)
			{
				if (tmpTime >= startTime)
				{
					tmpObj=new Object;
					tmpObj.value=new Date(tmpTime);
					var str:String=formatDateString(tmpTime, (interval < 24 * 60 * 60 * 1000));
					p=chartBox.worldToLocal(new Point(0, tmpTime.time));

					var tf:TextField=new TextField;
					tf.x=p.x;
					tf.y=p.y;
					tf.text=str;
					tf.setTextFormat(fmt);
					tf.autoSize=TextFieldAutoSize.CENTER;
					tmpObj.text=str;
					tmpObj.rect=new Rectangle(0, p.y, tf.textWidth, tf.textHeight);
					max_text_size=Math.max(tf.textWidth, max_text_size);
					outArray.push(tmpObj);
				}
				tmpTime.time+=interval;
			}

			return max_text_size;
		}

		/**
		 * 年为单位的刻度分布
		 * @param fmt TextFormat
		 * @param startTime 开始时间
		 * @param endTime 结束时间
		 * @param xYears 年数
		 * @param outArray 输出数组
		 * @return
		 *
		 */
		private function getYearAxis(fmt:TextFormat, startTime:Date, endTime:Date, xYears:Number, outArray:Array):Number
		{
			var tmpTime:Date;
			var tmpObj:Object;
			var p:Point;
			var max_text_size:Number=0;

			tmpTime=new Date(startTime.fullYear, 0);
			while (tmpTime < endTime)
			{
				tmpObj=new Object;
				tmpObj.value=new Date(tmpTime);
				var str:String=formatDateString(tmpTime);
				p=chartBox.worldToLocal(new Point(0, tmpTime.time)); //数据坐标转到本地坐标

				var tf:TextField=new TextField;
				tf.x=p.x;
				tf.y=p.y;
				tf.text=str;
				tf.setTextFormat(fmt);
				tf.autoSize=TextFieldAutoSize.CENTER;
				tmpObj.text=str;
				tmpObj.rect=new Rectangle(0, p.y, tf.textWidth, tf.textHeight);
				max_text_size=Math.max(tf.textWidth, max_text_size);
				outArray.push(tmpObj);

				tmpTime.fullYear=tmpTime.fullYear + xYears;
			}

			return max_text_size;
		}

		private function formatDateString(t:Date, formatTime:Boolean=false):String
		{
			var str:String="";
			if (!formatTime)
				str+=t.fullYear + "-" + createDoubDigit((t.month + 1)) + "-" + createDoubDigit(t.date) + "\n";
			else
			{
				str+=createDoubDigit(t.hours) + ":" + createDoubDigit(t.minutes) + ":" + createDoubDigit(t.seconds);
				if (t.milliseconds > 0)
					str+="." + createDoubDigit(t.milliseconds);
			}
			return str;
		}
		
		private function createDoubDigit(value:Number):String
		{//补足两位数字
			var str:String = "";
			if(value < 10)
				str += "0" + value;
			else
				str = value.toString();
			return str;
		}

		/**
		 * 月为单位的刻度分布
		 * @param fmt TextFormat
		 * @param startTime 开始时间
		 * @param endTime 结束时间
		 * @param xMonths 月数
		 * @param outArray 输出数组
		 * @return
		 *
		 */
		private function getMonthAxis(fmt:TextFormat, startTime:Date, endTime:Date, xMonths:Number, outArray:Array):Number
		{
			var tmpTime:Date;
			var tmpObj:Object;
			var p:Point;
			var max_text_size:Number=0;

			tmpTime=new Date(startTime.fullYear);
			while (tmpTime < endTime)
			{
				if (tmpTime >= startTime)
				{
					tmpObj=new Object;
					tmpObj.value=new Date(tmpTime);
					var str:String=formatDateString(tmpTime);
					p=chartBox.worldToLocal(new Point(0, tmpTime.time));

					var tf:TextField=new TextField;
					tf.x=p.x;
					tf.y=p.y;
					tf.text=str;
					tf.setTextFormat(fmt);
					tf.autoSize=TextFieldAutoSize.CENTER;
					tmpObj.text=str;
					tmpObj.rect=new Rectangle(0, p.y, tf.textWidth, tf.textHeight);
					max_text_size=Math.max(tf.textWidth, max_text_size);
					outArray.push(tmpObj);
				}

				if ((tmpTime.month + xMonths) < 12)
					tmpTime.month=tmpTime.month + xMonths;
				else
				{
					tmpTime.fullYear=tmpTime.fullYear + 1;
					tmpTime.month=xMonths - (12 - tmpTime.month);
				}
			}

			return max_text_size;
		}

		/**
		 * 两个级别的输出数组进行合并，将 newItems 与 oldItems 重复的部分保留老的版本
		 * 同时通过二分法剔除部分文本，使得适应容器宽度
		 * @param dist
		 * @param newItems
		 * @return 新的数组
		 */
		private function combinationItems(oldItems:Array, newItems:Array):Array
		{
			if (newItems.length < oldItems.length)
				return oldItems;
			var outItems:Array=newItems.slice();
			var v:Number;
			var outlen:int=outItems.length;
			var oldlen:int=oldItems.length;

			for (var i:Number=0; i < outlen; i++)
			{
				v=outItems[i].value;
				for (var j:Number=0; j < oldlen; j++)
				{
					if (Number(oldItems[j].value) == v)
					{
						outItems[i]=oldItems[j];
						break;
					}
				}
			}

			return outItems;
		}

		protected function createDateTimeAxisItems(fmt:TextFormat):Array
		{
			// 计算最大最小时间
			var r:ChartRect=chartBox.extent;
			trace("y："+r);
			var startTime:Date=new Date(r.bottom);
			var endTime:Date=new Date(r.top);
			var tmpTime:Date;
			var tmpObj:Object;
			var p:Point;
			var max_text_size:Number=0;

			// 根据wave的x坐标范围生成刻度
			var min_sep:int=25;
			var itemArray:Array=[];
			var tmpArray:Array;

			// 年
			// 先排布年份，如不足一年，则使用下一级别排布
			tmpTime=new Date(startTime.fullYear, 0);
			if (startTime.fullYear < endTime.fullYear)
				max_text_size=getYearAxis(fmt, new Date(startTime.fullYear, 0), endTime, 1, itemArray);

			if (itemArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成

			// 超过一个月，则排布月份
			// 如果 axisArray.length > 0，说明已经超过了一年
			// 如果 如果在一年以内，并且在同一个月以内，则不需要使用月份来排布了，直接使用下一级别
			//			if (itemArray.length > 0 || (startTime.month < endTime.month))
			//			{
			// 6个月
			tmpArray=[];
			max_text_size=getMonthAxis(fmt, startTime, endTime, 6, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 3个月
			tmpArray=[];
			max_text_size=getMonthAxis(fmt, startTime, endTime, 3, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 2个月
			tmpArray=[];
			max_text_size=getMonthAxis(fmt, startTime, endTime, 2, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 1个月
			tmpArray=[];
			max_text_size=getMonthAxis(fmt, startTime, endTime, 1, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 15天
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 15 * 24 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);
			//			}

			// 10天
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 10 * 24 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 5天
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 5 * 24 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 2天
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 2 * 24 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 1天
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 24 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 超过一小时，则排布时
			// 12小时
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 12 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 6小时
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 6 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 3小时
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 3 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 2小时
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 2 * 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 1小时
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 60 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 30分钟
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 30 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 10分钟
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 10 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 5分钟
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 5 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 2分钟
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 2 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 1分钟
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 1 * 60 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 30秒
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 30 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 10秒
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 10 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 5秒
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 5 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);


			// 2秒
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 2 * 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			// 1秒
			tmpArray=[];
			max_text_size=getOneLevelAxis(fmt, startTime, endTime, 1000, tmpArray);
			if (tmpArray.length * max_text_size * 2 > chartBox.width)
				return itemArray; // 布局完成
			itemArray=combinationItems(itemArray, tmpArray);

			return itemArray; // 布局完成
		}
		
//		/**
//		 * 步长计算 
//		 * @param target
//		 * @param dr 数据范围
//		 * @param sr 像素范围
//		 * @param min_sep
//		 * @return 步长
//		 */		
//		private function defaultSegCB(target:AxisBase,dr:Rectangle,sr:Rectangle,min_sep:int):Number
//		{
//			var iSegNum:int=sr.height / min_sep;
//			// 计算最大步长
//			var min_seg:Number=Math.abs(dr.height / iSegNum);
//			
//			// 最小粒度 nScale，最小粒度是10的n次幂
//			var mi:int=int(Math.log(min_seg) * Math.LOG10E);
//			var nScale:Number=Math.pow(10, mi);
//			
//			// 计算最合适步长
//			var seg:Number=nScale / 5;
//			if (seg < min_seg)
//				seg=nScale / 2;
//			if (seg < min_seg)
//				seg=nScale;
//			if (seg < min_seg)
//				seg=nScale * 2;
//			if (seg < min_seg)
//				seg=nScale * 5;
//			if (seg < min_seg)
//				seg=nScale * 10;
//			return seg;
//		}
//		
		/**
		 * 在控制上单击右键菜单事件的处理函数
		 * @param event 右键事件
		 */
//		protected function onRightDown(event:ContextMenuEvent):void
//		{
//			var menuData:Array= [
//			        {label:'全部',action:'allAxis',icon:'',styleName:'PlotChart'} ,
////			        {type:"separator"} ,
//				];
//			
//			var axisNames:Array = chartBox.axisNameList;
//			for each(var name:String in axisNames)
//			{
//				var menuObj:Object = {};
//				menuObj.label = name;
//				menuObj.action = 'axis';
//				menuData.push(menuObj);
//			} 
//			
//			if (axisNames.length > 1)
//				RightClickManager.showMenu(this, menuData, onSelectAxis);
//		}


//		private function onSelectAxis(e:MenuEvent):void
//		{
//			switch(e.item.action)
//			{
//				case "allAxis":
//					unitName = null;
//					break;
//				case "axis":
//					unitName = e.item.label;
//					break;
//			}
//			
//			updateAxis();
//		}
	}
}
