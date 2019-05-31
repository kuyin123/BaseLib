package ppf.base.graphics
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;
	import mx.core.IVisualElementContainer;
	
	import ppf.base.resources.LocaleConst;
	import ppf.base.resources.LocaleManager;
	
	public class DataDrawer extends ChartDrawer
	{
		/**
		 * 显示提示时的精度 
		 */	
		public function get precision():Number
		{
			return _precision; 
		}
		
		public function set precision(value:Number):void
		{
			_precision = value;
		}
		// 常量定义
		///////////////////////////////////////////////////////////////////
		/**
		 * 删除进度条 
		 */		
		static public const DEL:int = -1;
		/**
		 *  请拖动通道对象到这里
		 */		
		static public const DRAG:int = 0;
		/**
		 *  正在请求数据 ...
		 */		
		static public const REQUEST:int = 1;
		/**
		 * 请求数据失败
		 */		
		static public const ERROR:int = 2;
		/**
		 * 无数据 
		 */		
		static public const ZERO:int = 3;
		/**
		 *  使用自定义提示
		 */		
		static public const USER_DEFINED:int = 4;
		/**
		 *  使用错误的自定义提示
		 */		
		static public const ERR_USER_DEFINED:int = 5;
		/**
		 * 停止请求数据 
		 */		
		static public const STOP:int = 5;
	
		/**
		 * 设置当前的进度条在显示列表最上层
		 */		
		public var isProcessTop:Boolean = false;
		// 共用方法
		///////////////////////////////////////////////////////////////////
		public function DataDrawer()
		{
			super();
			addEventListener(Event.REMOVED, onRemoved);//去除监听  当datadrawer重绘时会发出该事件会导致进度条显示异常
		}
	
		/**
		 * 点数组 
		 */
		public function get pointArr():Array
		{
			return _pointArr;
		}

		public function get pointY():Array
		{
			return _pointY;
		}

		public function get pointX():Array
		{
			return _pointX;
		}
		/**
		 * 获取三维z值
		 */ 
		public function get pointZ():Array
		{
			return _pointZ;
		}
		/**
		 * 获取转速值
		 */ 
		public function get pointS():Array
		{
			return _pointS;
		}
		/**
		 * 点数组 Point的对象数组 
		 * @return 
		 * 
		 */	
		public function set pointArr(value:Array):void
		{
			_pointArr = value;
			_pointX = [];
			_pointY = [];
			
			_minX = Number.POSITIVE_INFINITY;
			_maxX = Number.NEGATIVE_INFINITY;
			_minY = Number.POSITIVE_INFINITY;
			_maxY = Number.NEGATIVE_INFINITY;
			
			
			for each(var p:Point in _pointArr)
			{
				pointX.push(p.x);
				pointY.push(p.y);
				
				if (p.x > _maxX) _maxX = p.x;
				if (p.x < _minX) _minX = p.x;
				if (p.y > _maxY) _maxY = p.y;
				if (p.y < _minY) _minY = p.y;
			}
		}

		/**
		 * 根据指定索引号获取坐标，范围为 [0 ~ lengh-1] 
		 * @param index
		 * @param x
		 * @return 
		 * 
		 */		
		public function getPointByIndex(index:Number,x:Number=0):Point
		{
			throw new Event("getPointByIndex not implemented!!!");
		}

		/**
		 * 通过 X 坐标查找最近的点索引号
		 * 继承的绘图类应重写 indexOfWaveX
		 * @param valueX
		 * @return 
		 * 
		 */		
		public function indexOfWaveX(valueX:Number, valueY:Number=NaN):Number
		{
			return -1;
		}
		
		/**
		 * 赋值DataDrawer 
		 * @return DataDrawer
		 * 
		 */		
		public function copyInfo():DataDrawer
		{
			var dataDrawer:DataDrawer = new DataDrawer;
			formatInfo(dataDrawer);
			
			return dataDrawer;
		}
		
		protected function formatInfo(dataDrawer:DataDrawer):void
		{
			dataDrawer.minY = this.minY;
			dataDrawer.maxY = this.maxY;
			dataDrawer.color = this.color;
			dataDrawer.unitName = this.unitName;
			dataDrawer.pointArr = this.pointArr;
			dataDrawer.progressDesc = this.progressDesc;
			dataDrawer._progressType = this._progressType;
			dataDrawer.setRenderProgress(this.parentCanvas,progressDesc);
		}
		
		// 共用属性
		///////////////////////////////////////////////////////////////////
		/**
		 * 当光标位置改变，OpSelection将调用此函数
		 * selectChangedFunction (index:int, point:Point, op:OpSelection, drawer:DataDrawer):Point
		 */		
		public var selectChangedFunction:Function = null;
		
		/**
		 * progressType = USER_DEFINED 进度条自定义的显示
		 */		
		public var progressDesc:String="";
		
		/**
		 * Y方向的数据最小值 
		 * @return 
		 */		
		public function get minY():Number
		{
			return _minY;
		}

		public function set minY(value:Number):void
		{
			_minY = value;
		}

		/**
		 * Y方向的最大量程 
		 * 过程量使用
		 * @return 
		 * 
		 */		
		public function get maxY():Number
		{
			return _maxY;
		}

		public function set maxY(value:Number):void
		{
			_maxY = value;
		}
		
		/**
		 * X方向的数据最小值
		 * @return 
		 */		
		public function get minX():Number
		{
			return _minX;
		}
		
		public function set minX(value:Number):void
		{
			_minX = value;
		}
		
		/**
		 * X方向的数据最大值 
		 * @return 
		 */		
		public function get maxX():Number
		{
			return _maxX;
		}
		
		public function set maxX(value:Number):void
		{
			_maxX = value;
		}

		/**
		 * 颜色
		 * @return 
		 */		
		public function get color ():Number { return _color; }
		public function set color (c:Number):void
		{
			if (_color != c)
			invalidate();
				_color = c;
		}

		override public function get axisName():String	{	return unitName;	}
		
		/**
		 * 获取单位名，如 "秒"
		 * @return 
		 */		
		public function get unitName ():String
		{
			if ("" == _unitName)
				return null;
			return _unitName;
		}
		/**
		 * 获取单位名，如 "秒"
		 * @return 
		 */		
		public function set unitName(value:String):void
		{
			_unitName = value;
		}
		

		/**
		 * 获取数据长度
		 * @return 
		 */		
		public function get length():Number
		{
			if (null != pointX)
				return pointX.length;
			throw new Event("length not implemented!!!");
		}
		
		/**
		 * 设置进度条状态 
		 * @param type 0 请拖动通道对象到这里 1 正在请求数据 ...  2 数据错误 3 无数据 
		 * 4 使用自定义提示 5 使用错误的自定义提示
		 * 
		 */		
		public function set progressType(type:int):void
		{
			_progressType = type;
			setRenderProgress(parentCanvas, getProgressLabel());
		}
		
		/**
		 * 返回进度条状态
		 */		
		public function get progressType():int
		{
			return _progressType;
		}
		
		//  重写的方法
		//////////////////////////////////////////////////////////////////////
		/**
		 * 绘制函数，ChartCanvas调用来更新Drawer的内容	 
		 * @param canvas
		 * 
		 */		
		override public function Draw (canvas:ChartCanvas) : void
		{
			super.Draw(canvas);
			setRenderProgress(canvas, getProgressLabel());
		}
		
		// 私有和保护类型属性、方法
		//////////////////////////////////////////////////////////////////////
		private function getProgressLabel():String
		{
			var lab:String = "";
			switch (_progressType)
			{
				case 0:
//					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_051') + this.progressDesc;
					break;
				case 1:
					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_049')+" ... " + this.progressDesc;
					break;
				case 2:
					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_050')+ this.progressDesc;
					break;
				case 3:
					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_052') + this.progressDesc;
					break;
				case 4:
				case 5:
					lab = this.progressDesc;
					break;
				case 6:
					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_053') + this.progressDesc;
					break;
				case 7:
					lab = LocaleManager.getInstance().getString(LocaleConst.LIB,'LIB_TIP_057') + this.progressDesc;
					break;
				default:
					break;
			}
			return lab;
		}
		
		private function onRemoved (e:Event):void
		{
			if(e.target == this)
				this.progressType = DEL;
		}
		
		/**
		 * 进度条显示 
		 * @param canvas 显示的容器对象
		 * @param desc 自定义显示的内容
		 * 
		 */		
		private  function setRenderProgress(canvas:ChartCanvas, desc:String=""):void
		{
			if (null == canvas)
				return;
			
			var lab:String = desc;
			
			if ("" == lab)
			{
				if (null != _progress && null != _progress.parent)
				{
					if (_progress.parent is IVisualElementContainer)
						(_progress.parent as IVisualElementContainer).removeElement(_progress);
					else
						_progress.parent.removeChild(_progress);
					_progress = null;
				}
				return;
			}
			
			// 如果正在获取数据，则显示进度条
			if (null == _progress)
			{
				_progress = new ProgressBar;
				_progress.labelPlacement = "center";
				_progress.indeterminate = true;
				_progress.label = lab;
				if (canvas is IVisualElementContainer)
					canvas.addElement(_progress);
				else
					canvas.addChild(_progress);
				_progress.setStyle("horizontalCenter", 0);
				_progress.setStyle("verticalCenter", 0);
				_progress.setStyle("barColor",this._color);
				if (canvas is IVisualElementContainer)
					canvas.setElementIndex(_progress,canvas.numChildren -1);
				else
					canvas.setChildIndex(_progress,canvas.numChildren -1);
			}
			else
			{
				_progress.setStyle("color",0x4D4D4D);
				_progress.setStyle("barColor",this._color);
				_progress.mode = ProgressBarMode.EVENT;
				_progress.label = lab;
				if (!canvas.contains(_progress))
				{
					if (canvas is IVisualElementContainer)
						canvas.addElement(_progress);
					else
						canvas.addChild(_progress);
				}
				
//				if (!isProcessTop)
//				{
					if (_progress.parent is IVisualElementContainer)
						(_progress.parent as IVisualElementContainer).setElementIndex(_progress,_progress.parent.numChildren -1);
					else
						_progress.parent.setChildIndex(_progress,_progress.parent.numChildren -1);
//					isProcessTop = true;
//				}
			}
			
			if (null != _progress && 
				(_progressType == DRAG || _progressType == ERROR || 
					_progressType == ZERO || _progressType == ERR_USER_DEFINED || _progressType == STOP))
			{
				_progress.mode = ProgressBarMode.MANUAL;
				_progress.setStyle("color",0xe71f19);
			}
		}	
		
		/**
		 * Z数组
		 */ 
		protected var _pointZ:Array;
		/**
		 * 转速数组
		 */ 
		protected var _pointS:Array;
		/**
		 * X数组
		 */ 
		protected var _pointX:Array;
		/**
		 * Y数组
		 */ 
		protected var _pointY:Array;
		protected var _pointArr:Array;
		
		protected var _color : Number = ChartColor.waveLine;
		protected var _maxY:Number;
		protected var _minY:Number;
		protected var _maxX:Number;
		protected var _minX:Number;
		
		/**
		 * 0 请拖动通道对象到这里
		 * 1 正在请求数据 ... 
		 * 2 数据错误
		 * 3 无数据
		 * 4 使用自定义提示
		 * 5 使用错误的自定义提示
		 */		
		private var _progressType:int = -1;
		private var _unitName:String="";
		private var _progress : ProgressBar;
		private var _precision:Number=NaN;
	}
}