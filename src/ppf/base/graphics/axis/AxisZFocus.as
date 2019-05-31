package ppf.base.graphics.axis
{
	import ppf.base.graphics.IOpSelection;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	import ppf.base.graphics.ChartColor;
	import ppf.base.graphics.operation.OpSelection;
	import ppf.base.graphics.ChartCanvas;
	import ppf.base.graphics.DataDrawer;

	/**
	 * Z轴上的刻度游标
	 * @author yiyi
	 */ 
	public class AxisZFocus extends UIComponent
	{
		private var _selPos : Number = Number.NEGATIVE_INFINITY;
		private var _tips:Sprite;//画布
		private var _op:IOpSelection;
		 
		public var initClipRect:Rectangle;
		public var lableString:String;
		private var _selPosZ:Number;
		private var canvas:ChartCanvas;
		private var _axisZ:AxisTestZ;
		public function AxisZFocus(o:IOpSelection=null,_canvas:ChartCanvas=null,axisZ:AxisTestZ=null)
		{
			super();
			if(o)this.selection=o;
			canvas=_canvas;
			_tips=new Sprite;
			_axisZ=axisZ;
		}
		
		public function set selection(o:IOpSelection):void
		{
			_op=o;
			o.addEventListener(OpSelection.EVENT_SELECT_CHANGED,onSelectionChanged,false,0,true);
			var cav:ChartCanvas=o.parentCanvas;//???????
			cav.addEventListener(ChartCanvas.EVENT_MATRIX_CHANGED,onSelectionChanged,false,0,true);
		}

		private function onSelectionChanged(e:Event):void
		{
			if (null == _op)
				return;
			var cav:ChartCanvas = _op.parentCanvas;
			var lp:Point = cav.worldToLocal(new Point(_op.selPosX, 0));
			this.selPos = lp.x;
		}
		/**
		 * 根据横坐标纵坐标获取Z值
		 */
		private function getZ(obj:Object):Number
		{
			var newdrawer:DataDrawer;
			var pointarr3d:Array;
			if(canvas.dataDrawers.getChildAt(0) is DataDrawer)
			{
				newdrawer=canvas.dataDrawers.getChildAt(0) as DataDrawer;
			}
			if(null == newdrawer)
				return NaN;
			if(newdrawer.pointArr!=null)
			{
				pointarr3d = newdrawer.pointArr;
				return pointarr3d[obj.rowindex][obj.columnindex].Z;
			}
			return Number.NaN;
		}
		public function draw():void
		{
			if(_tips!=null&&contains(_tips))
				removeChild(_tips);
			if(_op.parentCanvas.operation!=null)
				return;
			if(parent!=null)
				initClipRect=new Rectangle(0,0,parent.width,parent.height);
			if(_selPos==Number.NEGATIVE_INFINITY)
				return;
			try
			{
				var color:Number=ChartColor.selectLine;
				var tip:Sprite = drawOneTip(parent.width-10,color,initClipRect);
				_tips = new Sprite;
				_tips.addChild(tip);
				_tips.alpha=ChartColor.alphaTip;
				addChild(_tips);
			}
			catch(e:Error)
			{
				
			}
		}
		public function get selPos() : Number			{ return _selPos; 		}
		public function set selPos(pos : Number) : void	{	_selPos = pos;	 draw();	}
		/**
		 * 根据坐标获取刻度文本
		 */ 
		public function onNeedText():String
		{
			if(lableString!=null)
				return lableString;
			var pa:AxisBase=(parent as AxisBase);
			if(pa==null)
				return "error";
			return pa.onNeedText(new Point(_op.curPoint.x*pa.axisScale, 0), true);
		}
		
		private function sortByY(a:Object, b:Object):Number {
			var pa:Point = a.posLocal as Point;
			var pb:Point = b.posLocal as Point;
			
			if(pa.y > pb.y) {
				return -1;
			} else if(pa.y < pb.y) {
				return 1;
			} else  {
				//aPrice == bPrice
				return 0;
			}
		}
		/**
		 * 绘制一个标注
		 */
		protected function drawOneTip(sel:Number,color:Number,limitRect:Rectangle):Sprite
		{
			var obj:Object;
			var opsel:OpSelection
			if(_op is OpSelection)
				opsel =_op as OpSelection ;//as Op2;
			if(null == opsel)
				return new Sprite;
			var len:Number = opsel.selInfoList.length;//获得选中的点集
			if(len < 1)
				return new Sprite;
			var selObj:Object = opsel.selInfoList[0];
			var zValue:Number = getZ(selObj);
			
			var tip:Sprite = new Sprite;
			var xtrans:int = 10;
			var point:Point = new Point(0,zValue);
			canvas.currentAxis = "axisZ";
			point = canvas.worldToGlobal(point);
			canvas.currentAxis = null;
			point = this.globalToLocal(point);
			
			tip.graphics.beginFill(0xFF0000);
			tip.graphics.moveTo(0,point.y-3);
			tip.graphics.lineTo(xtrans,point.y);
			tip.graphics.lineTo(0,point.y+3);
			return tip;		
		}
	}
}