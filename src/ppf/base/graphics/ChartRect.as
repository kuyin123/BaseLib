package ppf.base.graphics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ChartRect extends Object
	{
		/// 构造函数，初始化为 (fLeft, fTop, fRight, fBottom)
		public function ChartRect(fLeft:Number = NaN, 
			fTop:Number = NaN,
			fRight:Number = NaN, 
			fBottom:Number = NaN)
		{
			left = fLeft, top = fTop, right = fRight, bottom = fBottom;
			if (!isNaN(fLeft)
				&& !isNaN(top)
				&& !isNaN(right)
				&& !isNaN(bottom))
				normalize ();
		}

		/**
		 * Rectangle 与 ChartRect 的区别在于坐标系 
		 * 两者坐标系的Y方向是相反的
		 * @param r
		 * 
		 */		
		public function set rectangle(r:Rectangle):void
		{
			left = r.left;
			right = r.right;
			top = r.bottom;
			bottom = r.top;
		}

		public function get rectangle():Rectangle
		{
			return new Rectangle(minX, minY, width, height);
		}

		/**
		 * 拷贝构造函数，初始化为 r 
		 * @param r
		 * 
		 */		
		public function copy(r : ChartRect) : void
		{
			left = r.left, top = r.top;
			right = r.right, bottom = r.bottom;		
		}	

		/**
		 * 构造函数，参数指定左上和右下坐标，初始化为两坐标的外框 
		 * @param fLeftTop 左上坐标
		 * @param fRightBottom 右下坐标
		 * 
		 */		
		public function setPoint(fLeftTop:Point, fRightBottom:Point):void
		{
			left = fLeftTop.x;
			top = fLeftTop.y;
			right = fRightBottom.x;
			bottom = fRightBottom.y;
			normalize();
		}

		/**
		 * 构造函数，初始化为以center为中心，上下左右都向外扩展tolerance的矩形 
		 * @param center 中心坐标
		 * @param tolerance 向外扩展系数
		 * 
		 */		
		public function setCenter(center:Point, tolerance:Number):void
		{
			left = center.x - tolerance;
			top = center.y + tolerance;
			right = center.x - tolerance;
			bottom = center.y + tolerance;
		}

		// GetData
		// set rect abnormal and empty, abnomal rect == { 1e30, 1e30, -1e30, -1e30 }
		/**
		 * 设置为空矩形 
		 * 
		 */		
		public function setNull() : void		{  left = NaN; }

		/// minX
		public function get minX ():Number { return left; }
		public function set minX (v:Number) : void { left = v; }
		/// maxX
		public function get maxX():Number { return right; }
		public function set maxX (v:Number) : void { right = v; }
		/// maxY
		public function get maxY ():Number { return top; }
		public function set maxY (v:Number) : void { top = v; }
		/// minY
		public function get minY ():Number { return bottom; }
		public function set minY (v:Number) : void { bottom = v; }

		/// 获取宽度
		public function get width() :Number	{  return right - left;	}
		/// 获取高度
		public function get height() : Number {  return top - bottom;	}
		/// 获取左上角坐标
		public function get leftTop() : Point	{ return new Point (left, top); }
		public function set leftTop(p:Point) : void	{ left = p.x, top =  p.y; }
		/// 获取右上角坐标
		public function get rightTop() : Point	{ return new Point (right, top); }
		public function set rightTop(p:Point) : void	{ right = p.x, top =  p.y; }
		/// 获取右下角坐标
		public function get rightBottom() : Point	{ return new Point (right, bottom); }
		public function set rightBottom(p:Point) : void	{ right = p.x, bottom =  p.y; }
		/// 获取左下角坐标
		public function get leftBottom() : Point { return new Point (left, bottom); }
		public function set leftBottom(p:Point) : void	{ left = p.x, bottom =  p.y; }
		/// 获取中心点坐标
		public function get center() : Point	{ return new Point ((left + right)*0.5, (top + bottom)*0.5); }

		public function scale (fScale:Number):void
		{
			scaleEx(fScale, fScale);
		}
		
		public function scaleEx (fScaleX:Number, fScaleY:Number):void
		{
			var c:Point = center;
			var w:Number = width * fScaleX / 2;
			var h:Number = height * fScaleY / 2;
			minX = c.x - w;
			maxX = c.x + w;
			minY = c.y - h;
			maxY = c.y + h;
		}

		public function clone () : ChartRect
		{
			return new ChartRect (left, top, right, bottom);
		}

		//
		// 比较函数
		//
		/**
		 * 判断矩形是否为空矩形 
		 * @return true：空矩形4点值都为正无穷大或负无穷大 false：正常矩形
		 * 
		 */		
		public function get is_empty() : Boolean 
		{
			return !(isFinite(left) && isFinite(right) && isFinite(top) && isFinite(bottom));
		}

		/**
		 * 判断矩形是否与另一个矩形 r 相交	 
		 * @param r
		 * @return 
		 * 
		 */		
		public function is_intersect(r:ChartRect) : Boolean
		{
			return !(r.left > right || r.right < left 
				|| r.bottom > top|| r.top < bottom);
		}

		/**
		 * 判断矩形是否包含另一矩形 r 
		 * @param r
		 * @return 
		 * 
		 */		
		public function is_include(r : ChartRect) : Boolean
		{
			return (r.left >= left && r.right <= right 
				&& r.bottom >= bottom && r.top <= top);
		}

		/**
		 * 判断矩形是否包含点x、y 
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		public function is_pointin(x:Number, y:Number) : Boolean
		{
			return x > left && x < right && y > bottom && y < top;
		}

		//
		// 修改函数
		//
		/** 矩形扩张
		 *	@param dx、dy 分别在上、下、左、右四个方向的扩张距离
		 */
		public function grow(dx:Number, dy:Number):void							
		{
			left	-= dx;	
			right	+= dx;
			bottom	-= dy;
			top		+= dy;
		}

		/** 矩形扩张
		 *	@param l、t、r、b 分别在左、上、右、下四个方向的扩张距离
		 */
		public function grow4(l:Number, t:Number, r:Number, b:Number):void
		{
			left	-= l;
			bottom 	-= t;
			right	+= r;
			top		+= b;
		}

		/**
		 *	矩形偏移
		 *	@param dx、dy 举行在x、y方向上的偏移距离
		 */
		public function offset(dx:Number, dy:Number) : void
		{
			left	+= dx;
			right	+= dx;
			top		+= dy;
			bottom	+= dy;
		}

		/**
		 *	合并指定点
		 *	@param x、y 要合并的点
		 */
		public function union_point (x:Number, y:Number):void
		{
			if (is_empty)
			{
				left = right = x;
				top = bottom = y;
				return;
			}

			if(x < left)	left = x;
			if(x > right)	right = x;
			if(y < bottom)	bottom = y;
			if(y > top)		top = y;
		}

		/** 合并矩形 r 到当前矩形
		 * 如果两个矩形中有一个空矩形，则取非空的为当前矩形
		 */
		public function union_rect (r : ChartRect):void
		{
			if (r.is_empty)
				return;

			if (is_empty)
			{
				left	= r.left;
				bottom	= r.bottom;
				right	= r.right;
				top		= r.top;
			}
			else
			{
				left	= Math.min(r.left, left);
				bottom	= Math.min(r.bottom, bottom);
				right	= Math.max(r.right, right);
				top		= Math.max(r.top, top);
			}
		}

		// normalize
		/**
		 *	矩形规格化，使得矩形满足 left <= right，bottom <= top
		 */
		public function normalize():void
		{
			var t:Number;
			if(left > right)	t = left, left = right, right = t;
			if(bottom > top)	t = bottom, bottom = top, top = t;
		}

		/** 矩形求交
		 *	计算矩形 r1 与 r2 的相交矩形，存储到 this
		 *	@param r1、r2 求交的两个矩形对象
		 *	@return 返回是否相交，如果有相交返回true，相交矩形，存储到 this
		 *			如果没有相交，则返回false
		 */
		public function intersect(r1:ChartRect, r2:ChartRect) : Boolean
		{
			left		= Math.max(r1.left, r2.left);
			bottom		= Math.max(r1.bottom, r2.bottom);
			right		= Math.min(r1.right, r2.right);
			top			= Math.min(r1.top, r2.top);
			return right >= left && top >= bottom;
		}

		/**
		 * 线段--矩形裁减函数
		 * @param p1
		 * @param p2
		 * @return 
		 * 
		 */		
		public function	clipLine(p1:Point, p2:Point):Boolean
		{
			var XL:int = this.left;
			var XR:int = this.right;
			var YT:int = this.top;
			var YB:int = this.bottom;
			var dx:Number;
			var dy : Number
			var u1:Number = 0.0;
			var u2:Number = 1.0;
			var t:int;

			//如果两点都在裁减区内，则不需要裁减
			if(p1.x >= XL && p1.y >= YB && p1.x <= XR && p1.y <= YT && 
				p2.x >= XL && p2.y >= YB && p2.x <= XR && p2.y <= YT)
				return true;

			if(p1.x == p2.x) 
			{	//垂直线
				if(p1.x < XL || p1.x > XR)
					return false;
				if(p1.y > p2.y)
					t = p1.y, p1.y = p2.y, p2.y = t;
				if(p1.y < YB)
					p1.y = YB;
				if(p2.y > YT)
					p2.y = YT;
				return p1.y <= p2.y;
			}
			if(p1.y == p2.y) {	//水平线
				if(p1.y < YB || p1.y > YT)
					return false;
				if(p1.x > p2.x)
					t = p1.x, p1.x = p2.x, p2.x = t;
				if(p1.x < XL)
					p1.x = XL;
				if(p2.x > XR)
					p2.x = XR;
				return p1.x <= p2.x;
			}

			dx = p2.x-p1.x;
			dy = p2.y-p1.y;
			var u:Point = new Point(u1, u2);
			if(	ClipT(-dx,p1.x-XL,u)	&&
				ClipT(dx,XR-p1.x, u)	&&
				ClipT(-dy,p1.y-YB, u)	&&
				ClipT(dy,YT-p1.y, u))
			{
				u1 = u.x;
				u2 = u.y;
				p2.x = p1.x+(u2*dx);
				p2.y = p1.y+(u2*dy);
				p1.x += u1*dx;
				p1.y += u1*dy;
				return true;
			}
			return false;
		}

		public function toString():String
		{
			return "" + left + ", " + top + ", " + right + ", " + bottom;
		}

		//@}
		public var left:Number;
		public var top:Number;
		public var right:Number;
		public var bottom:Number;

	
		/**
		 * 裁减计算 
		 * u1 = u.x
		 * u2 = u.y
		 * @param p
		 * @param q
		 * @param u
		 * @return 
		 * 
		 */		
		private static function ClipT(p:Number, q:Number, u:Point):Boolean
		{
			var r:Number;
			if(p<0) 
			{
				r=q/p;
				if(r>u.y)
					return false;
				else if(r>u.x)	
				{
					u.x=r;
					return true;
				}
			}
			else if(p>0) 
			{
				r=q/p;
				if(r<u.x)
					return false;
				else if(r<u.y)
				{
					u.y=r;
					return true;	
				}
			}
			else if(q<0)
				return false;
			return true;	
		}	
	}
}
