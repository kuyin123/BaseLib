package ppf.base.graphics.axis
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.EventMatrixChange;
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartRect;

	public class AxisTestZ extends AxisY
	{
		/**
		 * 绘图用的画板
		 */
		private var _canvas:Sprite;
		private var bmp:Bitmap;
		private var myBitmapData:BitmapData;
		private var unitTextObj:TextField;
		/**
		 * 设置间隙 
		 */		
		public var GAP:Number = 10;
		public function AxisTestZ()
		{
			super();
		}
		
		/**
		 * 鼠标滚轮缩放事件
		 * @param e 鼠标事件
		 */
		override protected function DiagramFrame_wheel(e:MouseEvent):void
		{
			var nmaxY:Number =  getmaxZ(point3dArr)* 4 * _scale;//设置三维坐标的高度值
			var cur:Point = chartBox.globalToWorld(new Point(e.stageX,e.stageY));
			var old_r:ChartRect = chartBox.extent;
			var scale:Number;
			if (e.delta>0) {
				scale = 1/(e.delta*0.4);
			}
			else if(!isNaN(nmaxY) && nmaxY > 1)
				scale = -e.delta*0.4;
			else 
				return;
			_scale *= scale;
			var evt:EventMatrixChange=new EventMatrixChange(ChartCanvas.EVENT_MATRIX_CHANGED,true);
			chartBox.dispatchEvent(evt);
		}
		
		override protected function DiagramFrame_move(e:MouseEvent):void 
		{
			var nmaxY:Number =  getmaxZ(point3dArr)* 4 * _scale;//设置三维坐标的高度值
			var cur:Point = new Point(e.stageX,e.stageY);
			var old_w:Point = chartBox.globalToWorld(_startPoint);
			var cur_w:Point = chartBox.globalToWorld(cur);
			_startPoint = cur;			
			var old_r:ChartRect = chartBox.extent;
			var new_r:ChartRect = old_r.clone();
			var dis:Number = old_w.y - cur_w.y;
			if(dis >= 0)
				_scale *= 1.05;
			else if(!isNaN(nmaxY) && nmaxY > 1)
				_scale *= 0.95;
			else
				return;
			var evt:EventMatrixChange=new EventMatrixChange(ChartCanvas.EVENT_MATRIX_CHANGED,true);
			chartBox.dispatchEvent(evt);
		}
		
		override protected function onRedrawAxis(e:Event):void
		{
			if(style == AxisBase.STYLE_DATETIME || style == AxisBase.STYLE_UTCTIME)
			{//风格为时间
				redrawDateTime();
				return;
			}
			var prevAxis:String = this.chartBox.currentAxis;
			//调用基类的方法，创建字体
			var fmt:TextFormat = CreateTextFormat();
			var scale:Number = axisScale;//得到waveScaleY的值
			var min_sep:int = minStep;//刻度最小步长
			var text_arr:Array;//存储文字
			var rect_arr:Array;//存储文字的位置信息
			//使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle = getMyRect(this);//得到本地坐标
			// r = 当前图框的外框，使用像素坐标，即相对舞台的矩形 即全局坐标
			var Rect:Rectangle = getMyRect();
			var visible_arr:Array = [];//可见文字对象
			//通过多次迭代，计算刻度尺的位置和间距
			while(1)
			{
				// r = 指定wave的值范围
				var r:Rectangle = new Rectangle();
				var extent:ChartRect = chartBox.extent;
				var nminY:Number = 0;
				var nmaxY:Number =  getmaxZ(point3dArr)* 4 * _scale;//设置三维坐标的高度值
				if(isNaN(nmaxY))
					nmaxY = 1;
				var maxValue:int = nmaxY;
				var count:int = 0;
				var lastnum:int = 0;
				while(maxValue != 0)//判断是几位数
				{
					maxValue /= 10;
					count ++;
				}
				lastnum = int(nmaxY) / Math.pow(10,count - 1);
				lastnum += 1;
				if(int(nmaxY) == 0)//小数时设置范围 0~1
					nmaxY = 1;
				else
					nmaxY = lastnum * Math.pow(10,count - 1);
				
				chartBox.currentAxis = "axisZ";//此时把数据按“axisZ”坐标系处理  保证数据的像素高度和刻度尺的像素高度对应
//				chartBox.extent.minY = nminY;
//				chartBox.extent.maxY = nmaxY;
				chartBox.setExtent(new ChartRect(extent.left,nmaxY,extent.right,nminY),false);
				chartBox.currentAxis = "axisZ";//axisXFoucus中会把currentAxis设置为null  此处重新设置回来
				r.topLeft = chartBox.globalToWorld(Rect.topLeft);
				r.bottomRight = chartBox.globalToWorld(Rect.bottomRight);
				
				//绘制Z坐标
				var iSegNum:int = Rect.height/min_sep;//最小步长默认为25个像素
				if(iSegNum <= 0)//高度小于最小粒度
					return;
				
				//计算最大步长
				var min_seg:Number = Math.abs(r.height / iSegNum);
				//最小粒度nScale,最小粒度是10的n次幂
				var mi:int = int(Math.log(min_seg)*Math.LOG10E);
				var nScale:Number = Math.pow(10,mi);//当粒度很小时此时mi为0  需要接着计算合适步长
				
				//计算最合适步长
				var seg:Number = nScale / 5;
				if(seg < min_seg)
					seg = nScale / 2;
				if(seg < min_seg)
					seg = nScale;
				if(seg < min_seg)
					seg = nScale * 5;
				if(seg < min_seg)
					seg = nScale * 10;
				//起始点
				var dd:Number = seg * int(Math.min(r.top,r.bottom)/seg);
				var num:int = (Math.max(r.bottom,r.top) - dd) / seg + 3;
				var max_text_sizeX:int = 0;
				var max_text_sizeY:int = 0;
				text_arr = [];
				rect_arr = [];
				//创建临时文本对象，用来存储文字的宽高，辅助计算
				var tf:TextField = new TextField();
				var p0:Point;
				var str:String;
				
				for(var istep:int = 0;istep < num;istep++)
				{
					p0 = new Point(r.left,dd + seg * istep);
					str = onNeedText(p0,false);
					p0 = chartBox.worldToGlobal(p0);
					p0= this.globalToLocal(p0);
					
					p0.x = 0;//设置到最左端
					//记录文字的位置  辅助计算 方便接下来绘制文字的位置和和显示刻度值
					tf.x = p0.x;
					tf.y = p0.y;
					tf.text = str;
					tf.setTextFormat(fmt);
					tf.autoSize = TextFieldAutoSize.CENTER;
					
					text_arr.push(str);//存储刻度文字
					rect_arr.push(new Rectangle(p0.x,p0.y,tf.textWidth,tf.textHeight));//存储刻度范围
					max_text_sizeX = Math.max(tf.textWidth,max_text_sizeX);
					max_text_sizeY = Math.max(tf.textHeight,max_text_sizeY);
				}
				
				max_text_sizeY *= 1.5;//前后增加2毫米的间隔
				if(max_text_sizeY > min_sep)//反复计算知道文字的高度小于步长
					min_sep = max_text_sizeY;
				else
					break;
			}
			
			if(null != _canvas && this.contains(_canvas))
				_body.removeChild(_canvas);
			if(null != bmp && this.contains(bmp))
				_body.removeChild(bmp);
			_canvas = new Sprite;
			var unitNameY:int = int.MIN_VALUE;//单位的y坐标
			if(null != _unitName)
			{
				var fmtUnit:TextFormat = CreateTextFormat();
				fmtUnit.bold = true;
				var unitTextObj:TextField = new TextField();
				unitTextObj.autoSize = TextFieldAutoSize.RIGHT;
				unitTextObj.text = _unitName;
				unitTextObj.setTextFormat(fmtUnit);
				unitTextObj.x = 17;
				unitTextObj.y = 0;
				unitTextObj.selectable = false;
				unitTextObj.visible = unitVisible;
				addFontFilter(unitTextObj);
				_canvas.addChild(unitTextObj);
				unitNameY = clipRect.top + unitTextObj.textHeight; 
			}
			
			_canvas.graphics.lineStyle(0,ChartColor.axisBorder,1.0,true,LineScaleMode.NONE,null,null,1);
			var bp:Point = chartBox.worldToGlobal(new Point(0,0));//该窗口的边缘
			bp = this.globalToLocal(bp);//将数据坐标的（0,0）转到本地坐标
			var gridArray:Array = [];
			var len:int = text_arr.length;
			var text_r:Rectangle;
			var next:Number;
			var prev:Number;
			var f_sub_seg:Number;
			var j:int;
			var yy:Number;
			var yy2:Number;
			var textObj:TextField;
			var lineEnd:Point = new Point;//最后一个刻度的位置
			for(var i:int = 0;i < len;i++)
			{//绘制刻度与文字
				text_r = rect_arr[i];
				p0.x = text_r.left + GAP;
				p0.y = text_r.top;
				var p_global:Point = localToGlobal(p0);
				gridArray.push(p_global.y);
				
				if(!_bHasNegative && (p0.y > bp.y)||(p0.y <　0))
					continue;
				if(int(p0.y) == int(bp.y))//对边缘点做特殊处理   不使图像绘出当前区域
					p0.y -= 1;
				if(int(p0.y) == 0)//对边缘点做特殊处理   不使图像绘出当前区域
					p0.y = int(p0.y) + 1;
				text_r.top = p0.y;
				visible_arr.push(text_r);//记录可见对象  方便接下来绘制刻度条直线
				if(_subStepNumber > 0)
				{//绘制刻度线
					if(i < (rect_arr.length - 1))
					{
						next = rect_arr[i+1].top;
						prev = p0.y;
						f_sub_seg = (prev - next) / _subStepNumber;//刻度的步长
						j = 0;
						for(;j< _subStepNumber;j++)
						{
							yy = prev - f_sub_seg * j;
							yy2 = yy + (prev - next);
							if(int(yy2) == 0)//防止刻度绘制出界
								yy2 = 1;
							if(int(yy) == 0)
								yy = 1;
							if(yy2 < 0 || yy < 0)
								continue;
							if(i == 0)
							{
								if(j == 0)
								{
									_canvas.graphics.moveTo(p0.x + 5,yy);
									_canvas.graphics.lineTo(p0.x,yy);
									_canvas.graphics.moveTo(p0.x + 5,yy2);
									_canvas.graphics.lineTo(p0.x,yy2);
									lineEnd.y = yy2; 
								}
								else
								{
									_canvas.graphics.moveTo(p0.x + 3,yy);
									_canvas.graphics.lineTo(p0.x,yy);
									lineEnd.y = yy;
									if(((p0.y - bp.y) < 0.00000001) && !_bHasNegative)//当不显示刻度时不绘制可见范围内最后的补充刻度
										continue;
									_canvas.graphics.moveTo(p0.x + 3,yy2);
									_canvas.graphics.lineTo(p0.x,yy2);
									lineEnd.y = yy2;
								}
							}
							else
							{
								if(j == 0)
									_canvas.graphics.moveTo(p0.x + 5,yy);
								else
								{
									if(Math.abs(yy) < 1)
										yy = 1;
									_canvas.graphics.moveTo(p0.x + 3,yy);
								}
									
								_canvas.graphics.lineTo(p0.x,yy);
								lineEnd.y = yy;
							}
						}
					}
					
				}
				//创建刻度文本
				if((p0.y) >= clipRect.top && (p0.y) <= clipRect.bottom)
				{
					textObj = new TextField();
					if((p0.y - text_r.height / 2) < clipRect.top)
					{
						p0.y = clipRect.top + text_r.height / 2;
					}
					else if((p0.y + text_r.height / 2) > clipRect.bottom)
					{
						p0.y = clipRect.bottom - text_r.height / 2;
					}
					
					textObj.autoSize = TextFieldAutoSize.LEFT;
					textObj.x = p0.x + 7;
					textObj.y = p0.y - text_r.height / 2;
					textObj.text = text_arr[i];
					textObj.setTextFormat(fmt);
					textObj.selectable = false;
					addFontFilter(textObj);
					if(textObj.y > (unitNameY))
						_canvas.addChild(textObj);
				}
			}
			
			if(visible_arr.length > 0)
			{
				p0.x = visible_arr[0].left + GAP;
				p0.y = int(visible_arr[0].top);
				_canvas.graphics.moveTo(p0.x,p0.y);
				p0.x = rect_arr[visible_arr.length - 1].left + GAP;
				p0.y = int(lineEnd.y) < 1 ? 1 :(int(lineEnd.y) < lineEnd.y ? int(lineEnd.y + 1) : int(lineEnd.y));
				_canvas.graphics.lineTo(p0.x,p0.y);				
			}
			
			//使用位图画刻度
			if (bUseBitmap == true)
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
			
			chartBox.currentAxis = prevAxis;//将坐标系设置为原有的
		}
		
		override protected function redrawDateTime():void
		{
			//创建字体
			var fmt:TextFormat = CreateTextFormat();
			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect:Rectangle=getMyRect(this); //frameBox.getRect(this);	
			clipRect.offset(-clipRect.x, -clipRect.y); // !!! 强制把x、y置0
			
			// 创建刻度序列
			var itemArray:Array = createDateTimeAxisItems(fmt);
			
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
				unitTextObj.visible = true;
				unitTextObj.autoSize=TextFieldAutoSize.RIGHT;
				// ！！！设置好字体和对齐方式后再设置坐标，否则会不能对齐
				unitTextObj.x=clipRect.right - 5;
				unitTextObj.y=clipRect.top;
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
					
					addFontFilter(textObj);
					
					if ((textObj.y) < (unitNameX - 5))
						_canvas.addChild(textObj);
				}
			}
			
			//使用位图画刻度
			if (bUseBitmap == true)
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
			chartBox.updateGridLineX(gridArray);
		}
		
		/**
		 * 获取Z的最大值 
		 * @param pointarr
		 * @return 
		 */		
		private function getmaxZ(pointarr:Array):Number
		{
			if(null == pointarr)
				return NaN;
			if(pointarr.length < 1)
				return NaN;
			var maxz:Number;
			maxz = pointarr[0][0].Z;
			var len:int=pointarr.length;
			for (var i:int=0; i < len; i++)
			{
				var len2:int=pointarr[i].length;
				for (var j:int=0; j < len2; j++)
				{
					if (pointarr[i][j].Z > maxz)
					{
						maxz=pointarr[i][j].Z;
					}
				}
			}
			return maxz;
		}
	}
}