package ppf.base.graphics
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.primitives.Graphic;
	
			
	/**
	 * 主波形容器
	 * @author wangke
	 * 
	 */	
	public class ChartCanvas extends Group
	{
		///////////////////////////////////////////////////////////////////////
		// 事件
		///////////////////////////////////////////////////////////////////////
		static public const EVENT_MATRIX_CHANGED:String = "matrixChanged";
		
		///////////////////////////////////////////////////////////////////////
		// 属性
		///////////////////////////////////////////////////////////////////////
		/**
		 *  数据绘图对象列表
		 */		
		public var dataDrawers:Sprite = new Sprite;
		/**
		 * 三维数据绘图对象
		 */
		public var dataDrawer3d:Sprite=new Sprite;
		/**
		 * 前景绘图对象列表 
		 */		
		public var frontDrawers:Sprite = new Sprite;
		
		/**
		 * 背景绘图对象列表 
		 */		
		public var backDrawers:Sprite = new Sprite;
		
		/**
		 * 操作绘图对象
		 */		
		public var opContainer:Sprite = new Sprite;

		/**
		 * 网格绘制回调函数 
		 * 	原型：
		 * 		function onUpdateGridLineX (canvas:ChartCanvas, gridX:Array, g:Graphics):void
		 */
		public var funUpdateGridLineX:Function=onUpdateGridLineX;
		public var funUpdateGridLineY:Function=onUpdateGridLineY;
		
		/**
		 *校正到指定的矩形大小 
		 * 原型： foo (vas:ChartCanvas, newExtent:ChartRect):ChartRect
		 * @param vas 将要被改变的 ChartCanvas
		 * @param newExtent 新的可见范围
		 * @return 返回校正后的可见范围
		 */
		public function get preSetExtent():Function
		{
			return _preSetExtent;
		}

		/**
		 * @private
		 */
		public function set preSetExtent(value:Function):void
		{
			_preSetExtent = value;
		}

		public function get viewMatrixEx():Matrix
		{
			return _viewMatrixEx;
		}

		public function set viewMatrixEx(value:Matrix):void
		{
			_viewMatrixEx = value;
			this.ApplyMatrixByExtent();
		}

		public function get maskCanvas():Group
		{			
			return _maskCanvas;	
		}
		
		public function set borderWidth(v:Number):void { _borderWidth = v; invalidateDisplayList(); }
		public function get borderWidth():Number { return _borderWidth; }
		public function set operation(op:Sprite):void
		{
			if (null != _operation && this.contains(_operation))
				opContainer.removeChild(_operation);
			
			_operation = op;
			
			if (null != op)
			{
				opContainer.addChild(op);
				op.hitArea = this;
			}
		}
		
		public function get operation():Sprite
		{
			return _operation;
		}
		
		/**
		 * RW	可见坐标范围
		 * @return 
		 * 
		 */		
		public function get extent () : ChartRect		
		{
			return _extentRect.clone();
		}
		public function set extent (r:ChartRect) : void 
		{ 
			setExtent(r); 
		}
		
		/**
		 * R	所有数据对象坐标范围 
		 * @return 
		 * 
		 */		
		public function get fullExtent () : ChartRect	
		{ 
			return getFullExtent(); 
		}

		public function get validRect():Rectangle
		{
			return _matrixValidRect.clone();
		}
		
		/**
		 * R	裁减矩形， 即窗口的范围，本地坐标 
		 * @return 
		 * 
		 */		
		public function get clipRect() : Rectangle		
		{ 
			return new Rectangle(0, 0, width - borderWidth*2, height - borderWidth*2); 
		}
		
		/**
		 * RW	是否支持漫游 鼠标滚轮事件
		 * @return 
		 * 
		 */		
		public function get enableMove():Boolean		
		{ 
			return _enableMove;	
		}
		public function set enableMove(ena:Boolean):void
		{
			// 如果需要操作，则注册鼠标事件
			_mainWaveBox.buttonMode=true;
			_mainWaveBox.useHandCursor=true;
			addEventListener(MouseEvent.MOUSE_DOWN, DiagramFrame_down,false,0,true);
//			addEventListener(MouseEvent.MOUSE_OVER, Mouse_Over,false,0,true);
			_enableMove = ena;
		}
		
		/**
		 * RW	是否支持缩放 
		 * @return 
		 * 
		 */		
		public function get enableZoom():Boolean		
		{ 
			return _enableZoom;	
		}
		public function set enableZoom(ena:Boolean):void
		{
			// 如果需要操作，则注册鼠标事件
			addEventListener(MouseEvent.MOUSE_WHEEL, DiagramFrame_wheel,false,0,true);
			_enableZoom = ena;
		}
		
		public function get clipLeft():uint 
		{ 
			return _clipLeft; 
		}
		public function set clipLeft(v:uint):void 
		{ 
			_clipLeft = v; 
			invalidateDisplayList(); 
		}
		
		public function get clipRight():uint 
		{ 
			return _clipRight; 
		}
		public function set clipRight(v:uint):void 
		{ 
			_clipRight = v; 
			invalidateDisplayList();
		}
		
		public function get clipTop():uint 
		{ 
			return _clipTop; 
		}
		public function set clipTop(v:uint):void 
		{ 
			_clipTop = v;
			invalidateDisplayList(); 
		}
		
		public function get clipBottom():uint 
		{ 
			return _clipBottom;
		}
		public function set clipBottom(v:uint):void 
		{ 
			_clipBottom = v; 
			invalidateDisplayList(); 
		}
		
		/**
		 * RW	是否允许X方向平移和缩放
		 */		
		public var enableZoomX:Boolean = true;
		
		/**
		 * RW	是否允许Y方向平移和缩放  
		 */		
		public var enableZoomY:Boolean = true;
		
		/**
		 * RW	是否允许X方向平移 
		 */		
		public var enableMoveX:Boolean = true;

		/**
		 * RW	是否允许Y方向平移 
		 */		
		public var enableMoveY:Boolean = true;
		
		/**
		 * RW	供外部使用的object变量 
		 */		
		public var target : Object;
		
		private var _allAxis:Object = {};
		private var _currentAxis:Object = null;
		private var _rootAxis:Object;
		
		public function get currentAxis():String	
		{ 
			return _currentAxis.name;	
		}
		public function set currentAxis(axisName:String):void
		{
			if (axisName == _currentAxis.name || null == _projectMatrix)
				return;

			//
			// _currentAxis
			// {
			//		name				// 坐标系名
			//		viewMatrix			// 视矩阵：由 setExtent 设置为适合的矩阵
			//		viewMatrixInvert	// 逆矩阵：由 setExtent 设置为适合的矩阵
			// }
			//
			_currentAxis.viewMatrix = _viewMatrix;
			_currentAxis.viewMatrixInvert = _viewMatrixInvert;
			
			if (null == axisName)
			{
				_currentAxis = _rootAxis;	// 根坐标系
				_viewMatrix = _currentAxis.viewMatrix; 
				_viewMatrixInvert = _currentAxis.viewMatrixInvert;
				CreateCurrentMatrix(_viewMatrix, null, _projectMatrix);
			}
			else if (_allAxis.hasOwnProperty(axisName))
			{
				_currentAxis = _allAxis[axisName];
				_viewMatrix = _currentAxis.viewMatrix; 
				_viewMatrixInvert = _currentAxis.viewMatrixInvert;
				CreateCurrentMatrix(_viewMatrix, _rootAxis.viewMatrix, _projectMatrix);
			}
			else
			{// 插入新坐标系
				_currentAxis = {};
				_currentAxis.name = axisName;
				
				_viewMatrix = new Matrix;
				_viewMatrixInvert = _viewMatrix; 
				_currentAxis.viewMatrix = _viewMatrix;
				_currentAxis.viewMatrixInvert = _viewMatrixInvert;
				_allAxis[axisName] = _currentAxis;
				CreateCurrentMatrix(_viewMatrix, _rootAxis.viewMatrix, _projectMatrix);
			}
			
			
			// 反算 extent
			var lt:Point = localToWorld(new Point(_matrixValidRect.left, _matrixValidRect.top));
			var rb:Point = localToWorld(new Point(_matrixValidRect.right, _matrixValidRect.bottom));
			_extentRect = new ChartRect(lt.x, lt.y, rb.x, rb.y);
		}
		
		public function get axisNameList():Array
		{
			var arr:Array = [];
			for each(var item:Object in this._allAxis)
			{
				arr.push(item.name);				
			}
			
			return arr;
		}
		
		///////////////////////////////////////////////////////////////////////
		// 方法
		///////////////////////////////////////////////////////////////////////
		/**
		 * 转换 本地坐标->数据坐标
		 * @param point 本地坐标
		 * @return 数据坐标
		 * 
		 */		
		public function localToWorld (point:Point) : Point
		{
			return _currentMatrixInvert.transformPoint(point);
		}

		
		/**
		 * 转换 数据坐标->本地坐标 
		 * @param point 数据坐标
		 * @return 本地坐标 
		 * 
		 */		
		public function worldToLocal (point:Point) : Point
		{
			return _currentMatrix.transformPoint(point);
		}

		/**
		 * 转换 全局坐标->数据坐标 
		 * @param point 全局坐标
		 * @return 数据坐标
		 * 
		 */		
		public function globalToWorld (point:Point) : Point
		{
			point = _mainWaveBox.globalToLocal (point);
			return _currentMatrixInvert.transformPoint(point);
		}

		/**
		 * 转换 数据坐标->全局坐标 
		 * @param point 数据坐标
		 * @return 全局坐标 
		 * 
		 */		
		public function worldToGlobal (point:Point) : Point
		{
			point = _currentMatrix.transformPoint(point);
			return _mainWaveBox.localToGlobal(point);
		}
		
		/**
		 * 转换 本地矩形->数据矩形
		 * @param r 本地矩形
		 * @return 数据矩形
		 * 
		 */		
		public function localToWorldRect (r:ChartRect) : ChartRect
		{
			var lt:Point = _currentMatrixInvert.transformPoint(r.leftTop);
			var rb:Point = _currentMatrixInvert.transformPoint(r.rightBottom);
			return new ChartRect (lt.x, lt.y, rb.x, rb.y);
		}

		/**
		 * 转换 数据矩形->本地矩形
		 * @param r 数据矩形
		 * @return 本地矩形
		 * 
		 */		
		public function worldToLocalRect (r:ChartRect) : ChartRect
		{
			var lt:Point = _currentMatrix.transformPoint(r.leftTop);
			var rb:Point = _currentMatrix.transformPoint(r.rightBottom);
			return new ChartRect (lt.x, lt.y, rb.x, rb.y);
		}

		/**
		 * 转换 全局矩形->数据矩形
		 * @param r 全局矩形
		 * @return 数据矩形
		 * 
		 */		
		public function globalToWorldRect (r:ChartRect) : ChartRect
		{
			var lt:Point = _currentMatrixInvert.transformPoint(_mainWaveBox.globalToLocal(r.leftTop));
			var rb:Point = _currentMatrixInvert.transformPoint(_mainWaveBox.globalToLocal(r.rightBottom));
			return new ChartRect (lt.x, lt.y, rb.x, rb.y);
		}

		/**
		 * 转换 数据矩形->全局矩形
		 * @param r 数据矩形
		 * @return 全局矩形
		 * 
		 */		
		public function worldToGlobalRect (r:ChartRect) : ChartRect
		{
			var lt:Point = _mainWaveBox.localToGlobal(_currentMatrix.transformPoint(r.leftTop));
			var rb:Point = _mainWaveBox.localToGlobal(_currentMatrix.transformPoint(r.rightBottom));
			return new ChartRect (lt.x, lt.y, rb.x, rb.y);
		}				
		
		/**
		 * 当前数据坐标 
		 * @return 
		 * 
		 */		
		public function get currentWorldMousePosition ():Point
		{
			var p:Point = new Point(mouseX, mouseY);
			return localToWorld(p);
		}
		
		private var _preSetExtent:Function = onPreSetExtent;
		private function onPreSetExtent(vas:ChartCanvas, newExtent:ChartRect):ChartRect
		{
			return newExtent;
		}
		
		/**
		 * 发送矩阵改变事件更新光标和游标 
		 * 
		 */		
		public function matrixUpdate():void
		{
			this._needSendModifyEvent = true;
		}
		
		/**
		 * 强制刷新  
		 * @param needEvent  是否发送发送矩阵改变事件更新光标和游标   默认false  true：发送 false：不发送
		 * 
		 */		
		public function invalidateAll(needEvent:Boolean = false):void
		{
			this._needUpdate = true;
			
			// 发送事件通知
			if (needEvent)
				_needSendModifyEvent = true;	
		}
		
		/**
		 * 设置X坐标方向的缩放比，发送事件通知
		 * @param r 矩形区域
		 * @param needEvent 是否需要发送事件
		 * @param byUser true表示由用户手动操作
		 */		
		public function setExtent (r:ChartRect, needEvent:Boolean = true, byUser:Boolean=false): void 
		{
			if (r.is_empty)
				return;		// 如果是空矩形，则视为无效操作，因为可能影响图谱后续的范围计算
			
			r = r.clone();
			var h_to_w : Number = _matrixValidRect.height / _matrixValidRect.width;
			
			//  校正 r.width = 0 或 height = 0 的错误
			if (r.width == 0)
			{
				if (r.height == 0)
					return;
				var w2 : Number = Math.abs(r.height / h_to_w);
				w2 /= 2;
				r.left -= w2;
				r.right += w2;
			}
			else if (r.height == 0)
			{
				var h2 : Number = Math.abs(r.width * h_to_w);
				h2 /= 2;
				r.bottom -= h2;
				r.top += h2;
			}
				
			var old : ChartRect = _extentRect;
			// 校正到指定的矩形大小
			_extentRect = _preSetExtent (this, r);
			 		
			try 
			{
				ApplyMatrixByExtent ();
			}
			catch(e:Error)
			{
				// 错误回滚
				_extentRect = old;
				ApplyMatrixByExtent();
			}
	
			// 发送事件通知
			if (needEvent)
			{
				_needSendModifyEvent = true;
				_hasManualChange = _hasManualChange || byUser;
			}
			_needUpdate = true;
		}
		
		/**
		 * 显示所有数据
		 * @param scale 指定将外框扩大指定的比例
		 */
		public function setFullExtent(scale:Number = 1.1, needEvent:Boolean = true): void 
		{
			var r:ChartRect = getFullExtent ();
			var center:Point = new Point;
			var width:Number = r.width;
			var h:Number = Math.abs(r.height);
			if (h < 0.01)
				h = 0.01;
			if (width < 0.01)
				width = 0.01;
			center.x = (r.left + r.right)/2;
			center.y = (r.top + r.bottom)/2;
			scale /= 2;
			r.left = center.x - width*scale;
			r.right = center.x + width*scale;
			r.top = center.y - h*scale;
			r.bottom = center.y + h*scale;
			setExtent (r, needEvent);
		}
				
		/**
		 * 构造函数
		 */		
		public function ChartCanvas()
		{
			super();
			this.mouseEnabled = true;
			this.mouseChildren = true;
			percentHeight=100;
			percentWidth=100;
//			_mainWaveBox.percentHeight=100;
//			_mainWaveBox.percentWidth=100;
			this.addEventListener(Event.ADDED, onAdded);
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			this.addEventListener(Event.REMOVED, onRemoved);
			
			_rootAxis = {};
			_rootAxis.name = null;
			_rootAxis.viewMatrix = new Matrix;
			_rootAxis.viewMatrixInvert =_rootAxis.viewMatrix; 
			_currentAxis = _rootAxis; 
		}
		
		/**
		 * 绘制X网格，提供给刻度对象调用 
		 * @param gridX
		 */
		public function updateGridLineX (gridX:Array):void
		{
			if (null != funUpdateGridLineX)
				funUpdateGridLineX(this, gridX, _gridLinesX.graphics);
		}

		/**
		 * 绘制Y网格，提供给刻度对象调用 
		 * @param gridY
		 */
		public function updateGridLineY (gridY:Array):void
		{
			if (null != funUpdateGridLineY)
				funUpdateGridLineY(this, gridY, _gridLinesY.graphics);
		}
		
		static private function onUpdateGridLineX (canvas:ChartCanvas, gridX:Array, g:Graphics):void
		{
			var r : Rectangle = canvas.clipRect;
			g.clear();
			g.lineStyle(0,ChartColor.gridLine,1.0,true,LineScaleMode.NONE,null,null,1);	//线条样式
			
			var len:Number = gridX.length;
			var p0 : Point;
			for (var i:Number=0; i<len; i++)
			{
				p0 = new Point(gridX[i], 0);
				p0 = canvas.globalToLocal(p0);
				p0.y = r.top;
				 					
				var p1 : Point = p0.clone();
				p1.y = r.bottom;
				
//				g.moveTo(p0.x, p0.y);
//				g.lineTo (p1.x, p1.y);
				drawBrokenLineX(g,p0,p1);
			}
		}
		
		//绘制X虚线
		static private function drawBrokenLineX(draw:Graphics,point1:Point,point2:Point):void
		{
//			for(var i:int =0;i<=Count;i=i+2){
//				var num: Number = point2.y/Count;
//				draw.moveTo(point1.x,num*i);
//				draw.lineTo(point2.x,num*(i+1));
//			}
//			
			for(var i:int =0;i<=point2.y;i=i+2){
				draw.moveTo(point1.x,3*i);
				draw.lineTo(point2.x,3*(i+1));
			}
		}
		//绘制Y虚线
		static private function drawBrokenLineY(draw:Graphics,point1:Point,point2:Point):void
		{
			for(var i:int =0;i<=point2.x;i=i+2){
				draw.moveTo(i*3,point1.y);
				draw.lineTo((i+1)*3,point1.y);
			}
//			for(var i:int =0;i<=Count2;i=i+2){
//				var num: Number = point2.x/Count2;
//				draw.moveTo(num*i,point1.y);
//				draw.lineTo(num*(i+1),point2.y);
//			}
		}
		
		static private function onUpdateGridLineY (canvas:ChartCanvas, gridY:Array, g:Graphics):void
		{
			var r : Rectangle = canvas.clipRect;
			g.clear();
			g.lineStyle(0,ChartColor.gridLine,1.0,true,LineScaleMode.NONE,null,null,1);	//线条样式
			
			var len:Number = gridY.length;
			var p0 : Point;
			for (var i:Number=0; i<len; i++)
			{
				p0 = new Point(0, gridY[i]);
				p0 = canvas.globalToLocal(p0);
				p0.x = r.left;
				 					
				var p1 : Point = p0.clone();
				p1.x = r.right;
				
//				g.moveTo(p0.x, p0.y);
//				g.lineTo (p1.x, p1.y);
				drawBrokenLineY(g,p0,p1);
			}
		}
		
		
	
		/*************************************************************************
		 * 私有方法/属性
		 *************************************************************************/		
		/**
		 * 初始化函数
		 * 
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			initApp();
		}
		
		protected function initApp():void
		{			
			this.addElement(_maskCanvas);
			
			_maskCanvas.mouseEnabled = true;
			_maskCanvas.mouseChildren = true;
			_maskCanvas.percentHeight = 100;
			_maskCanvas.percentWidth = 100;
			
			_maskCanvas.addElement(_rootBox);
			resetCanvas();	//创建蒙板对象, 初始化点击区域
			
			 this.addEventListener(ResizeEvent.RESIZE,onReSize);
			// 发送事件通知
			_needSendModifyEvent = true;
			_needUpdate = true;
		}

		private function onAdded(e:Event):void
		{
//			if (e.target != this)
//				return;
			this.addEventListener(Event.ENTER_FRAME, onTimer, false, 0, true);
		}
		private function onRemoved(e:Event):void
		{
			if (e.target == _operation)
				_operation = null;
		}

		/**
		 *	生成当前矩阵.
		 *	通过模型矩阵和视矩阵设置本对象为当前转换矩阵 [*this = View * Project]
		 *	@param View 视转换矩阵
		 *	@param Project 模型矩阵，描述世界坐标如何映射到屏幕
		 */
		private var _projectMatrix : Matrix;
		private var _currentMatrix : Matrix = new Matrix;
		private var _currentMatrixInvert : Matrix = new Matrix;
		private var _viewMatrix : Matrix = new Matrix;
		private var _viewMatrixInvert : Matrix = _viewMatrix;
		private var _viewMatrixEx : Matrix = _viewMatrix;
		private function CreateCurrentMatrix (View:Matrix, ParentMatrix:Matrix, Project:Matrix) : void
		{
			//然后，this为　View * Eye * Project
			//此为最终矩阵，可直接通过ScreenToWorld、WorldToScreen函数进行转换
			_currentMatrix = View.clone();
			if (null != ParentMatrix)
				_currentMatrix.concat(ParentMatrix);
			if(null!=_viewMatrixEx)
				_currentMatrix.concat(_viewMatrixEx);
			_currentMatrix.concat(Project);
			_currentMatrixInvert = _currentMatrix.clone();
			_currentMatrixInvert.invert();
		}
		
		private function CreateProjectMatrix(r:Rectangle, fWidth:Number, fHeight:Number) : Matrix
		{
			// (DXs / DXw) = scale_x ==> Xs = center_x + Xw * scale_x
			// (DYs / DYw) = scale_y ==> Ys = center_y - Yw * scale_y		
			var scale_x:Number = r.width / fWidth;
			var scale_y:Number = r.height / fHeight;
			var center_x:Number = (r.left + r.right)/ 2;
			var center_y:Number = (r.top + r.bottom) / 2;
			
			var m:Matrix = new Matrix; 
			m.a = scale_x;				m.tx = center_x;
			m.d = -scale_y;				m.ty = center_y;
			
			return m;
		}
		
		protected function ApplyMatrixByExtent() : Boolean
		{
			if(_matrixValidRect.width <= 0)
				return false;
			
			var m_fViewPortW : Number = 1.0;
			var m_fViewPortH : Number = m_fViewPortW * _matrixValidRect.height / _matrixValidRect.width;
			_projectMatrix = CreateProjectMatrix (
				//new Rectangle(0, 0, _clipRect.width, _clipRect.height),
				validRect,
				m_fViewPortW, m_fViewPortH);
		
			var lt:Point = (_extentRect.leftTop);
			var rb:Point = (_extentRect.rightBottom);
			var parentMatrix:Matrix = null;
			
			// 规格化
			var center_x : Number = (lt.x + rb.x) / 2;
			var center_y : Number = (lt.y + rb.y) / 2;
			var scaleX : Number = m_fViewPortW / (rb.x - lt.x);
			var scaleY : Number = Math.abs(m_fViewPortH / (rb.y - lt.y));
			
			// 根据可见范围计算出基本的视矩阵 mv
			var mv:Matrix = new Matrix;
			mv.translate(-center_x, -center_y);//坐标平移
			mv.scale(scaleX, scaleY);
			//mv.concat(_viewMatrix);
			
			// 如果当前不是根坐标系，将视矩阵与跟坐标系的根矩阵相乘，效果叠加
			if (_currentAxis != _rootAxis)
			{
				parentMatrix = _rootAxis.viewMatrix;
				mv.concat(_rootAxis.viewMatrixInvert);
			}
			
			// 计算逆矩阵 mvInvert
			var mvInvert:Matrix = mv.clone();
			mvInvert.invert();
			_currentAxis.viewMatrix = mv;
			_currentAxis.viewMatrixInvert = mvInvert; 
			
			_viewMatrix = mv;
			_viewMatrixInvert = mvInvert;
			
			// 坐标转换
			CreateCurrentMatrix(mv, parentMatrix, _projectMatrix);
						
			// 反算 extent
//			lt = localToWorld(_clipRect.topLeft);
//			rb = localToWorld(_clipRect.bottomRight);
//			var new_m_extentRect:ChartRect = new ChartRect(lt.x, lt.y, rb.x, rb.y);
						
			return true;
		}
		
		protected function _updateDisplayList (force:Boolean) : void
		{
			var oldAxis:String = currentAxis;
			var item : ChartDrawer;
			var i : int;
			for(i=0;i<backDrawers.numChildren;i++)
			{
				if(backDrawers.getChildAt(i) is ChartDrawer)
				{
					item=backDrawers.getChildAt(i) as ChartDrawer;
					if (force || item.dirty)
					{
						currentAxis = item.axisName;
						item.Draw(this);
					}
				}
			}
			
			for(i=0;i<dataDrawers.numChildren;i++)
			{
				if(dataDrawers.getChildAt(i) is ChartDrawer)
				{
					item=dataDrawers.getChildAt(i) as ChartDrawer;
					if (force || item.dirty)
					{
						currentAxis = item.axisName;
						item.Draw(this);
					}
				}
			}
			
			for(i=0;i<frontDrawers.numChildren;i++)
			{
				if(frontDrawers.getChildAt(i) is ChartDrawer)
				{
					item=frontDrawers.getChildAt(i) as ChartDrawer;
					if (force || item.dirty)
					{
						currentAxis = item.axisName;
						item.Draw(this);
					}
				}
			}
			
			if (_operation is ChartDrawer)
			{
				item=_operation  as ChartDrawer;
				if (force || item.dirty)
				{
					currentAxis = item.axisName;
					item.Draw(this);
				}
			}
			
			currentAxis = oldAxis;
		}
	
		/**
		 * 设置蒙版图形；设置后，canvas中处于蒙版外的图形将被裁剪而不可见
		 * 注：此图形必须是填充的
		 * @param obj
		 */
		public function set canvasMask(value:DisplayObject):void
		{
			_userMask = value;
			_needResetCanvas = true;
		}
		
		public function get canvasMask():DisplayObject
		{
			return _userMask;
		}		
		
		public function set canvasHitArea(value:Sprite):void
		{
			_userHitArea = value;
			_needResetCanvas = true;
			this.hitArea = value;
		}
		
		public function get canvasHitArea():Sprite
		{
			return _userHitArea;
		}
		
		private function resetCanvas ():void
		{
			resetClipRect ();
			ApplyMatrixByExtent();
			while (_rootBox.numChildren > 0)
				_rootBox.removeChildAt(0);
			var bound:Rectangle = clipRect;
			
			// 加入蒙板对象，裁剪波形
			if (null == _userMask)
			{
				var _maskObj:Sprite = new Sprite;
				_maskObj.graphics.beginFill(ChartColor.axisBorder);//0xEEEEEE
				_maskObj.graphics.drawRect(bound.x - _borderWidth, bound.y - _borderWidth, bound.width + _borderWidth * 2, bound.height + _borderWidth * 2);
//				_maskObj.graphics.drawRect(0, 0, width, height);
				_maskObj.opaqueBackground = ChartColor.axisBorder;
				_rootBox.mask = _maskObj;
				_rootBox.addChild(_maskObj);
			}
			else
			{
				_rootBox.mask = _userMask;
				_rootBox.addChild(_userMask);
			}
			
			//加入点击区域
			if (null == _userHitArea)
			{
				var _hitObj:Sprite = new Sprite;
				_hitObj.graphics.beginFill(ChartColor.axisBorder);
				//_hitObj.graphics.drawRect(bound.x - _borderWidth, bound.y - _borderWidth, bound.width + _borderWidth * 2, bound.height + _borderWidth * 2);
				_hitObj.graphics.drawRect(0, 0, width, height);

				_hitObj.visible = false;
				_rootBox.hitArea = _hitObj;
				_rootBox.addChild(_hitObj);
			}
			else
			{
				_rootBox.hitArea = _userHitArea;
				_rootBox.addChild(_userHitArea);
			}
			
			// 加入网格对象
			_rootBox.addChild(_gridLinesX);
			_rootBox.addChild(_gridLinesY);
			
			// 加入绘图主容器
			_rootBox.addChild(_mainWaveBox);
			_mainWaveBox.x = bound.x;
			_mainWaveBox.y = bound.y;
			_mainWaveBox.mouseEnabled = true;
			_mainWaveBox.mouseChildren = true;

			// 加入外边框
			if (_borderWidth > 0)
			{
				_bordLine.graphics.clear();
				_bordLine.graphics.lineStyle(_borderWidth, _borderColor);
				_bordLine.graphics.drawRect(bound.x - _borderWidth / 2, bound.y - _borderWidth / 2, bound.width + _borderWidth, bound.height + _borderWidth);
//				_bordLine.graphics.drawRect(clipRect.x - _borderWidth / 2, clipRect.y - _borderWidth / 2, clipRect.width + _borderWidth, clipRect.height + _borderWidth);
				_rootBox.addChild(_bordLine);
			}
			
			// 加入绘图者
			_mainWaveBox.addChild(backDrawers);
			_mainWaveBox.addChild(dataDrawers);
			_mainWaveBox.addChild(frontDrawers);
			_mainWaveBox.addChild(opContainer);
									
			// 发送事件通知
			_needSendModifyEvent = true;
			_needUpdate = true;
		}
		
		private function onTimer (ee:Event):void
		{
			if (null == this.stage)
			{// 如果父文档已经不存在, 证明当前对象已被删除
				this.removeEventListener(Event.ENTER_FRAME, onTimer);
				return;
			}
			
			if (_needResetCanvas)
			{
				resetCanvas();
				_needResetCanvas = false;
				return;
			}
			
			if (_needSendModifyEvent)
			{
				var e:EventMatrixChange=new EventMatrixChange(EVENT_MATRIX_CHANGED,true);
				e.hasManual = _hasManualChange;
				_hasManualChange = false;
				dispatchEvent(e);
			}
			
			if (_needUpdate)
			{
				_updateDisplayList(true);
			}
			else
				_updateDisplayList(false);
				
			if (_needSendModifyEvent || _needUpdate)
			{
				_needSendModifyEvent = false;
				_needUpdate = false;
			}
		}
		
		/**
		 * 获取已加载数据范围
		 * @return 
		 * 
		 */		
		protected function getFullExtent () : ChartRect
		{
			var r : ChartRect = new ChartRect;
			var item : ChartDrawer;
			var m:Matrix;
			var lt:Point;
			var rb:Point;
			for(var i:int=0;i<dataDrawers.numChildren;i++)
			{
				try 
				{
					if(dataDrawers.getChildAt(i) is ChartDrawer)
					{
						item=dataDrawers.getChildAt(i) as ChartDrawer;
						var item_r : ChartRect = item.getExtent().clone();
						// 转换到当前坐标系
						if (this._rootAxis == this._currentAxis)
						{
							var name:String = item.axisName;
							if (_allAxis.hasOwnProperty(name))
							{
								m = _allAxis[name].viewMatrix as Matrix;
								lt = m.transformPoint(item_r.leftTop);
								rb = m.transformPoint(item_r.rightBottom);
								item_r.setPoint(lt, rb);
							}
						}
						else if (this.currentAxis != item.axisName)
							continue;	// 如果属于不同坐标系，不参与范围计算
						
						if (item_r != null)
							r.union_rect(item_r);
					}
				}
				catch (e:Error)
				{
				}
			}			
			
			return r;
		}
				
		/**
		 * 响应控件RESIZE事件，适应大小的变化
		 * @param e Resize事件
		 * 
		 */
		protected function onReSize(e:ResizeEvent):void
		{
			// 重设背景和点击区域
			resetCanvas();
		}
				
		/**
		 * 重置裁剪矩形范围
		 * 
		 */		
		private function resetClipRect():void
		{
			var bound:Rectangle = new Rectangle;
			bound.x = this._clipLeft + _borderWidth;
			bound.y = this._clipTop + _borderWidth;
			bound.width = width - this._clipLeft - this._clipRight - _borderWidth * 2;
			bound.height = height - this._clipTop - this._clipBottom - _borderWidth * 2;
			_matrixValidRect = bound;			
		}

		///////////////////////////////////////////////////////
		// Events
		/**
		 * 起点
		 */
		private var _startPoint:Point=new Point;
		/**
		 * 鼠标按下处理函数，注册舞台的事件监听，记住：起点，MainWaveBox在鼠标按下时的位置
		 * @param e 鼠标事件
		 * 
		 */
		private function DiagramFrame_down(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move,false,0,true);
			_startPoint=new Point(e.stageX,e.stageY);
		}
//		private function Mouse_Over(e:MouseEvent):void
//		{
//			_startPoint=new Point(e.stageX,e.stageY);
//		}
		/**
		 * 鼠标松开处理函数，删除舞台的事件监听
		 * @param e 鼠标事件
		 * 
		 */
		private function DiagramFrame_up(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, DiagramFrame_up);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, DiagramFrame_move);
		}
		/**
		 * 鼠标按下并移动的处理函数，移动MainWaveBox的位置
		 * @param e 鼠标事件
		 * 
		 */
		private function DiagramFrame_move(e:MouseEvent):void
		{	
			var cur:Point = new Point(e.stageX,e.stageY);
			var old_w:Point=globalToWorld(_startPoint);
			var cur_w:Point = globalToWorld(cur);
			_startPoint = cur;
			
			var r:ChartRect = extent;
			var off_x:Number = enableZoomX ? old_w.x - cur_w.x : 0;
			var off_y:Number = enableZoomY ? old_w.y - cur_w.y : 0;
			r.offset(off_x, off_y);
			setExtent (r, true, true);
		}
		
		/**
		 * 限制缩放大小，最大不超过 _precisionX, _precisionY 指定的精度
		 * 最小不小于屏幕的 1/100
		 * @param newExtent 最新矩形
		 * @param scaleX X方向放大比例
		 * @param scaleY Y方向放大比例
		 * @param p 缩放中心
		 * @return 返回矫正后的新矩形
		 */
		private function zoomLimit (newExtent:ChartRect, scaleX:Number, scaleY:Number, p:Point = null):ChartRect
		{
			const MIN_SCALE_PARAM:Number = 100;
			
			if (scaleX == 0)	
				scaleX = 1;
			if (scaleY == 0)	
				scaleY = 1;
			
			var cur_extent:ChartRect = newExtent.clone();
			var cur:Point = p;
			if (null == cur)
				cur = cur_extent.center;
			
			var full:ChartRect = fullExtent.clone();
			var m1:Matrix=new Matrix  ;
			var m2:Matrix=new Matrix  ;
			var m3:Matrix=new Matrix  ;
			m1.translate(-cur.x, -cur.y);
			m2.scale(1/scaleX, 1/scaleY);
			m3.translate(cur.x, cur.y);
			m1.concat(m2);
			m1.concat(m3);
			
			cur_extent.leftTop = m1.transformPoint(cur_extent.leftTop);
			cur_extent.rightBottom = m1.transformPoint(cur_extent.rightBottom);

			return cur_extent;
		}
		
		/**
		 * 缩放 
		 * @param scaleX 水平缩放系数
		 * @param scaleY 垂直缩放系数
		 * @param p 缩放点（目前是数据点）
		 * @param computOnly 是否只是作为返回数值而不做实际的缩放设置 true：只返回值 false：要做缩放设置
		 * @return ChartRect
		 * 
		 */		
		public function zoom (scaleX:Number, scaleY:Number, p:Point = null, computOnly:Boolean = false, byUser:Boolean = false):ChartRect
		{
			var cur_extent:ChartRect = zoomLimit (extent, scaleX, scaleY, p);
			if (!computOnly)
				setExtent (cur_extent, true, byUser);
			
			return cur_extent;
		} 
		
		/**
		 * 鼠标滚轮缩放事件
		 * @param e 鼠标事件
		 * 
		 */
		private function DiagramFrame_wheel(e:MouseEvent):void
		{
			var cur:Point = globalToWorld(new Point(e.stageX,e.stageY));
			var cur_extent:ChartRect = extent;
			var scale:Number;
			if (e.delta>0) 
			{
//				scale=e.delta*0.4;
				//往前滚放大
				scale=1.2
			} 
			else 
			{
//				scale = -1/(e.delta*0.4);
				//往后滚缩小
				scale = 0.8;
			}
			
			zoom (enableZoomX ? scale : 1, enableZoomY ? scale : 1, cur, false, true);
		}
		 
		/**
		 * 主波形容器，鼠标的缩放、移动操作对像
		 */
		private var _rootBox:UIComponent = new UIComponent;
		protected var _mainWaveBox:Sprite= new Sprite;
		private var _enableMove : Boolean = false;
		private var _enableZoom : Boolean = false;
		private var _borderWidth:Number = 2;	// 外框宽度
		private var _borderColor:Number = ChartColor.boundaryLine;	// 外框颜色，默认为黑色
		
		/**
		 * 窗口范围矩形，属于窗口坐标系，坐标原点在当前控件左上角
		 */		 
		private var _matrixValidRect : Rectangle = new Rectangle;
		/**
		 * 保存当前world坐标系的可见范围
		 */
		private var _extentRect : ChartRect = new ChartRect(0, 0, 1, 1);
		private var _clipLeft:uint = 5;
		private var _clipRight:uint = 5;
		private var _clipTop:uint = 5;
		private var _clipBottom:uint = 5;

		/**
		 * 网格绘制对象
		 */
		private var _gridLinesX : Sprite= new Sprite();
		private var _gridLinesY : Sprite= new Sprite();
		private var _bordLine:Sprite = new Sprite();
		
		private var _needSendModifyEvent:Boolean = false;		// 需要发送矩阵变化的事件
		private var _hasManualChange:Boolean = false;			// 需要发送手动操作事件
		private var _needUpdate:Boolean = false;
		private var _needResetCanvas:Boolean = true;
		private var _operation:Sprite;
		private var _maskCanvas:Group = new Group;
		
		private var _userMask:DisplayObject;
		private var _userHitArea:Sprite;
		static private var Count : int = 300 ; //虚线段数
		static private var Count2 : int = 300
	}
}