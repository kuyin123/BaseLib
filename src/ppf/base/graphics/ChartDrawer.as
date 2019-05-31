package ppf.base.graphics
{
	import ppf.base.resources.AssetsUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.managers.CursorManager;
	
	/**
	 * 绘图者基类
	 */
	public class ChartDrawer extends Sprite
	{
		/**
		 * 获取数据是否已变化 
		 * @return 
		 * 
		 */		
		public function get dirty():Boolean 
		{ 
			return _bIsDirty;
		}

		/**
		 * 获取本次Rander需要重绘的矩形区域（本地像素坐标）
		 * 如果未给出失效区域，将返回 null
		 * @return 
		 */
		public function get invalidateRect():ChartRect
		{
			return _invalidateRect;
		}
		
		/**
		 * 坐标系名称，如果不为null，则Canvas根据此名称切换到子坐标系 
		 * @return 
		 * 
		 */		
		public function get axisName():String	
		{	
			return null;
		} 

		public function get cursor():String	
		{	
			return _cursorName;
		}
		public function set cursor(cursorName:String):void
		{
			if(_cursorName==cursorName)
				return;
			if (null == cursorName)
				_currentCursor = null;
			else
				_currentCursor = AssetsUtil.stringToIcon(cursorName);
				
			if (null != _currentCursor)
			{
				_cursorName = cursorName;
				if (-1 != _cursorID)
				{
					CursorManager.removeCursor(_cursorID);
					_cursorID = CursorManager.setCursor(_currentCursor, 2, cursorOffsetX, cursorOffsetY);
				}
				this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			else
			{
				_cursorName = null;
				if (-1 != _cursorID)
					CursorManager.removeCursor(_cursorID);
				this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
		}
		
		/**
		 * 获取ChartCanvas父窗口 
		 * @return 
		 * 
		 */		
		public function get parentCanvas () : ChartCanvas
		{
			try 
			{
				return parent.parent.parent.parent.parent as ChartCanvas;
			}
			catch(e:Error)
			{
			}
			return null;
		}
		
		public var cursorOffsetX:Number = 0;
		public var cursorOffsetY:Number = 0;
		
		/**
		 * 附加属性 
		 */		
		public var token : Object;
		
		/**
		 * 当Render被调用前，触发此函数
		 * 原型：onBeforeRender(drawer:ChartDrawer):void {}
		 */		
		public var onBeforeRender:Function;
		
		/**
		 *  当Render被调用后，触发此函数
		 * 	原型：onAfterRender(drawer:ChartDrawer):void {}
		 */		
		public var onAfterRender:Function;

		/**
		 * 设置数据由变化 
		 * @param invalidateRect 失效的数据范围
		 */
		public function invalidate (invalid_rect:ChartRect=null) : void
		{ 
			if (_invalidateRect)
			{
				if (invalid_rect)
					_invalidateRect.union_rect(invalid_rect);
				else
					_invalidateRect = null;
			}
			else
			{
				if (!_bIsDirty)
					_invalidateRect = invalid_rect;
			}
			
			_bIsDirty = true;
		}
		
		/**
		 * 绘制函数，ChartCanvas调用来更新Drawer的内容	 
		 * @param canvas
		 * 
		 */		
		public function Draw (canvas:ChartCanvas) : void
		{
			if (null != onBeforeRender)
				onBeforeRender (this);
			this.graphics.clear();
			onRender(canvas);
			_bIsDirty = false;
			if (null != onAfterRender)
				onAfterRender (this);
			
			_invalidateRect = null;
		}

		public function clearChildren ():void
		{
			for(var n:int=numChildren; n>0; n--)
				removeChildAt(0);
		}

		/*************************************************************
		 * 需要重写的方法
		 *************************************************************/
		/**
		 * 获取绘图者的大小，为世界坐标系中的大小；
		 * 当以数据对象加入时，此返回的矩形将包含在Canvas的FullExtent中		
		 * @return 
		 * 
		 */		
		public function getExtent () : ChartRect 
		{	
			return null;	
		}
		/**
		 * 重画，派生类重写此函数绘制自己的图形 
		 * @param canvas ChartCanvas
		 * 
		 */		
		protected function onRender (canvas:ChartCanvas) : void {}
		
		/*************************************************************
		 * 私有方法、属性
		 *************************************************************/
		private function onRollOut(e:MouseEvent):void
		{
			if (-1 != _cursorID)
				CursorManager.removeCursor(_cursorID);				
			_cursorID = -1;
			
			if (null == _currentCursor)
			{
				this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				return;
			}
		}
		
		private function onRollOver(e:MouseEvent):void
		{
			if (null == _currentCursor)
			{
				this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				return;
			}
			
			if (-1 == _cursorID)
				_cursorID = CursorManager.setCursor(_currentCursor);
		}
		protected var _bIsDirty : Boolean = true;
		protected var _invalidateRect:ChartRect;
		// 当前鼠标光标
		private var _currentCursor:Class;
		private var _cursorID:int = -1;
		private var _cursorName:String;
	}
}
