package ppf.base.graphics.operation
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.ChartRect;
	
	public class OpPan extends DragDrawer
	{
		public var autoExit:Boolean = false;
		public var enableMoveX:Boolean = true;
		public var enableMoveY:Boolean = true;
		
		public function OpPan()
		{
			super();
			cursor = "hand_up";
		}

		
		override protected function onMouseDown(e:MouseEvent):void
		{
			super.onMouseDown(e);
			cursor = "hand_down";
		}

		override protected function onMouseUp(e:MouseEvent):void
		{
			super.onMouseUp(e);
			cursor = "hand_up";
		}
		
		// 鼠标按下并移动的处理函数
		override protected function onMouseDrag(e:MouseEvent):void
		{
			super.onMouseDrag(e);
			
			var canvas:ChartCanvas = this.parentCanvas;
			var cur:Point = new Point(e.stageX,e.stageY);
			var old_w:Point = canvas.globalToWorld(beginPointStage);
			var cur_w:Point = canvas.globalToWorld(cur);
			beginPointStage = cur;
			
			var r:ChartRect = canvas.extent;
			var off_x:Number = enableMoveX ? old_w.x - cur_w.x : 0;
			var off_y:Number = enableMoveY ? old_w.y - cur_w.y : 0;
			r.offset(off_x, off_y);
			canvas.setExtent(r, true, true);
		}
	}
}