package ppf.base.graphics.operation
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartRect;
	import ppf.base.graphics.DataDrawer;
	import ppf.base.graphics.ChartColor;

	// 开创缩放
	public class OpZoom extends DragDrawer
	{
		public var autoExit:Boolean = false;
		
		/**
		 *  如果设置了 alignTo，则获得最近的索引
		 */		
		public var alignTo:DataDrawer;
		
		/**
		 * 缩放水平坐标 
		 */		
		public var zoomX:Boolean = true;
		
		/**
		 * 缩放垂直坐标
		 */		
		public var zoomY:Boolean = true;
		
		public function OpZoom()
		{
			super();
		}

		override protected function onMouseDown(e:MouseEvent):void
		{
			super.onMouseDown(e);
			
			// 如果设置了 alignTo，则获得最近的索引
			if (null != alignTo)
			{
				var i:Number = alignTo.indexOfWaveX(beginPoint.x);
				if (-1 != i)
					beginPoint.x = alignTo.getPointByIndex(i).x;
			}
		}
		
		// 鼠标按下并移动的处理函数
		override protected function onMouseDrag(e:MouseEvent):void
		{
			super.onMouseDrag(e);
			this.invalidate();
		}

		// 鼠标松开处理函数，删除舞台的事件监听
		override protected function onMouseUp(e:MouseEvent):void
		{
			super.onMouseUp(e);
			
			var localP:Point = parentCanvas.worldToLocal(beginPoint);
			if(Math.abs(localP.x - mouseX) > 1 && Math.abs(localP.y - mouseY) > 1)
			{
				var canvas:ChartCanvas = parentCanvas;
				var lt : Point = beginPoint;
				
				var pos:Point = parentCanvas.localToWorld(new Point(mouseX, mouseY));
				// 如果设置了 alignTo，则获得最近的索引
				if (null != alignTo)
				{
					var i:Number = alignTo.indexOfWaveX(pos.x);
					if (-1 != i)
						pos.x = alignTo.getPointByIndex(i).x;
				}
				
				var rb : Point = pos;
				var extent:ChartRect = parentCanvas.extent;
				var isValid:Boolean = true;
				if (zoomX)
				{
					extent.left = lt.x;
					extent.right = rb.x;
					if (Math.abs(e.stageX-beginPointStage.x) < 10 || Math.abs(extent.width) < 0.001)
						isValid = false;
				}
				
				if (zoomY)
				{
					extent.top = lt.y;
					extent.bottom = rb.y;
					if (Math.abs(e.stageY-beginPointStage.y) < 10 || Math.abs(extent.height) < 0.001)
						isValid = false;
				}
				
				if (isValid)
				{
					extent.normalize();
					parentCanvas.setExtent(extent, true, true);
				}
			}
			
			if (this.autoExit)
				parent.removeChild(this);
		}

		override protected function onRender (canvas:ChartCanvas) : void
		{
			// super.onRender(canvas);
			
			if (this.isDraging)
			{
				var pos:Point = new Point(mouseX, mouseY);
				// 如果设置了 alignTo，则获得最近的索引
				if (null != alignTo)
				{
					pos = parentCanvas.localToWorld(pos);
					var i:Number = alignTo.indexOfWaveX(pos.x);
					if (-1 != i)
						pos.x = alignTo.getPointByIndex(i).x;
						
					pos = parentCanvas.worldToLocal(pos);
				}
				
				var start:Point = parentCanvas.worldToLocal(beginPoint);
				this.graphics.lineStyle(2, ChartColor.selectLine, 0.75);
				this.graphics.drawRect (start.x, start.y,
										pos.x - start.x, pos.y - start.y);
			}
		}
	}
}