package ppf.base.graphics.axis
{
	import ppf.base.math.MathUtil;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	import mx.core.UIComponent;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.graphics.DataDrawer;

	/**
	 * 坐标类，Z轴
	 * @author yiyi
	 */
	public class AxisZ extends AxisY
	{
		public function AxisZ()
		{
			super();
		}
		
		/**
		 * 单位与刻度之间的间隔
		 */
		public var GAP:Number=5;
		public var xtrans:Number=10; //平移量
		public var textHeight:Number=0;
		
		private var _minz:Number=Number.NEGATIVE_INFINITY;
		private var _maxz:Number=Number.POSITIVE_INFINITY;
		private var _isSpeed:Boolean=false;
		private var arrpointColl:Array;//数据源
		/**
		 * 绘图用的画板
		 */
		private var _canvas:Sprite;
		/**
		 *存储画刻度的所有点 
		 */		
		private var tmppointarr:Array;
		/**
		 *存储所有的文本对象 
		 */		
		private var tmptextarr:Array;
		/**
		 * 绘制位图
		 */ 
		private var myBitmapData:BitmapData
		/**
		 * 绘制位图用的画布
		 */ 
		private var bmp:Bitmap;
		/**
		 * 是否使用位图 解决旋转显示问题
		 */
		private var _bUseBitmap:Boolean=false;
		
		private var _unitVisible:Boolean;

		override public function get bUseBitmap():Boolean
		{
			return _bUseBitmap;
		}
		
		/**
		 * 是否使用位图 
		 * @param isuse
		 */
		override public function set bUseBitmap(isuse:Boolean):void
		{
			_bUseBitmap = isuse;
		}

		/**
		 * 是否是转速轴
		 */
		public function get isSpeed():Boolean
		{
			return _isSpeed;
		}

		public function set isSpeed(isspeed:Boolean):void
		{
			_isSpeed=isspeed;
		}

		/**
		 * Z的最大值
		 */
		public function get maxZ():Number
		{
			if (_maxz != Number.POSITIVE_INFINITY)
				return _maxz;
			return getmaxZ(point3dArr);
		}

		public function get minZ():Number
		{
			if (_minz != Number.NEGATIVE_INFINITY)
				return _minz;
			return getminZ(point3dArr);
		}

		public function set maxZ(max:Number):void
		{
			_maxz = max;
		}

		public function set minZ(min:Number):void
		{
			_minz = min;
		}
		
		/**
		 * 设置单位的可见性 
		 * @param value
		 */		
		override public function set unitVisible(value:Boolean):void
		{
			_unitVisible = value;
		}

		override protected function onsetExtent(old_r:ChartRect, new_r:ChartRect):ChartRect
		{
			new_r.left=old_r.left;
			new_r.right=old_r.right;
			return new_r;
		}

		override protected function get isX():Boolean
		{
			return false;
		}
		
		override protected function onRedrawAxis(e:Event):void
		{
			if(this.visible == false)
				return;
			if (_canvas != null && this.contains(_canvas))
				_body.removeChild(_canvas);
			if(bmp!=null&&this.contains(bmp))
				_body.removeChild(bmp)
			if(style == AxisBase.STYLE_NUMBER && !isSpeed)
			{
				super.onRedrawAxis(e);
				return;
			}
			_canvas = new Sprite;
			var clipRect:Rectangle = getMyRect(this); //获得当前矩形
			var fmt:TextFormat = CreateTextFormat(); //调用基类的方法，创建字体
			var point:Point; //绘图点
			arrpointColl = point3dArr;
			if(point3dArr == null || point3dArr.length<1)
				return;
			var data3dDrawer:DataDrawer;
			for(var i:int=0;i<chartBox.dataDrawers.numChildren;i++)
			{
				if(chartBox.dataDrawers.getChildAt(i) is DataDrawer)
				{
					data3dDrawer=chartBox.dataDrawers.getChildAt(i) as DataDrawer;
					break;
				}
			}
			var t_point:Point;
			var len3:int = arrpointColl.length;
			var txt_rect2:Array = [];
			var txtobj:TextField;
			var txtObjArr:Array = [];
			_canvas.graphics.lineStyle (0,ChartColor.axisBorder,1.0,true,LineScaleMode.NONE,null,null,1);
			// 使用刻度对象的边界作为坐标的裁剪边界
			var clipRect2:Rectangle = getMyRect(this);
			var prey:Number = 0;
			tmppointarr = [];//2012-7-13
			
			var pretextObj:TextField;
			var lt:int;
			var max_text_sizeX:int = 0;
			for(var i2:int=0;i2<len3;i2++)//创建刻度
			{
				t_point = new Point;
				t_point.y = getMiny(arrpointColl[i2]);
				t_point = chartBox.worldToLocal(t_point);
				txtobj = new TextField;
				if(_isSpeed)
					txtobj.text = arrpointColl[i2][0].S;
				else
					txtobj.text = createTextTime(data3dDrawer.pointY[i2][1]);//获取真实的y文字
				txtobj.x = 0;
				txtobj.y = t_point.y-txtobj.textHeight/2;
				
				lt = txtObjArr.length;
				var rect:Rectangle;
				var isintesect:Boolean=false;
				var cur_rect:Rectangle=new Rectangle(txtobj.x,txtobj.y,txtobj.textWidth,txtobj.textHeight);
				for(var  t:int=0;t<lt;t++)
				{
					pretextObj = txtObjArr[t] as TextField;
					rect=new Rectangle(pretextObj.x,pretextObj.y,pretextObj.textWidth,pretextObj.textHeight);
					if(cur_rect.intersects(rect))
						isintesect=true;
				}
				if(!isintesect || i2 == 0)//如果没有相交 则画出当前的文字
				{
					max_text_sizeX = Math.max(txtobj.textWidth,max_text_sizeX);
					txtObjArr.push(txtobj);
					_canvas.addChild(txtobj);
				}
			}
			
			//刻度宽度自适应  在最大宽度与最小宽度之间自动调整  
			if((max_text_sizeX + 10) > maxWidth)
				this.width = maxWidth;
			else if((max_text_sizeX + 10) < minWidth)
				this.width = minWidth;
			else
				this.width = max_text_sizeX + 10;

			//使用位图绘制刻度文本    否则旋转之后文字不能显示
			if (_bUseBitmap == true)
			{
				myBitmapData = new BitmapData(this.width, this.height);
				myBitmapData.draw(_canvas);
				bmp = new Bitmap(myBitmapData);
				bmp.smoothing = true;
				_body.addChild(bmp);
			}
			else
				_body.addChildAt(_canvas, 0);
		}
		
		private function createTextTime(value:Number):String
		{
			if(!isNaN(value))
			{
				var date:Date = new Date(value);
				var str:String = "";
				
				str += createDoubDigit(date.hours) + ":" + createDoubDigit(date.minutes) + ":" + createDoubDigit(date.seconds);
				return str;
			}
			return "";
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
		 * 获取每条谱线y最小值 给转速文本定位 
		 * @param arr
		 * @return 
		 */
		private function getMiny(arr:Array):Number
		{
			var nmin:Number = arr[0].Y;
			var len:int=arr.length;
			for (var i:int=0; i < len; i++)
			{
				if (arr[i].Y < nmin)
					nmin = arr[i].Y;
			}
			return nmin;
		}

		/**
		 * 获取Z的最大值 
		 * @param pointarr
		 * @return 
		 */		
		private function getmaxZ(pointarr:Array):Number
		{
			var maxz:Number;
			maxz = pointarr[0][0].Z;
			var len:int = pointarr.length;
			for (var i:int=0; i < len; i++)
			{
				var len2:int=pointarr[i].length;
				for (var j:int=0; j < len2; j++)
				{
					if (pointarr[i][j].Z > maxz)
					{
						maxz = pointarr[i][j].Z;
					}
				}
			}
			return maxz;
		}
		
		/**
		 * 获取Z的最小值 
		 * @param pointarr
		 * @return 
		 */
		private function getminZ(pointarr:Array):Number
		{
			var minz:Number;
			minz = pointarr[0][0].Z;
			var len:int = pointarr.length;
			for (var i:int=0; i < len; i++)
			{
				var len2:int = pointarr[i].length;
				for (var j:int=0; j < len2; j++)
				{
					if (pointarr[i][j].Z < minz)
					{
						minz = pointarr[i][j].Z;
					}
				}
			}
			return minz;
		}
	}
}
