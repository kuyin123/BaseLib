package ppf.base.graphics.axis
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.text.*;
	
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.math.MathUtil;

	/**
	 * 坐标类，水平刻度：对象响应指定波形容器的"matrixChanged"事件，并产生刻度
	 * @author wangke
	 *
	 */
	public class AxisX extends AxisBase
	{
		/**
		 * 绘图用的画板
		 */
		private var _canvas:Sprite;
		private var _bUseBitmap:Boolean=false;

		/**
		 *存储所有的文本对象
		 */
		private var tmptextarr:Array;
		
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
		 * 释放资源 
		 */	
		override public function dispose():void
		{
			super.dispose();
			_canvas = null;
			if (null != tmptextarr)
				tmptextarr.length = 0;
		}

		/**
		 * 构造函数
		 *
		 */
		public function AxisX()
		{ //初始化
			super();
		}

		override protected function onsetExtent(old_r:ChartRect, new_r:ChartRect):ChartRect
		{
			new_r.top=old_r.top;
			new_r.bottom=old_r.bottom;
			return new_r;
		}

		/**
		 * 波形状态改变发出的Event的X轴处理函数
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

			var box:ChartCanvas=chartBox;
			// 创建字体
			var fmt:TextFormat=CreateTextFormat();

			// 根据wave的x坐标范围生成刻度
			var scale:Number=axisScale;
			var min_sep:int=minStep;
			var text_arr:Array;
			var rect_arr:Array;
			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle=getMyRect(parent); //frameBox.getRect(this);	
			// !!! 强制把x、y置0
			clipRect.offset(-clipRect.x, -clipRect.y);
			// r = 当前图框的外框，使用像素坐标，即相对与舞台的矩形
			var Rect:Rectangle=getMyRect(); //frameBox.getRect(myStage);

			//	通过多次迭代，计算出刻度尺的位置和间距
			while (1)
			{
				// r = 指定wave的值范围
				var r:Rectangle=new Rectangle();
				r.topLeft=chartBox.globalToWorld(Rect.topLeft);
				r.bottomRight=chartBox.globalToWorld(Rect.bottomRight);
				// 对X方向缩放
				r.left*=scale;
				r.right*=scale;
				
				var seg:Number = calculateStep(r.width, true, min_sep);
				if (seg <= 0)
					return;
				
//				// 绘制横坐标
//				var iSegNum:int=Rect.width / min_sep;
//				if (iSegNum <= 0)
//					return;
//				
//				// 计算最大步长
//				var min_seg:Number=r.width / iSegNum;
//				
//				// 最小粒度 nScale，最小粒度是10的n次幂
//				var logn:int = 10;
//				if(style == AxisBase.STYLE_DIGIT)
//					logn = 2;
//				var mi:int=int(Math.log(min_seg) / Math.log(logn));
//				var nScale:Number=Math.pow(logn, mi);
//				var seg:Number = nScale;
//
//				if (logn == 10)
//				{
//					// 计算最合适步长
////					seg=nScale / 5;
////					if (seg < min_seg)
////						seg=nScale / 2;
////					if (seg < min_seg)
////						seg=nScale;
//					if (seg < min_seg)
//						seg=nScale * 2;
//					if (seg < min_seg)
//						seg=nScale * 5;
//					if (seg < min_seg)
//						seg=nScale * 10;
//				}
//				else if (logn == 2)
//				{
//					seg = nScale ;
//					if(seg < min_seg)
//						seg *= 2;
//				}
				
				var dd:Number=int(r.left / seg);
				dd-=1;
				dd*=seg;
				var _num:int=(r.right - dd) / seg + 3;
				var max_text_size:int=0;
				text_arr=[];
				rect_arr=[];
				// 临时文本shape对象，用来获取文字的宽高，辅助计算
				var tf:TextField=new TextField();
				var p0:Point;
				var str:String;
				for (var istep:int=0; istep <= _num; istep++)
				{
					// 根据步长计算出当前步的X值
					var tmpx:Number=istep;
					tmpx*=seg;
					tmpx+=dd;
					p0=new Point(dd + seg * istep, r.bottom);
					str=onNeedText(p0, true);
					p0.x/=scale;
					// 将波形空间的值转换到刻度对象的坐标
					p0=chartBox.worldToLocal(p0);
					
					// 设置y到刻度对象的顶部
					p0.y=0; //getMyRect(this).top;//frameBox.getRect(this).top;
					//	if ((p0.x + 0.5) >= Rect.left() && (p0.x - 0.5) <= Rect.right())
					//{
					tf.x=p0.x;
					tf.y=p0.y;
					tf.text=str;
					tf.setTextFormat(fmt);
					tf.autoSize=TextFieldAutoSize.CENTER;
					text_arr.push(str);
					rect_arr.push(new Rectangle(p0.x, p0.y, tf.textWidth, tf.textHeight));
					max_text_size=Math.max(tf.textWidth, max_text_size);
					//}
				}
				
				max_text_size*=2; // 前后增加2毫米的间隔
				if (max_text_size > min_sep)
					min_sep=max_text_size;
				else
					break;
			}

			//绘制刻度
			if (_canvas != null && this.contains(_canvas))
				_body.removeChild(_canvas);
			_canvas=new Sprite;
//			_body.addChildAt (_canvas, 0);

			var unitNameX:int=int.MAX_VALUE;
			if (null != _unitName)
			{ // add unit name
				var fmtUnit:TextFormat=CreateTextFormat();
				fmtUnit.bold=true;
				var unitTextObj:TextField=new TextField();
				unitTextObj.autoSize=TextFieldAutoSize.RIGHT;
				// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
				unitTextObj.x=clipRect.right - 5;
				unitTextObj.y=clipRect.top + 7;
				unitTextObj.text=this._unitName;
				unitTextObj.setTextFormat(fmtUnit);
				unitTextObj.selectable=false;
				addFontFilter(unitTextObj);
				_canvas.addChild(unitTextObj);

				unitNameX=clipRect.right - unitTextObj.textWidth - 5;
			}

			_canvas.graphics.lineStyle(0, ChartColor.axisBorder, 1.0, true, LineScaleMode.NONE, null, null, 1);
			var p00:Point=chartBox.worldToLocal(new Point(0, 0));
			var gridArray:Array=[];
			var text_r:Rectangle;
			var p_global:Point;
			var next:Number;
			var prev:Number;
			var f_sub_seg:Number;
			var textObj:TextField;
			var len:int=text_arr.length;

			for (var i:int=0; i < len; i++)
			{
				text_r=rect_arr[i];
				p0=text_r.topLeft;
				p_global=localToGlobal(p0);
				gridArray.push(p_global.x + box.borderWidth);

				if (!_bHasNegative && p0.x < p00.x)
					continue;

				if (_subStepNumber > 0)
				{ //绘制刻度线
					if (i < (rect_arr.length - 1))
					{
						next=rect_arr[i + 1].left + box.borderWidth;
						prev=p0.x + box.borderWidth;
						f_sub_seg=(next - prev) / _subStepNumber; // 计算刻度线的位置
						for (var j:int=0; j < _subStepNumber; j++)
						{
							var xx:int=int(prev + f_sub_seg * j);
							if (xx >= clipRect.left && xx <= clipRect.right)
							{
								if (j == 0)
									_canvas.graphics.moveTo(xx, p0.y + 5);
								else
									_canvas.graphics.moveTo(xx, p0.y + 3);
								_canvas.graphics.lineTo(xx, p0.y);
							}
						}
					}
				}

				// 创建刻度文本
				if ((p0.x) >= clipRect.left && (p0.x) <= clipRect.right)
				{
					//fmt.color=0xff0000;
					textObj=new TextField();
					if ((p0.x - text_r.width / 2) < clipRect.left)
					{
						textObj.autoSize=TextFieldAutoSize.LEFT;
						p0.x=clipRect.left;
					}
					else if ((p0.x + text_r.width / 2) > clipRect.right)
					{
						textObj.autoSize=TextFieldAutoSize.RIGHT;
						p0.x=clipRect.right;
					}
					else
						textObj.autoSize=TextFieldAutoSize.CENTER;
					// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
					textObj.x=p0.x; // - text_r.width/2;
					textObj.y=p0.y + 7;
					textObj.text=text_arr[i];
					textObj.setTextFormat(fmt);
					textObj.selectable=false;
					addFontFilter(textObj);
					if ((textObj.x + textObj.textWidth) < (unitNameX - 5))
						_canvas.addChild(textObj);
				}
			}
			if (isGridLine)
				chartBox.updateGridLineX(gridArray);
			//使用位图画刻度
			if (_bUseBitmap == true)
			{
				var myBitmapData:BitmapData=new BitmapData(_canvas.width + 20, _canvas.height);
				var bmp:Bitmap;
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
//			//限制缩放范围
//			var Step:Number=MathUtil.abs(Number(text_arr[1]) - Number(text_arr[0]));
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

			tmpTime=new Date(startTime.fullYear, 0); //获得年份
			if (interval < 31 * 24 * 60 * 60 * 1000) //获得月份
				tmpTime.month=startTime.month;
			if (interval < 24 * 60 * 60 * 1000) //天
				tmpTime.date=startTime.date;
			if (interval < 60 * 60 * 1000) //时
				tmpTime.hours=startTime.hours;
			if (interval < 60 * 1000) //分
				tmpTime.minutes=startTime.minutes;
			if (interval < 1000) //秒
				tmpTime.time=startTime.time;
			while (tmpTime < endTime)
			{
				if (tmpTime >= startTime)
				{
					tmpObj=new Object;
					tmpObj.value=new Date(tmpTime);
					var str:String=formatDateString(tmpTime, (interval < 24 * 60 * 60 * 1000));
					p=chartBox.worldToLocal(new Point(tmpTime.time, 0));

					var tf:TextField=new TextField;
					tf.x=p.x;
					tf.y=0;
					tf.text=str;
					tf.setTextFormat(fmt);
					tf.autoSize=TextFieldAutoSize.CENTER;
					tmpObj.text=str;
					tmpObj.rect=new Rectangle(p.x, 0, tf.textWidth, tf.textHeight);
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
				p=chartBox.worldToLocal(new Point(tmpTime.time, 0));

				var tf:TextField=new TextField;
				tf.x=p.x;
				tf.y=0;
				tf.text=str;
				tf.setTextFormat(fmt);
				tf.autoSize=TextFieldAutoSize.CENTER;
				tmpObj.text=str;
				tmpObj.rect=new Rectangle(p.x, 0, tf.textWidth, tf.textHeight);
				max_text_size=Math.max(tf.textWidth, max_text_size);
				outArray.push(tmpObj);

				tmpTime.fullYear=tmpTime.fullYear + xYears;
			}

			return max_text_size;
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
					p=chartBox.worldToLocal(new Point(tmpTime.time, 0));

					var tf:TextField=new TextField;
					tf.x=p.x;
					tf.y=0;
					tf.text=str;
					tf.setTextFormat(fmt);
					tf.autoSize=TextFieldAutoSize.CENTER;
					tmpObj.text=str;
					tmpObj.rect=new Rectangle(p.x, 0, tf.textWidth, tf.textHeight);
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

		/**
		 * 绘制日期、时间刻度
		 */
		private function redrawDateTime():void
		{
			// 创建字体
			var fmt:TextFormat=CreateTextFormat();

			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle=getMyRect(parent); //frameBox.getRect(this);	
			clipRect.offset(-clipRect.x, -clipRect.y); // !!! 强制把x、y置0

			// 创建刻度序列
			var itemArray:Array=createDateTimeAxisItems(fmt);

			//绘制刻度
			if (null != _canvas && null != _canvas.parent)
				_body.removeChild(_canvas);
			_canvas=new Sprite;
			_body.addChildAt(_canvas, 0);

			var unitNameX:int=int.MAX_VALUE;
			if (null != _unitName)
			{ // add unit name
				var fmtUnit:TextFormat=CreateTextFormat();
				fmtUnit.bold=true;
				var unitTextObj:TextField=new TextField();
				unitTextObj.autoSize=TextFieldAutoSize.RIGHT;
				// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
				unitTextObj.x=clipRect.right - 5;
				unitTextObj.y=clipRect.top + 7;
				unitTextObj.text=this._unitName;
				unitTextObj.setTextFormat(fmtUnit);
				unitTextObj.selectable=false;
				addFontFilter(unitTextObj);
				_canvas.addChild(unitTextObj);

				unitNameX=clipRect.right - unitTextObj.textWidth - 5;
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
			var f_sub_seg:Number;
			var xx:int;
			var textObj:TextField;
			for (var i:int=0; i < len; i++)
			{
				item=itemArray[i];
				text_r=item.rect;
				p0=text_r.topLeft;
				p_global=localToGlobal(p0);
				gridArray.push(p_global.x);

				if (!_bHasNegative && p0.x < p00.x)
					continue;

				if (_subStepNumber > 0)
				{ //绘制刻度线
					if (i < (len - 1))
					{
						next=(itemArray[i + 1].rect as Rectangle).left;
						prev=p0.x;
						f_sub_seg=(next - prev) / _subStepNumber; // 计算刻度线的位置
						for (var j:int=0; j < _subStepNumber; j++)
						{
							xx=int(prev + f_sub_seg * j);
							if (i == 0) //在绘制第一个点的同时绘制左边补充点
							{
								if (j == 0)
								{
									_canvas.graphics.moveTo(xx, p0.y + 5);
									_canvas.graphics.lineTo(xx, p0.y);
									_canvas.graphics.moveTo(xx - (next - prev), p0.y + 5);
									_canvas.graphics.lineTo(xx - (next - prev), p0.y);
								}
								else
								{
									_canvas.graphics.moveTo(xx, p0.y + 3);
									_canvas.graphics.lineTo(xx, p0.y);
									_canvas.graphics.moveTo(xx - (next - prev), p0.y + 3);
									_canvas.graphics.lineTo(xx - (next - prev), p0.y);
								}
							}
							else if (i == len - 2) //绘制完最后一个点的同时绘制最右补充点
							{
								if (j == 0)
								{
									_canvas.graphics.moveTo(xx, p0.y + 5);
									_canvas.graphics.lineTo(xx, p0.y);
									_canvas.graphics.moveTo(xx + (next - prev), p0.y + 5);
									_canvas.graphics.lineTo(xx + (next - prev), p0.y);
								}
								else
								{
									_canvas.graphics.moveTo(xx, p0.y + 3);
									_canvas.graphics.lineTo(xx, p0.y);
									_canvas.graphics.moveTo(xx + (next - prev), p0.y + 3);
									_canvas.graphics.lineTo(xx + (next - prev), p0.y);
								}
							}
							else
							{
								if (xx >= clipRect.left && xx <= clipRect.right)
								{
									if (j == 0)
										_canvas.graphics.moveTo(xx, p0.y + 5);
									else
										_canvas.graphics.moveTo(xx, p0.y + 3);
									_canvas.graphics.lineTo(xx, p0.y);
								}
							}
						}
					}
				}
				// 创建刻度文本
				if ((p0.x) >= clipRect.left && (p0.x) <= clipRect.right)
				{
					//fmt.color=0xff0000;
					textObj=new TextField();
					if (i == 0 && (p0.x - text_r.width / 2) < clipRect.left)
					{
						textObj.autoSize=TextFieldAutoSize.LEFT;
						p0.x=clipRect.left;
					}
					else if (i == itemArray.length - 1 && (p0.x + text_r.width / 2) > clipRect.right)
					{
						textObj.autoSize=TextFieldAutoSize.RIGHT;
						p0.x=clipRect.right;
					}
					else
						textObj.autoSize=TextFieldAutoSize.CENTER;
					// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
					textObj.x=p0.x; // - text_r.width/2;
					textObj.y=p0.y + 7;
					textObj.text=item.text;
					textObj.setTextFormat(fmt);
					textObj.selectable=false;
					addFontFilter(textObj);
					if ((textObj.x + textObj.textWidth) < (unitNameX - 5))
						_canvas.addChild(textObj);
				}
			}

			chartBox.updateGridLineX(gridArray);

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
		
		public function createDateTimeAxisItems(fmt:TextFormat):Array
		{
			var r:ChartRect=chartBox.extent;
			var startTime:Date;
			var endTime:Date;
			startTime=new Date(r.left);
			endTime=new Date(r.right);	
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
	}
}
