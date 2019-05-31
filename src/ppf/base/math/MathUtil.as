package ppf.base.math
{
	import flash.geom.Point;

	public final class MathUtil
	{
		/**
		 * 两个number相减（解决出现小数精度问题) 
		 * @param num1 减数
		 * @param num2 被减数
		 * @return 
		 * 
		 */		
		static public function subNum(num1:Number,num2:Number):Number
		{
			var num:Number = num1 - num2;
			return Number(num.toFixed(13));
		}
		/**
		 * 返回小数点后几位
		 * toFixed(123.456,1));//123.4
		 * toFixed(123.456,2));//123.46
		 * @param num  数值
		 * @param fractionDigits 小数点后几位
		 * @return 
		 * 
		 */		
		static public function toFixed(num:Number,fractionDigits:int=0):String
		{
			var s:String;
			//toFixed为0是返回的是 0.
			if (0 == fractionDigits)
				s = int(Math.round(num)).toString();
			else
				s = num.toFixed(fractionDigits);
			
			return s;
		}
		/**
		 * 返回小数点后几位 Number类型
		 * toFixed(123.456,1));//123.4
		 * toFixed(123.456,2));//123.46
		 * @param num  数值
		 * @param fractionDigits 小数点后几位
		 * @return Number类型
		 * 
		 */		
		static public function toFixedNum(num:Number,fractionDigits:int):Number
		{
			var s:String = toFixed(num,fractionDigits);
			return Number(s);
		}
		
		static public function FormatNumber(num:Number,nAfterDot:int):String
		{
			var srcStr:String;
			var resultStr:String
			var dotPos:int;
			srcStr=(num).toString();
			srcStr = ""+srcStr+"";
			var strLen:uint = srcStr.length;
			dotPos = srcStr.indexOf(".",0);
			if (dotPos == -1)
			{
				resultStr = srcStr+".";
				for (var i:uint=0;i<nAfterDot;i++)
				{
					resultStr = resultStr+"0";
				}
				return resultStr;
			}
			else
			{
				if ((strLen - dotPos - 1) >= nAfterDot)
				{
					var nAfter:int = dotPos + nAfterDot + 1;
					var nTen:int =1;
					for(var j:uint=0;j<nAfterDot;j++)
					{
						nTen = nTen*10;
					}
					var resultnum:Number=Math.round(num*nTen)/nTen;
					resultStr = resultnum.toString();
					return resultStr;
				}
				else
				{
					resultStr = srcStr;
					for (i=0;i<(nAfterDot - strLen + dotPos + 1);i++)
					{
						resultStr = resultStr+"0";
					}
					return resultStr;
				}
			}
		}
		
		/**
		 * 计算并返回由参数 val 指定的数字的绝对值。 
		 * @param val
		 * @return 
		 * 
		 */		
		static public function abs(val:Number):Number
		{
			if (val<0)
				val = -val;
			return val;
		}
		/**
		 * 指定小数位数，四舍五入，转换Number形到字符串，
		 * @param val 转换的数字
		 * @param precision 小数点后的位数
		 * @param fill 补足位数  （已经被关闭，此处fill引发歧义）
		 * @return 指定小数位的字符
		 */		 
		static public function n2s(val:Number, precision:uint = 0, fill:Number = 0):String
		{
			var tmpValue:String = "";
			
			if (isNaN(val))
				return tmpValue;
			
			var m : Number = Math.pow(10, precision);
			val = Math.round(val*m)/m;
			tmpValue = val.toFixed(precision);

//			//除去-0.00的情况
//			if(tmpValue.length)
//			{
//				if(tmpValue.charAt(0) == '-')
//				{
//					var hasNonZero:Boolean = false;
//					var c:String;
//					for(var n:int = 1; n < tmpValue.length ; n ++)
//					{
//						c = tmpValue.charAt(n);
//						if(c != '0' && c != '.')
//						{
//							hasNonZero = true;
//							break;
//						}
//					}
//					if(!hasNonZero)
//						tmpValue =  tmpValue.substr(1,tmpValue.length - 1);
//				}
//			}
			
//			var len:Number = tmpValue.length;			
//			if (0 == fill)
//			{// 无需填充，则取出末尾的 0
//				for (var i:Number = len-1; i>=0; i--)
//				{
//					var ch:String = tmpValue.charAt(i);
//					if ('0' != ch)
//					{
//						if ('.'  == ch)
//							i--;
//						break;
//					}
//				}
//				if(i < 0)//当输入参数为个位整数时i=-1
//					i = 0;
//				
//				if (i < (len-1))
//					tmpValue = tmpValue.substr(0, i+1);
//			}
//			else if (len < fill)
//			{// 补足末尾的 0
//				for (var j:Number=len; j<fill; j++)
//				{
//					tmpValue = tmpValue + "0";
//				}
//			}
			
			return tmpValue;
		}
		
		/**
		 * 二分查找				<br/>
		 * 在排序数组 a 中查找值 x	<br/>
		 * 如果为a 或 x为复杂数组，可设置 getter 函数进行比较操作，getter 原型如：<br/>
		 * 		private function getter(a:Object, x:Object):Boolean		<br/>
		 * 		{														<br/>
		 * 			return a[m_data.indexX] < x;						<br/>
		 * 		}														<br/>
		 * 返回 >= x 的第一个下标											<br/>
		 * @param a
		 * @param x
		 * @param getter
		 * @return
		 *
		 */		 
//		static public function lowerBound(a:Array, x:Object, getter:Function = null) : int
//		{	// find first element not before _Val, using _Pred
//			var _Count:int = a.length;
//			var _First:int = 0;
//			for (; 0 < _Count; )
//			{// divide and conquer, find half that contains answer
//				var _Count2:int = _Count / 2;
//				var _Mid:int = _First + _Count2;
//				var less:Boolean;  
//				if (null == getter) 
//					less = (a[_Mid] < x);
//				else
//					less = getter(a[_Mid], x);
//				
//				if (less)
//					_First = ++_Mid, _Count -= _Count2 + 1;
//				else
//					_Count = _Count2;
//			}
//			return _First;
//		}
		static public function lowerBound(a:Array, x:Object, getter:Function = null):int
		{	// find first element not before _Val, using _Pred
			var _Count:int = a.length;
			var _First:int = 0;
			var _Count2:int;
			var _Mid:int
			var less:Boolean; 
			for (; 0 < _Count; )
			{// divide and conquer, find half that contains answer
				_Count2 = _Count * 0.5;
				_Mid = _First + _Count2;
				less = false;  
				if (null == getter) 
					less = (a[_Mid] < x);
				else
					less = getter(a[_Mid], x);
				
				if (less)
					_First = ++_Mid, _Count -= _Count2 + 1;
				else
					_Count = _Count2;
			}
			return (_First);
		}
		
		/**
		 * 角度转换为弧度
		 * @param angle 角度
		 * @return 弧度
		 *
		 */		 
		static public function angle2Radian(angle:Number):Number
		{
			return angle*Math.PI/180;
		}
		
		/**
		 * 弧度转换成角度  
		 * @param radian 弧度
		 * @param setdomian 是否设置为0-360度
		 * @return 角度
		 */		
		static public function radian2Angle(radian:Number,setdomian:Boolean = true):Number
		{
			if(setdomian)
			{
				radian = radian * 180/Math.PI;
				radian = radian % 360;
				if (radian < 0)
					radian += 360;
				return Number(radian.toFixed(0)) % 360;
			}
			else
				return Number((radian*180/Math.PI).toFixed(0)) % 360;
		}
		
		/**
		 * 计算线段与线段的相交关系
		 *	函数返回交点类型，0为无交点，1为一个交点，2为重合（两个交点）
		 *	@param	a0-a1, b0-b1	分别存储两条线段a, b的四个端点,
		 @param	返回的交点存放在到ret0、ret1中
		 *	@return	<PRE>
		 *		0：无交点
		 *		1：一个交点，返回的交点坐标放在L2中
		 *		2：为重合（两个交点），返回的交点存放在到ret0、ret1中，
		 *	</PRE>
		 */
		static public function line2line (a0:Point, a1:Point, b0:Point, b1:Point,
										  ret0:Point= null, ret1:Point = null):uint
		{
			if (null == ret0)
				ret0 = new Point;
			if (null == ret1)
				ret1 = new Point;
			
			var rtn:uint = Vect_segment_intersection (
				a0.x, a0.y, a1.x, a1.y,
				b0.x, b0.y, b1.x, b1.y,
				ret0, ret1);
			
			if (rtn > 2)
				rtn = 2;
			if (rtn < 2)
				return rtn;
			else 
				return 2;
		}
		
		/**!
		 \brief 两线段求交
		 \return
		 *           0 - 不相交
		 *           1 - 相交到一点
		 *                 \  /    \  /  \  /
		 *                  \/      \/    \/
		 *                  /\             \
		 *                 /  \             \
		 *           2 - 部分重叠                ( \/                      )
		 *                ------      a          (    distance < threshold )
		 *                   ------   b          (                         )
		 *           3 - a 包含 b                ( /\                      )
		 *                ----------  a    ----------- a
		 *                   ----     b          ----- b
		 *           4 - b 包含 a
		 *                   ----     a          ----- a
		 *                ----------  b    ----------- b
		 *           5 - 两线段相等
		 *                ----------  a
		 *                ----------  b
		 *
		 \param input line a, input line b, intersection point1 (case 1),
		 intersection point2 (case 2-4)
		 */
		static private function Vect_segment_intersection (ax1:Number, ay1:Number, ax2:Number, ay2:Number, /* input line a */
														   bx1:Number, by1:Number, bx2:Number, by2:Number, /* input line b */
														   p1:Point, /* intersection point1 (case 2-4) */
														   p2:Point /* intersection point2 (case 2-4) */
		) : uint
		{
			var d:Number, d1:Number, d2:Number, r1:Number, r2:Number, dtol:Number, t:Number;
			var switched:int = 0;
			
			// 检察线段是否相等
			if ( ( ax1 == bx1 && ay1 == by1 && ax2 == bx2 && ay2 == by2 ) ||
				( ax1 == bx2 && ay1 == by2 && ax2 == bx1 && ay2 == by1 ) ) {
				p1.x = ax1; p1.y = ay1;
				p2.x = ax2; p2.y = ay2;
				return 5;	// 相等
			}
			
			// 按优先级 x1, x2, y1, y2 排序 
			if ( bx1 < ax1 ) switched = 1;
			else if ( bx1 == ax1 ) {
				if ( bx2 < ax2 ) switched = 1;
				else if ( bx2 == ax2 ) {
					if ( by1 < ay1 ) switched = 1;
					else if ( by1 == ay1 ) {
						if ( by2 < ay2 ) switched = 1;
						// 不可能存在 by2 == ay2
					}
				}
			}
			
			// 根据排序结果，交换线段
			if (switched)
			{
				t = ax1; ax1 = bx1; bx1 = t; t = ay1; ay1 = by1; by1 = t; 
				t = ax2; ax2 = bx2; bx2 = t; t = ay2; ay2 = by2; by2 = t;
			}	
			
			// 计算差积
			d  = ((ax2-ax1)*(by1-by2) - (ay2-ay1)*(bx1-bx2));
			d1 = ((bx1-ax1)*(by1-by2) - (by1-ay1)*(bx1-bx2));
			d2 = ((ax2-ax1)*(by1-ay1) - (ay2-ay1)*(bx1-ax1));
			
			dtol = 1.0e-10; // EPSILON 为最小差
			if (Math.abs(d) > dtol)
			{// 两条线相交到一点
				r1 = d1/d;
				r2 = d2/d;
				
				if (r1 < 0 || r1 > 1 || r2 < 0 || r2 > 1)
					return 0;
				
				p1.x = ax1 + r1 * (ax2 - ax1);
				p1.y = ay1 + r1 * (ay2 - ay1);
				return 1;
			}
			
			// 判断是否同线
			if (d1 || d2)
			{ // d1, d2 都为0，是平行线，且不相等，所以不相交
				return 0;
			}
			
			//
			// 下面两线段共线，处理覆盖情况
			//
			
			if (ax1 == ax2 && bx1==bx2 && ax1==bx1)
			{// 垂直且同线
				// 确保 ay1 < ay2 && by1 < by2
				if (ay1 > ay2) { t=ay1; ay1=ay2; ay2=t;	}
				if (by1 > by2) { t=by1; by1=by2; by2=t; }
				
				// 不相交
				if (ay1 > by2 || ay2 < by1)
					return 0;
				
				/* pend points */
				if (ay1 == by2) {
					p1.x = ax1; p1.y = ay1;
					return 1; /* endpoints only */
				}
				if(ay2 == by1) {
					p1.x = ax2; p1.y = ay2;
					return 1; /* endpoints only */
				}
				
				/* a contains b */
				if ( ay1 <= by1 && ay2 >= by2 ) 
				{
					p1.x = bx1; p1.y = by1;
					p2.x = bx2; p2.y = by2;
					if ( !switched )
						return 3; 
					else 
						return 4;
				}
				
				/* b contains a */
				if ( ay1 >= by1 && ay2 <= by2 ) 
				{
					p1.x = ax1; p1.y = ay1;
					p2.x = ax2; p2.y = ay2;
					if ( !switched )
						return 4; 
					else 
						return 3;
				}   
				
				/* 通用重叠情况, 存在 2 个交点*/
				if ( by1 > ay1 && by1 < ay2 ) { /* b1 in a */
					if ( !switched ) {
						p1.x = bx1; p1.y = by1;
						p2.x = ax2; p2.y = ay2;
					} 
					else 
					{
						p1.x = ax2; p1.y = ay2;
						p2.x = bx1; p2.y = by1;
					}
					return 2;
				} 
				if ( by2 > ay1 && by2 < ay2 ) { /* b2 in a */
					if ( !switched ) 
					{
						p1.x = bx2; p1.y = by2;
						p2.x = ax1; p2.y = ay1;
					} 
					else 
					{
						p1.x = ax1; p1.y = ay1;
						p2.x = bx2; p2.y = by2;
					}
					return 2;
				} 
				
				// 出现未考虑到的错误
				throw new Error("HTMath.Vect_segment_intersection 出现未考虑到的错误");
				
				return 0;
			}
			
			//
			// 同线且非垂直情况 ...
			//
			
			// 判断是否包含
			if ( ( bx1 > ax1 && bx2 > ax1 && bx1 > ax2 && bx2 > ax2 ) || 
				( bx1 < ax1 && bx2 < ax1 && bx1 < ax2 && bx2 < ax2 ) ) 
			{
				return 0;	// 同线，但是错开，不相交
			}
			
			// 判断端点是否相等，如果是则相交
			if ( (ax1 == bx1 && ay1 == by1) || (ax1 == bx2 && ay1 == by2) )
			{
				p1.x = ax1; p1.y = ay1;
				return 1; 
			}
			
			if ( (ax2 == bx1 && ay2 == by1) || (ax2 == bx2 && ay2 == by2) )
			{
				p1.x = ax2; p1.y = ay2;
				return 1;
			}
			
			// 确保 ax1 < ax2  && bx1 < bx2
			if (ax1 > ax2) { t=ax1; ax1=ax2; ax2=t; t=ay1; ay1=ay2; ay2=t; }
			if (bx1 > bx2) { t=bx1; bx1=bx2; bx2=t; t=by1; by1=by2; by2=t; }
			
			/* a 包含 b */
			if ( ax1 <= bx1 && ax2 >= bx2 )
			{
				p1.x = bx1; p1.y = by1;
				p2.x = bx2; p2.y = by2;
				if ( !switched )
					return 3; 
				else 
					return 4;
			}
			
			/* b 包含 a */
			if ( ax1 >= bx1 && ax2 <= bx2 )
			{
				p1.x = ax1; p1.y = ay1;
				p2.x = ax2; p2.y = ay2;
				if ( !switched )
					return 4;
				else
					return 3;
			}   
			
			// 通用覆盖, 存在 2 个交点
			// x1, y1 ==> in b
			// x2, y2 ==> in a
			if ( bx1 > ax1 && bx1 < ax2 )
			{/* b1 is in a */
				if (switched) 
				{
					p1.x = ax2; p1.y = ay2;
					p2.x = bx1; p2.y = by1;
				}
				else 
				{
					p1.x = bx1; p1.y = by1;
					p2.x = ax2; p2.y = ay2;
				}
				return 2;
			}
			
			if ( bx2 > ax1 && bx2 < ax2 )
			{
				/* b2 is in a */
				if (switched) 
				{
					p1.x = ax1; p1.y = ay1;
					p2.x = bx2; p2.y = by2;
				}
				else 
				{
					p1.x = bx2; p1.y = by2;
					p2.x = ax1; p2.y = ay1;
				}
				return 2;
			} 
			
			return 0;
		}
		
		/**
		 * 有效位数处理 
		 * @param effNum 有效位数 
		 *            此处的有效位数理解如下
		 *            例如：1234，如果设置两位有效位 则返回 1200
		 *                0.123 如果设置两位有效位 则返回0.12
		 *                0.456 如果设置两位有效位 则返回0.46
		 * @return 
		 */		
		public static function toEffNum(value:Number,effNum:int):Number
		{
			if (effNum == 0)
				return 0;
			if (Math.abs(value) < 1)//小于1时直接返回小数点后effNum位
				return Number(n2s(value,effNum));
			
			var tmpValue:Number = Math.abs(value);
			var result:Number = 0;
			var maxBit:int = 0;//计算最高位是几位
			while(tmpValue >= 1)
			{
				tmpValue /= 10;
				maxBit ++;
			}
			
			if (maxBit > effNum)//当最高位大于有效位数  例如1234  返回的有效数字是两位  那么后面的补0就OK了
			{
				result = Number((value / Math.pow(10,(maxBit - effNum))).toFixed(0));
				result = result * Math.pow(10,(maxBit - effNum));
				return result;
			}
			else
			{
				return Number(value.toFixed(effNum - maxBit)); 	
			}
		}
		
		public function MathUtil()
		{
			throw new Error("MathUtil类只是一个静态方法类!");  
		}
	}
}