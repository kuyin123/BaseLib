package ppf.base.graphics
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import mx.controls.Button;
	
	public class LabelsDrawer extends ChartDrawer
	{
		public function LabelsDrawer()
		{
			super();
			this.mouseEnabled = false;
		}
		/**
		 *可拖动 
		 */		
		private var _enableEdit:Boolean=false;
		
		private var _enableInput:Boolean = false;

		/**
		 *可修改文字 
		 */
		public function set enableInput(value:Boolean):void
		{
			_enableInput = value;
		}
		
		
		public function set enableEdit(value:Boolean):void
		{
			_enableEdit=value;
		}
		
		/**
		 * rectPosition: 0: cenetr	1: left	2: top	3: right 4: bottom
		 */
		public function addLabel (pos:Point, text:String, rectPosition:uint,axisname:String):int
		{
			var label:ArrowLable = new ArrowLable;
			label.text = text;
			label.worldPosition = pos;
			label.frontWhenClicked = true;
			label.enabelEdit = _enableEdit;
			label.showCloseBtn = _showCloseBtn;
			label.enabelInput = _enableInput;
			 
			this.addChild(label);
			
			if (null != parentCanvas)
			{
				parentCanvas.currentAxis = axisname;
				pos = parentCanvas.worldToLocal(pos);
				parentCanvas.currentAxis = null;
				label.x = pos.x;
				label.y = pos.y;
				label.unitName = axisname;
				label.autoRect(10, rectPosition);
			}

			return this.numChildren - 1;
		}
		//每次更新视图重新计算位置
		override protected function onRender (canvas:ChartCanvas):void
		{
			for (var i:uint=0; i<this.numChildren; i++)
			{
				var label:ArrowLable = this.getChildAt(i) as ArrowLable;
				canvas.currentAxis = label.unitName;
				var pos:Point = canvas.worldToLocal(label.worldPosition);
				canvas.currentAxis = null;
				label.x = pos.x;
				label.y = pos.y;
			}
		}
		
		public function set showCloseBtn(value:Boolean):void
		{
			_showCloseBtn = true;
		}
		
		private var _showCloseBtn:Boolean = false;
	}
}