package ppf.base.graphics.operation
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import ppf.base.graphics.ChartDrawer;
	
	public class DragDrawer extends ChartDrawer
	{
		public function DragDrawer()
		{
			super();
			// 注册添加事件，当对象被添加到容器时，初始化鼠标事件
			addEventListener(Event.ADDED, _onAdded, false, 0, true);
			addEventListener(Event.REMOVED, _onRemove, false, 0, true);
		}
		
		// 是否正在拖动
		public function get isDraging() : Boolean
		{
			return _isDraging;
		}
		// 是否正在拖动
		public function set isDraging(_isDraging:Boolean) : void
		{
			this._isDraging = _isDraging;
		}

		// 获取鼠标的事件的捕获者
		public function get mouseOwner ():Sprite
		{
			if (null == _mouseOwner)
				return this;
			return _mouseOwner;
		}

		// 设置鼠标的事件的捕获者
		public function set mouseOwner (owner:Sprite):void
		{
			this.hitArea = null;
			mouseOwner.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_mouseOwner = owner;
			_mouseOwner.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			if (owner == this)
				this.hitArea = parentCanvas;
		}

		// 响应被加入到舞台的事件
		private function _onAdded (e:Event):void
		{
			if (e.target != this)
				return;
				
			if (null == parentCanvas)
				return;
			
			if (mouseOwner == this)	
				this.hitArea = parentCanvas;
			mouseOwner.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			onAdded();
		}

		// 响应被从舞台删除的事件
		private function _onRemove(e:Event):void
		{
			if (e.target != this)
				return;
				
			if (null == parentCanvas)
				return;
				
			mouseOwner.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			parentCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
			onRemoved();
		}

		// onAdded onRemoved 是为派生类准备的，当前操作被加入或删除时被触发
		protected function onAdded():void
		{
			
		}

		protected function onRemoved():void
		{
			
		}

		// 鼠标按下处理函数，注册舞台的事件监听，记住：起点，MainWaveBox在鼠标按下时的位置
		protected function onMouseDown(e:MouseEvent):void
		{
			// e.stopImmediatePropagation();
			beginPointStage = new Point(e.stageX, e.stageY);
			beginPoint = parentCanvas.currentWorldMousePosition;//获取当前世界坐标系的开始点
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
			parentCanvas.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag,false,0,true);
			_isDraging = true;
			onMouseDrag (e);
			
			//左键点击弹出菜单,会处理MouseDown事件，需要屏蔽掉次事件流
			e.stopImmediatePropagation();
			e.preventDefault();
			//上面屏蔽掉事件流后需要手动处理
//			RightClickManager.hideMenu();
		}

		// 鼠标松开处理函数，删除舞台的事件监听
		protected function onMouseUp(e:MouseEvent):void
		{
			_isDraging = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			parentCanvas.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
			this.invalidate();
		}
		
		// 鼠标按下并移动的处理函数
		protected function onMouseDrag(e:MouseEvent):void
		{
			
		}

//		override protected function onRender (canvas:ChartCanvas) : void
//		{
//			graphics.clear();
//			// 绘制绘图区域
//			this.graphics.beginFill(0, 0);
//			this.graphics.drawRect(canvas.clipRect.x, canvas.clipRect.y, canvas.clipRect.width, canvas.clipRect.height);
//			this.graphics.endFill();
//		}

		/**
		 * 鼠标按下的位置，数据坐标
		 */		
		protected var beginPoint : Point;
		/**
		 * 鼠标按下的位置，全局舞台坐标
		 */		
		protected var beginPointStage : Point;
		/**
		 * 是否选择了曲线
		 */
		protected var isNewclick:Boolean=false;
		/**
		 * 按下拖动状态
		 */		
		protected var _isDraging:Boolean = false;
		
		private var _mouseOwner:Sprite;
	}
}