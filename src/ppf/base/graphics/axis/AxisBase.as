package ppf.base.graphics.axis
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.*;
	import flash.text.*;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;
	
	import org.flexunit.asserts.assertEquals;
	
	import ppf.base.frame.IDispose;
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.ChartRect;
	import ppf.base.graphics.DataDrawer;
	import ppf.base.math.MathUtil;
	import ppf.base.math.StringUtil;
	import ppf.base.resources.LocaleConst;
	
	import spark.components.Group;
	
	/**
	 * 刻度对象的基类
	 * 从此类派生出的对象有 AxisX、AxisY
	 * 本基类直接支持的功能如下：
	 *   从 Canvas 继承，可直接在MXML中进行布局，设置颜色等
	 *   通过 WaveBox 设置关联的ChartCanvas对象
	 *   支持刻度单位的设置
	 *   支持鼠标的拖动、滚轮等操作
	 *   支持刻度文本的格式化以及风格设置，支持的风格有：数字、角度、日期时间、UTC时间
	 *   支持显示精度的设置
	 *   通过 get axisName 属性，支持多坐标系统的刻度显示
	 * @author luoliang
	 */
	public class AxisBase extends Group implements IDispose
	{
		public var isShowTime:Boolean = true;
		public var isShowMillisecond:Boolean = true;
		/**
		 * 构造函数
		 * 
		 */		
		public function AxisBase()
		{	//初始化
			super();
			this.addElement(_body);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,init);
		}
				
		/**
		 * 刻度格式化风格 
		 */		
		public static var STYLE_NUMBER : int = 0;
		public static var STYLE_ANGLE : int = 1;
		public static var STYLE_DATETIME : int = 2;
		public static var STYLE_UTCTIME : int = 3;
		public static var STYLE_PERCENT : int = 4;
		public static var STYLE_POINT: int = 5;
		public static var STYLE_RLTVDATETIME:int = 6;	// 显示时间间隔
		public static var STYLE_DIGIT : int = 7;					// 二进制数位分度坐标，用于采样序号的显示
		
		/**
		 * 是否画GridLine 
		 */		
		public var isGridLine:Boolean = true;
		/**
		 *  记录所关联的图谱对象
		 */		
		public var chartBox:ChartCanvas;
		
		/**
		 *获得数组 目的是获取z值
		 */ 
		public function get point3dArr():Array
		{
			var data3dDrawer:DataDrawer;
			for(var i:int=0;i<chartBox.dataDrawers.numChildren;i++)
			{
				if(chartBox.dataDrawers.getChildAt(i) is DataDrawer)
				{
					data3dDrawer=chartBox.dataDrawers.getChildAt(i) as DataDrawer;
					if(data3dDrawer.pointArr!=null)
					return data3dDrawer.pointArr;
				}
			}
			return null;
		}
		/**
		 * 风格 
		 * STYLE_NUMBER：数字 
		 * STYLE_ANGLE：角度 
		 * STYLE_DATETIME：时间 
		 * STYLE_UTCTIME：UTC时间 
		 * STYLE_PERCENT：百分比 
		 * STYLE_POINT：点数
		 * @param s  风格
		 * 
		 */		
		public function set style(s:int):void	
		{	
			_style = s;	
			if(isX)
			{
				switch(_style)
				{
					case STYLE_NUMBER:
						_precisionX = 1 / Math.pow(10, this.precision) / axisScale / 25;
						break;
					case STYLE_DATETIME:
						_precisionX = 1 / Math.pow(10, this.precision) / axisScale * 30000;
						break;
					case STYLE_UTCTIME:
						_precisionX = 1 / Math.pow(10, this.precision) / axisScale / 5;
						break;
					case STYLE_ANGLE:
						_precisionX = 1 / Math.pow(10, this.precision)/axisScale * 5;
						break;
					case STYLE_PERCENT:
						_precisionX = 1 / Math.pow(10, this.precision) / axisScale / 5;
						break;
					case STYLE_POINT:
						_precisionX = 1 / Math.pow(10, this.precision)/axisScale * 5;
						break;
					default:
						_precisionX = 1 / Math.pow(10, this.precision) / axisScale / 25;
						break;
				}
			}
			else if(isY)
			{
				switch(_style)
				{
					case STYLE_NUMBER:
						_precisionY = 1 / Math.pow(10, this.precision) / axisScale / 25;
						break;
					case STYLE_DATETIME:
						_precisionY = 1 / Math.pow(10, this.precision) / axisScale * 30000;
						break;
					case STYLE_UTCTIME:
						_precisionY = 1 / Math.pow(10, this.precision) / axisScale / 5;
						break;
					case STYLE_ANGLE:
						_precisionY = 1 / Math.pow(10, this.precision)/axisScale * 5;
						break;
					case STYLE_PERCENT:
						_precisionY = 1 / Math.pow(10, this.precision) / axisScale / 5;
						break;
					case STYLE_POINT:
						_precisionY = 1 / Math.pow(10, this.precision)/axisScale * 5;
						break;
					default:
						_precisionY = 1 / Math.pow(10, this.precision) / axisScale / 25;
						break;
				}
			}
			
		}
		/**
		 * 获取风格
		*/
		public function get style():int				
		{	
			return _style;		
		}
		
		/**
		 * 小数位数 
		 * @param _precision
		 * 
		 */		
		public function set precision(precision:int):void	
		{	
			_precision = precision;	
		}
		public function get precision():int					
		{	
			return _precision;		
		}
		
		/**
		 * 数字的小数位数
		 */		
		public var precision_Num:Number = 2;
		
		/**
		 * 是否显示负数
		 * @param has true:显示负数 false:不显示负数
		 * 
		 */		
		public function set hasNegative(has:Boolean):void	
		{	
			_bHasNegative = has;	
		}
		public function get hasNegative():Boolean			
		{	
			return _bHasNegative;	
		}
		
		/**
		 * 单位名称, unitName仅作为显示标题使用
		 * @return 
		 * 
		 */		
		public function get unitName():String				
		{	
			return _unitName; 
		}
		public function set unitName(unitName:String):void	
		{	
			_unitName = unitName; 
		}
		
		/**
		 * 获取坐标系名称
		 * 本函数在继承类中实现，当存在多个坐标系时，每次坐标转换前都将调用此属性获得坐标系名称，
		 * 并且在chartBox中进行坐标系的切换。
		 * @return 坐标系名称，默认返回null，为顶层坐标系。
		 */		
		public function get axisName():String 
		{ 
			return _axisName; 
		}
		
		public function set axisName(v:String):void 
		{ 
			_axisName = v;
		}
				
		
		/**
		 * 放大倍率，值刻度的真实值与坐标系之间的比例， 
		 *  一些特殊情况下，想要显示的刻度与坐标系不匹配，存在一个倍率关系时(譬如：米和毫米的转换)，使用此属性将显示的值放大 
		 * @return 
		 * 
		 */		
		public function get axisScale():Number 
		{ 
			return _scale; 
		}
		public function set axisScale(s:Number):void
		{
			_scale = s;
			if (null != this.parent)
				this.updateAxis(null);
		}
		
		/**
		 *是否允许操作 
		 */
		public function get enableOperator ():Boolean 
		{ 
			return _enableOp;
		}
		
		private var _enableZoom:Boolean = true;
		public function set enableZoom(value:Boolean):void{
			_enableZoom = value;
		}
		
		public function get enableZoom():Boolean{
			return _enableZoom;
		}
		
		public function set enableOperator (ena:Boolean):void
		{
			_enableOp = ena;
			try 
			{
				if (ena) 
				{
//					addEventListener(MouseEvent.MOUSE_OVER, DiagramFrame_over,false,0,true);
//					addEventListener(MouseEvent.MOUSE_OUT, DiagramFrame_out,false,0,true);
					addEventListener(MouseEvent.ROLL_OVER, DiagramFrame_over,false,0,true);
					addEventListener(MouseEvent.ROLL_OUT, DiagramFrame_out,false,0,true);
				}
				else 
				{
						DiagramFrame_out (null);
//						removeEventListener(MouseEvent.MOUSE_OVER, DiagramFrame_over);
//						removeEventListener(MouseEvent.MOUSE_OUT, DiagramFrame_out);
						removeEventListener(MouseEvent.ROLL_OVER, DiagramFrame_over);
						removeEventListener(MouseEvent.ROLL_OUT, DiagramFrame_out);
				}
			} 
			catch (e:Error) 
			{
			}
		}
		
		/**
		 * 初始化刻度对象，创建成功后必须调用此对象来注册相应的事件和初始化图形
		 */		
		public function init (e:FlexEvent):void
		{
			updateAxis();
			enableOperator = _enableOp;
			addEventListener(ResizeEvent.RESIZE,onReSize);
			
			chartBox.addEventListener("matrixChanged", updateAxis,false,0,true);//有改动时调用update
			
			onReSize (null);
		}
				
		/**
		 * 根据坐标获取刻度文本，继承类可覆盖此方法，使用其它的格式化方式显示坐标
		 * p：目标点的坐标 （Point）
		 * IsX：是否X轴（Boolean）
		 */
		public function onNeedText(p:Point, IsX:Boolean):String 
		{
			var text:String=new String  ;
			var it_val:Number=IsX ? p.x : p.y;
			
			switch (_style)
			{
				case STYLE_NUMBER:
					return this.formatNumber(it_val);
				case STYLE_DATETIME:
					return this.formatTime(it_val,isShowTime,isShowMillisecond);
				case STYLE_UTCTIME:
					return this.formatUTCTime(it_val,isShowTime,isShowMillisecond);
				case STYLE_ANGLE:
					return this.formatAngle(it_val);
				case STYLE_PERCENT:
					return this.formatPercent(it_val);
				case STYLE_POINT:
					return this.formatPoint(it_val);
				case STYLE_RLTVDATETIME:
					return this.formatRltvTime(it_val);
				default:
					return this.formatNumber(it_val);
			}
		}
		
		public function formatPoint(value:Number):String
		{
			return int(value).toString();
		}
	
		/**
		 * 以数字方式进行格式化 
		 * @param value 当前的坐标值
		 * @return 格式化完毕的字符串
		 */		
		public function formatNumber(value:Number):String
		{
//			var str:String;
//			str = MathUtil.n2s(11111, 0);
//			assertEquals(str, "11111");			
//			
//			str = MathUtil.n2s(0.0011111, 3);
//			assertEquals(str, "0.001");	
//			
//			str = MathUtil.n2s(0.0015111, 3);
//			assertEquals(str, "0.002");	
//			
//			str = MathUtil.n2s(0.0014111, 3);
//			assertEquals(str, "0.001");	
//			
//			str = MathUtil.n2s(0.009999997, 2);
//			assertEquals(str, "0.01");
//
//			str = MathUtil.n2s(0, 2);
//			assertEquals(str, "0.00");
//
//			str = MathUtil.n2s(-0.009999997, 2);
//			assertEquals(str, "-0.01");
//			
//			str = MathUtil.n2s(-0.00001, 2);
//			assertEquals(str, "0.00");
//
//			str = MathUtil.n2s(-0.00, 2);
//			assertEquals(str, "0.00");
//			
			
			if (!_bHasNegative && value < 0)
				return "";
			if (!isNaN(precision_Num))
				return MathUtil.n2s(value, precision_Num);// 保留precision_Num位小数;
			if (MathUtil.abs(value)<50)
				return MathUtil.n2s(value, 5);// 保留5位小数;
			if (MathUtil.abs(value)<500)
				return MathUtil.n2s(value, 4);// 保留4位小数;
			if (MathUtil.abs(value) < 5000)
				return MathUtil.n2s(value, 3);// 保留3位小数;
			if (MathUtil.abs(value) < 50000)
				return MathUtil.n2s(value, 2);// 保留2位小数;
			if (MathUtil.abs(value) < 100000)
				return MathUtil.n2s(value, 1);// 保留1位小数;
			return MathUtil.n2s(value, 0);// 保留n位小数;
		}

		/**
		 * 以时间方式进行格式化, 此时认为value指定的值为一个时间值 
		 * @param value 当前的坐标值
		 * @return 格式化完毕的字符串
		 */		
		public function formatTime(value:Number,isShowTime:Boolean = true, isShowMillisecond:Boolean = false):String
		{
			var t:Date = new Date;
			t.time = value;
			var year:String = t.fullYear.toString();
			var month:String = StringUtil.strFillFront((t.month + 1).toString(),2);
			var date:String = StringUtil.strFillFront(t.date.toString(),2);
			var hour:String = StringUtil.strFillFront(t.hours.toString(),2);
			var minute:String = StringUtil.strFillFront(t.minutes.toString(),2);
			var second:String;
			
			if (isShowTime)
				second = StringUtil.strFillFront(t.seconds.toString(),2);
			var str : String = "" + year + "-" + month + "-" + date + " "
				+ hour + ":" + minute + (isShowTime?(":" + second):"");
			if (isShowMillisecond && t.milliseconds > 0)
				str += "." + t.milliseconds;
			return str;
		}

		/**
		 * 以时间方式进行格式化, 此时认为value指定的值为一个时间值
		 * 与 formatTime 不同的是，本方法返回的是UTC时间文本
		 * @param value 当前的坐标值
		 * @return 格式化完毕的字符串
		 */		
		public function formatUTCTime(value:Number,isShowTime:Boolean = true, isShowMillisecond:Boolean = false):String
		{
			var t:Date = new Date;
			t.time = value;
			var str : String = "" + t.fullYearUTC + "-" + (t.monthUTC + 1) + "-" + t.dateUTC + " "
				+ t.hoursUTC + ":" + t.minutesUTC + (isShowTime?(":" + t.secondsUTC):"");
			
			if (isShowMillisecond && t.milliseconds > 0)
				str += "." + t.millisecondsUTC;
			return str;
		}
		
		/**
		 * 转换成相对时间 
		 * @param value
		 * @return  hh:mi:ss 返回 时：分：秒
		 */		
		public function formatRltvTime(value:Number):String
		{
			if(value == 0)
				return "0";
			var str:String = "";
			var temp:int = value/3600000;
			str += StringUtil.strFillFront(temp.toString(),2);//时
			temp = value % 3600000;
			temp = temp / 60000;
			str += ":" + StringUtil.strFillFront(temp.toString(),2);
			temp = value % 60000;
			temp = temp / 1000;
			str += ":" + StringUtil.strFillFront(temp.toString(),2);
			return str;
		}
		
		/**
		 * 以角度方式进行格式化，角度值在0~360度之间循环
		 * @param value 当前的坐标值
		 * @return 格式化完毕的字符串
		 * 
		 */		
		public function formatAngle(value:Number):String
		{
			value %= 360;
			if (value<0)
				value+=360;
			return MathUtil.n2s(value, 0);// 保留n位小数;
		}
		
		/**
		 * 百分比
		 * @param value 当前的坐标值
		 * @return 格式化完毕的字符串
		 * 
		 */		
		public function formatPercent(value:Number):String
		{
			if (!_bHasNegative && value < 0)
				return "";
			return MathUtil.n2s(value*100, _precision);// 保留n位小数;
		}
				
		/**
		 * 获取当前对象的矩形位置
		 * @param targetCoordinateSpace 目标对象，为空则返回的是全局坐标，否则返回的是本地坐标
		 * @return 矩形对象
		 */
		public function getMyRect(targetCoordinateSpace:DisplayObject=null):Rectangle
		{
			var bound:Rectangle=new Rectangle;
			bound.x=0;
			bound.y=0;
			bound.width=width;
			bound.height=height;

			bound.topLeft=localToGlobal(bound.topLeft);
			bound.bottomRight=localToGlobal(bound.bottomRight);
			if (targetCoordinateSpace != null)
			{			
				bound.topLeft=targetCoordinateSpace.globalToLocal(bound.topLeft);
				bound.bottomRight=targetCoordinateSpace.globalToLocal(bound.bottomRight);
			}
			return bound;
		}
		
		/**
		 * 计算刻度的步长 
		 * @param dataWidth 要在当前视图内显示的数据范围
		 * @param min_step 最小步长，为0时使用内部最小步长
		 * @return 返回刻度步长大小
		 */
		public function calculateStep (dataWidth:Number, isX:Boolean, min_step:Number = 0):Number
		{			
			if (min_step == 0)
				min_step = minStep;
			
			var screenWidth:Number;
			if (isX)
				screenWidth = width;
			else
				screenWidth = height;
			
			// 绘制横坐标
			var iSegNum:int=screenWidth / min_step;
			if (iSegNum <= 0)
				return -1;
			
			// 计算最大步长
			var min_seg:Number= dataWidth / iSegNum;
			
			// 最小粒度 nScale，最小粒度是10的n次幂
			var logn:int = 10;
			if(style == AxisBase.STYLE_DIGIT)
				logn = 2;
			else if (style == AxisBase.STYLE_ANGLE)
				logn = 45;
			var mi:Number = Math.log(min_seg) / Math.log(logn);
			mi = (mi > 0) ? int(mi+0.5) : int(mi-0.5);		// > 0 时向上取整，< 0时向下取整
			var nScale:Number=Math.pow(logn, mi);
			var seg:Number = nScale;
			
			if (logn == 10)
			{
				if (seg < min_seg)
					seg=nScale * 2;
				if (seg < min_seg)
					seg=nScale * 5;
				if (seg < min_seg)
					seg=nScale * 10;
				if(seg<=0.01)
					seg = 0.01;
			}
			else if (logn == 2)
			{
				seg = nScale ;
				if(seg < min_seg)
					seg *= 2;
			}
			else if (logn == 45)
			{
				if(nScale>1  && nScale < min_seg )
				{
				seg = nScale ;
				if(seg >min_seg)
					seg =nScale/ 45;
				if(seg < min_seg)
					seg =nScale* 2;
				if(seg < min_seg)
					seg =nScale* 4;
				if(seg < min_seg)
					seg =nScale*8;
				}
				else
				{
					nScale  = (nScale>1? int(nScale/45) : nScale);
					seg = nScale ;
					
					if(seg < min_seg)
						seg = nScale*2;
					if(seg < min_seg)
						seg =nScale* 5;
					if(seg < min_seg)
						seg = nScale*10;
					if(seg < min_seg)
						seg = nScale* 45;
				}
			}
				return seg;
		}

		/**
		 * 响应控件RESIZE事件，适应大小的变化，重新生成图形
		 * @param e Resize事件
		 */
		protected function onReSize(e:ResizeEvent):void
		{
			var bound:Rectangle = new Rectangle;	//this.getBounds(this);
			bound.height = height;
			bound.width = width;
						
			// 绘制绘图范围屏蔽蒙版
			// 创建蒙板对象，裁剪波形
			if (_maskObj != null && this.contains(_maskObj))
			{
				this.removeElement(_maskObj);
			}

			_maskObj = new UIComponent;
			_maskObj.graphics.beginFill(0xEEEEEE);
			_maskObj.graphics.drawRect(bound.x, bound.y, bound.width, bound.height);
			_maskObj.graphics.endFill();
			_maskObj.opaqueBackground = 0xFF0000;
			_maskObj.percentWidth=100;
			_maskObj.percentHeight=100;
			this.addElementAt(_maskObj, 0);
			this.mask=_maskObj;
						
			if (null != _linkBtnObj && null != _linkBtnObj.parent)
			{
				var container:DisplayObjectContainer = _linkBtnObj.parent;
				if (container is IVisualElementContainer)
					(container as IVisualElementContainer).removeElement(_linkBtnObj);
				else
					container.removeChild(_linkBtnObj);
			}
			_linkBtnObj = null;
			if (_enableOp)
			{// 绘制鼠标选中蒙版
				_linkBtnObj = new UIComponent;
				_linkBtnObj.graphics.beginFill(0xeeeeee);
				_linkBtnObj.graphics.drawRect(bound.x, bound.y, bound.width, bound.height);
				_linkBtnObj.graphics.endFill();
				_linkBtnObj.opaqueBackground = null;
				_linkBtnObj.visible=false;
				_linkBtnObj.percentWidth=100;
				_linkBtnObj.percentHeight=100;
				this.addElementAt(_linkBtnObj, 1);
			}
			this.buttonMode=_enableOp;
			this.useHandCursor=_enableOp;
			
			this.hitArea=_linkBtnObj;
		}

		/**
		 * 创建刻度字体格式
		 * @return 字体格式
		 */
		public function CreateTextFormat():TextFormat 
		{
			var fmt:TextFormat = new TextFormat();
			fmt.color=ChartColor.axisText;
			fmt.font=LocaleConst.FONT_FAMILY;
			fmt.size=12;
			fmt.align="right";
			return fmt;
		}
		
		protected function get isX():Boolean
		{
			return true;
		}
		
		protected function get isY():Boolean
		{
			return false;
		}
		
		/**
		 * 调用此函数重新绘制刻度
		 * 
		 * @param e
		 */
		public function updateAxis(e:Event=null):void
		{
			if (null == chartBox)
				return;
			chartBox.currentAxis = axisName;
			try 
			{
				onRedrawAxis(e);
			}
			catch (e:Error)
			{
			}
			chartBox.currentAxis = null;
		}
		
		/**
		 * 释放资源 
		 */	
		public function dispose():void
		{
			_body = null;
			_maskObj = null;
			_linkBtnObj = null;
			chartBox = null;
		}
		
		/**
		 * 此方法由派生类具体实现
		 * 当初始化时、chartBox的显示范围发生变化时等等，都将触发此方法更新刻度的图形
		 * @param e 事件
		 */
		protected function onRedrawAxis(e:Event):void 
		{
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.updateAxis(null);
		}
		
		/**
		 * 设置刻度所使用的光标
		 * @param cursorClass
		 */		
		protected function set cursor(cursorClass:Class):void
		{
			if (-1 != _cursorID)
			{
				mx.managers.CursorManager.removeCursor(_cursorID);
			}
			if (null != cursorClass)
			{
				_cursorID = mx.managers.CursorManager.setCursor(cursorClass);
			}
		}
		
		/**
		 * 响应缩放、移动等操作，并校正缩放范围
		 * 此函数可在继承类中重写
		 * @param old_r
		 * @param new_r
		 * @return 
		 */		
		protected function onsetExtent (old_r:ChartRect, new_r:ChartRect):ChartRect
		{
			return new_r;
		}

		/**
		 * 添加字体阴影滤镜 
		 * @param label
		 */		
		protected function addFontFilter (label:TextField):void
		{
			//label.filters = _myFilters;
		}
		
		private function DiagramFrame_out(e:MouseEvent):void
		{
			try
			{
				_isOut = true;
				cursor = null;
				removeEventListener(MouseEvent.MOUSE_WHEEL, DiagramFrame_wheel);
				removeEventListener(MouseEvent.MOUSE_DOWN, DiagramFrame_down);
//			removeEventListener(MouseEvent.ROLL_OUT, DiagramFrame_out);
			}
			catch (e:Error)
			{
			}
		}
		
		/**
		 * 鼠标移入函数
		 * @param e 鼠标事件
		 */		
		private function DiagramFrame_over(e:MouseEvent):void
		{
			_isOut = false;
			if(_isDrag)
				cursor = hand_down;
			else
				cursor = hand_up;
			addEventListener(MouseEvent.MOUSE_WHEEL, DiagramFrame_wheel,false,0,true);
			addEventListener(MouseEvent.MOUSE_DOWN, DiagramFrame_down,false,0,true);
		}
		
		/**
		 * 鼠标按下处理函数，注册舞台的事件监听，记住：起点，MainWaveBox在鼠标按下时的位置
		 * @param e 鼠标事件
		 */		
		private function DiagramFrame_down(e:MouseEvent):void
		{
			_isDrag = true;
			cursor = hand_down;
//			stage.addEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up,false,0,true);
//			stage.addEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move,false,0,true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up,false,0,true);
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move,false,0,true);

			_startPoint=new Point(e.stageX,e.stageY);
		}

		/**
		 * 鼠标松开处理函数，删除舞台的事件监听
		 * @param e 鼠标事件
		 */
		private function DiagramFrame_up(e:MouseEvent):void
		{
			_isDrag = false;
			//			if (this.hitTestPoint(e.stageX, e.stageY))
			if (_isOut)
				cursor = null;
			else
				cursor = hand_up;
			//			stage.removeEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up);
			//			stage.removeEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up);
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move);
		}
		/**
		 * 鼠标按下并移动的处理函数，移动被关联chartBox的可见范围
		 * @param e 鼠标事件
		 */
		protected function DiagramFrame_move(e:MouseEvent):void 
		{
				var cur:Point = new Point(e.stageX,e.stageY);
				var old_w:Point = chartBox.globalToWorld(_startPoint);
				var cur_w:Point = chartBox.globalToWorld(cur);
				_startPoint = cur;			
				var old_r:ChartRect = chartBox.extent;
				var new_r:ChartRect = old_r.clone();
				new_r.offset(old_w.x - cur_w.x, old_w.y - cur_w.y);
				chartBox.setExtent(onsetExtent(old_r, new_r), true, true);
		}

		/**
		 * 鼠标滚轮缩放事件
		 * @param e 鼠标事件
		 */
		protected function DiagramFrame_wheel(e:MouseEvent):void
		{
			if(!enableZoom)
				return;
				//			chartBox.currentAxis = axisName;
				var cur:Point = chartBox.globalToWorld(new Point(e.stageX,e.stageY));
				var old_r:ChartRect = chartBox.extent;
				var scale:Number;
				if (e.delta>0) {
					scale=e.delta*0.4;
				} else {
					scale = -1/(e.delta*0.4);
				}
				var new_r : ChartRect = chartBox.zoom(scale, scale, cur, true);
				chartBox.setExtent(onsetExtent(old_r, new_r), true, true);
				//			chartBox.currentAxis = null;				
		}
		
		/**
		 *每两个刻度文字之间允许有_sub_step条刻度线
		 */
		public function set subStepNumber(n:int):void
		{
			if (n > 0)
			{
				_subStepNumber = n;
			}
			else
			{
				_subStepNumber = 1;
			}
		}
		
		protected var _bHasNegative:Boolean=true;	// 坐标值是否允许有负数
		protected var _unitName:String;				// 存储单位名称，如果为null则不显示单位名
		protected var _axisName:String;				// 存储单位名称，如果为null则不显示单位名
		protected var _scale:Number = 1;			// 放大倍率，值刻度的真实值与坐标系之间的比例，一些特殊情况下会用到
		protected var _body:UIComponent = new UIComponent;	// 如果要会绘制图形，请将图形对象加入到 _body 中

		protected var _startPoint:Point=new Point;	// 鼠标拖动的起点
		private var _style:int = STYLE_NUMBER;		// 显示风格，默认为数字
		private var _precision:int = 3;				// 刻度显示精度
		private var _maskObj:UIComponent;			// 屏蔽矩形
		private var _linkBtnObj:UIComponent;		// 点击区域
		private var _cursorID:int = -1;				// 刻度对象当前使用的鼠标光标ID，记录此ID是为了方便删除
		private var _enableOp:Boolean = true;
		
		private var _precisionX:Number = 1 / Math.pow(10, _precision) / _scale / 25;
		private var _precisionY:Number = 1 / Math.pow(10, _precision) / _scale / 25;

		// 为字体添加的阴影滤镜
		static private var _f:DropShadowFilter = new DropShadowFilter(1, 45, 0x000000, 1, 0, 0, 1);
		static private var _myFilters:Array = [_f];
		
		/**
		 * 是否是鼠标按下状态 
		 */		
		private var _isDrag:Boolean = false;
		/**
		 * 鼠标是否移出
		 */		
		private var _isOut:Boolean = false;
		
		[Embed(source="/assets/hand_up.png")]
		private var hand_up:Class;
		
		[Embed(source="/assets/hand_down.png")]
		private var hand_down:Class;
		
		private var _min_sep:int=25;
		protected var _subStepNumber = 5;	// 默认不显示子刻度
		
		public function get minStep():int
		{
			return _min_sep;
		}
		/**
		 * 设置刻度的最小步长
		 * @return 
		 * 
		 */
		public function set minStep(value:int):void
		{
			_min_sep = value;
		}

	}
}