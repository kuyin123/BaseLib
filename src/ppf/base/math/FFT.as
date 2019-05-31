package ppf.base.math
{
	
	import flash.geom.Point;

	public class FFT
	{
		// OutX 输出频点
		public var OutX:Array;
		// OutY 输出幅值
		public var OutY:Array;
		// OutPhase 输出相位
		public var OutPhase:Array;

		public function getYExtremumsIndex(sortByY:Boolean=true):Array
		{
			var retArr:Array=[];

			try
			{
				var v:Number;
				var i:uint=0;
				if (OutY[0] > OutY[1])
				{
					retArr.push(0);
					i++; // the next must not be extremum
				}

				var n:uint=OutY.length;
				for (i=0; i < n - 1; i++)
				{
					v=OutY[i];
					if (v > OutY[i - 1] && v > OutY[i + 1])
					{
						retArr.push(i);
						i++; // the next must not be extremum
					}
				}

				if (i < n && OutY[i] > OutY[i - 1])
					retArr.push(i);

				if (sortByY)
				{
					retArr.sort(sortOnYIndex);
						// retArr.reverse();
				}
			}
			catch (e:Error)
			{

			}

			return retArr;
		}

		private function sortOnYIndex(a:uint, b:uint):Number
		{
			var aPrice:Number=OutY[b];
			var bPrice:Number=OutY[a];
			if (aPrice > bPrice)
				return 1;
			else if (aPrice < bPrice)
				return -1;
			else //aPrice == bPrice
				return 0;
		}

		/**
		 * 频谱分析
		 * @param data 波形采用数组
		 * @param freq 采样频率
		 * @param nFirst FFT原始数据的起始点位置
		 * @param nCount FFT原始数据的点数
		 * @param mi 指定分析的线数相对2的幂次方，如： mi = 10，则线数为 2 的 10 次方 1024
		 * @param 正常返回 > 0 的最大幅值，-1 表示失败
		 */
		public function waveFFT(data:Array, freq:Number):Number
		{
			var nPointNumber:uint=data.length;
			var mi:int = Math.log(nPointNumber)/Math.LN2;
			if (nPointNumber != Math.pow(2, mi)){
				return -1 ;
				//throw new Error("waveFFT: the nCount must be pow of 2");
			}
				
			
			var fDF:Number=freq / nPointNumber;
			
			// 抽取
			var x_arr:Array=[];
			var y_arr:Array=[];
			x_arr.push(0);	 // 插入空白点
			x_arr = x_arr.concat(data);

			// 计算平均值average，并且令x[i] -= average以消除直流分量
			var i:int;
			var sum:Number=0;
			for (i=1; i < x_arr.length; i++)
				sum+=x_arr[i];
			var average:Number=sum / nPointNumber;
			for (i=1; i < x_arr.length; i++)
				x_arr[i]-=average;
			
			y_arr.length=(nPointNumber + 1);
			_o_fft(1, mi, x_arr, y_arr, nPointNumber);
			
			// 处理计算结果
			var fMaxFZ:Number=0;
			var lineCount:uint=nPointNumber / 2;
			OutX=[];
			OutY=[];
			OutPhase=[];
			OutX.length=lineCount;
			OutY.length=lineCount;
			OutPhase.length=lineCount;
			var xi:Number, yi:Number;
			for (i=0; i < lineCount; i++)
			{
				xi=x_arr[i + 1];
				yi=y_arr[i + 1];
				// 频率
				OutX[i]=i * fDF;
				// 幅值
				OutY[i]=Math.sqrt(xi * xi + yi * yi) * 4 / nPointNumber;
				// 相位 (弧度)
				OutPhase[i]= - (Math.atan2(yi, xi) - Math.PI/2);
				// 最大幅值
				fMaxFZ=Math.max(OutY[i], fMaxFZ);
			}
			
			if (fMaxFZ < Number.NEGATIVE_INFINITY || fMaxFZ > Number.POSITIVE_INFINITY)
				return -1;
			
			return fMaxFZ;
		}		
		
		/**
		 * 频谱分析
		 * @param data 波形采用数组
		 * @param freq 采样频率
		 * @param nFirst FFT原始数据的起始点位置
		 * @param nCount FFT原始数据的点数
		 * @param mi 指定分析的线数相对2的幂次方，如： mi = 10，则线数为 2 的 10 次方 1024
		 * @param 正常返回 > 0 的最大幅值，-1 表示失败
		 */
		public function waveFFTWithInterp(data:Array, freq:Number, nFirst:uint, nCount:uint, mi:uint):Number
		{
			var nPointNumber:uint=1;
			for (var i:uint=0; i < mi; i++)
				nPointNumber*=2;

			var pBegin:uint=nFirst;
			var nWaveCount:uint=data.length;
			if (nFirst >= nWaveCount)
				return -1;
			if ((nFirst + nCount) > nWaveCount)
				nCount=nWaveCount - nFirst;

			var all_count:uint=nCount;
			var fDF:Number=freq / all_count;

			// 抽取
			var x_arr:Array=[];
			var y_arr:Array=[];
			x_arr.length=(nPointNumber + 1);
			x_arr[0]=0; // 插入空白点
			var pos:int, ipos0:int, ipos1:int;
			var v0:Number, v1:Number, t:Number, v:Number;
			for (i=0; i < (nPointNumber - 1); i++)
			{
				// i * nCount 可能很大，超过int的范围
				// 因此用double进行计算
				pos = i;
				pos = (pos * (nCount - 1)) / nPointNumber;
				ipos0 = pos;
				ipos1=ipos0 + 1;
				v0=data[pBegin + ipos0];
				v1=data[pBegin + ipos1];
				// 插值
				t=pos - ipos0;
				v=v0 + (v1 - v0) * t;
				x_arr[i + 1]=v;
			}
			x_arr[i + 1]=data[pBegin + nCount - 1]; // 插入最后一个点

//			if (x_arr.length != (nPointNumber+1))
//				return -1;

			// 计算平均值average，并且令x[i] -= average以消除直流分量
			var sum:Number=0;
			for (i=1; i < x_arr.length; i++)
				sum+=x_arr[i];
			var average:Number=sum / nPointNumber;
			for (i=1; i < x_arr.length; i++)
				x_arr[i]-=average;

			y_arr.length=(nPointNumber + 1);
			_o_fft(1, mi, x_arr, y_arr, nPointNumber);

			// 处理计算结果
			var fMaxFZ:Number=0;
			var number:uint=nPointNumber / 2;
			OutX=[];
			OutY=[];
			OutPhase=[];
			OutX.length=number;
			OutY.length=number;
			OutPhase.length=number;
			var xi:Number, yi:Number;
			for (i=0; i < number; i++)
			{
				xi=x_arr[i + 1];
				yi=y_arr[i + 1];
				// 频率
				OutX[i]=i * fDF;
				// 幅值
				OutY[i]=Math.sqrt(xi * xi + yi * yi) * 4 / nPointNumber;
//				OutY[i]=Math.sqrt(xi * xi + yi * yi)*2 / nPointNumber;//修改
				// 相位 (弧度)
				OutPhase[i]=Math.atan2(yi, xi);
				// 最大幅值
				fMaxFZ=Math.max(OutY[i], fMaxFZ);
			}

			if (fMaxFZ < Number.NEGATIVE_INFINITY || fMaxFZ > Number.POSITIVE_INFINITY)
				return -1;

			return fMaxFZ;
		}
				
		/**
		 * @method  fft
		 * @description  Fast Fourier transform -- this calculates an in-place
		 *               complex-to-complex fft. x_arr and y_arr are the real and
		 *               imaginary number arrays of 2^m points.
		 *               <blockquote><pre>
		 *               Formula: forward
		 *                           N-1
		 *                           ---
		 *                       1   \          - j k 2 pi n / N
		 *               X(n) = ---   >   x(k) e                    = forward transform
		 *                       N   /                                n=0..N-1
		 *                           ---
		 *                           k=0
		 *
		 *               Formula: reverse
		 *                           N-1
		 *                           ---
		 *                           \          j k 2 pi n / N
		 *               X(n) =       >   x(k) e                    = reverse transform
		 *                           /                                n=0..N-1
		 *                           ---
		 *                           k=0
		 *
		 * @usage  <pre>Fourier.fft(dir, m, x_arr, y_arr);</pre>
		 * @param   dir   (Number)  -- 1 gives forward transform, -1 gives reverse transform.
		 * @param   m   (Number)  -- a positive integer.
		 * @param   x_arr   (Array)  -- an array containing x-axis values for real number input.
		 * @param   y_arr   (Array)  -- an array containing y-axis values for imaginary number input.
		 * @param	n		-- 分析线数，即使用 x_arr 的长度，此长度必须与 m 相匹配，否则将会计算错误，如果 n = 0，则自动计算
		 * @return  (Boolean)
		 **/
		private static function _fft(dir:Number, m:Number, x_arr:Array, y_arr:Array, n:uint=0):Boolean
		{
			var i:Number, j:Number, k:Number, l:Number, z:Number;
			var i1:Number, i2:Number, l1:Number, l2:Number, c1:Number, c2:Number;
			var tx:Number, ty:Number, t1:Number, t2:Number, u1:Number, u2:Number;

			// Calculate the number of points
			if (n == 0)
			{
				n=1;
				for (i=0; i < m; i++)
					n*=2;
			}

			y_arr.length=n;
			for (i=0; i < n; i++)
				y_arr[i]=0;

			// Do the bit reversal
			i2=n >> 1;
			j=0;
			for (i=0; i < n - 1; i++)
			{
				if (i < j)
				{
					tx=x_arr[i];
					ty=y_arr[i];
					x_arr[i]=x_arr[j];
					y_arr[i]=y_arr[j];
					x_arr[j]=tx;
					y_arr[j]=ty;
				}
				k=i2;
				while (k <= j)
				{
					j-=k;
					k>>=1;
				}
				j+=k;
			}
			//trace("m:"+m+", n:"+n+", j:"+j+", k:"+k);

			// Compute the fft
			c1=-1.0;
			c2=0.0;
			l2=1;
			for (l=0; l < m; l++)
			{
				l1=l2;
				l2<<=1;
				u1=1.0;
				u2=0.0;
				for (j=0; j < l1; j++)
				{
					for (i=j; i < n; i+=l2)
					{
						i1=i + l1;
						t1=u1 * x_arr[i1] - u2 * y_arr[i1];
						t2=u1 * y_arr[i1] + u2 * x_arr[i1];
						x_arr[i1]=x_arr[i] - t1;
						y_arr[i1]=y_arr[i] - t2;
						x_arr[i]+=t1;
						y_arr[i]+=t2;
					}
					z=u1 * c1 - u2 * c2;
					u2=u1 * c2 + u2 * c1;
					u1=z;
				}
				c2=Math.sqrt((1.0 - c1) / 2.0);
				if (dir == 1)
					c2=-c2;
				c1=Math.sqrt((1.0 + c1) / 2.0);
			}

			//trace('c1:'+c1+', c2:'+c2+', z:'+z);

			// Scaling for forward transform
			if (dir == 1)
			{
				for (i=0; i < n; i++)
				{
					x_arr[i]/=n;
					y_arr[i]/=n;
				}
					//trace('n:'+n+' ..x:['+x+'], y:['+y+']');
			}

			return true;
		}

		public static function fftTest(i_dianshu_mi:Number, x:Array, y:Array, i_dianshu:uint):void
		{
			_o_fft(1, i_dianshu_mi, x, y, i_dianshu);
		}

		
		/**
		 * 计算指定 x 点序列的FFT
		 * i_dianshu：波形的长度；
		 * i_dianshu_mi：i_dianshu是2的多少次幂？如果i_dianshu=1024，则i_dianshu_mi=10；
		 *
		 * x[]：时域波形存放区，x[0]=0；x[1]到x[i_dianshu]中存放时域波形；
		 * y[]：从y[0]到y[i_dianshu]初始化为0；
		 *
		 * fft完成之后：x[1]到x[i_dianshu/2]中存放存放频谱的X坐标值；y[1]到y[i_dianshu/2]中存放频谱的Y坐标值；
		 *
		 * 每一点的辐值：sqrt(x[i] * x[i] + y[i] * y[*]) * 4 / i_dianshu;
		 * 每一点的相位：atan2(x[i],y[i]);
		 *
		 * @return 函数返回 y, y[1]到y[i_dianshu/2]中存放频谱的Y坐标值；
		 **/
		private static function _o_fft(dir:Number, i_dianshu_mi:Number, x:Array, y:Array, i_dianshu:uint=0):void
		{
			var i:int, j:int, k:int, l:int, m:int, l1:int;
			var t1:Number, t2:Number, u1:Number, u2:Number, w1:Number, w2:Number, p2:Number, z:Number;

			// Calculate the number of points
			if (i_dianshu == 0)
			{
				i_dianshu=1;
				for (i=0; i < i_dianshu_mi; i++)
					i_dianshu*=2;
			}

			y.length=i_dianshu + 1;
			for (i=0; i <= i_dianshu; i++)
				y[i]=0;

			j=1;

			for (l=1; l <= (i_dianshu - 1); l++)
			{
				if (l < j)
				{
					t1=x[j];
					t2=y[j];
					x[j]=x[l];
					y[j]=y[l];
					x[l]=t1;
					y[l]=t2;
				}
				k=(i_dianshu) >> 1;
				while (k < j)
				{
					j-=k;
					k=k >> 1;
				}
				j=j + k;
			}
			m=1;

			for (i=1; i <= i_dianshu_mi; i++)
			{
				u1=1;
				u2=0;
				k=m;
				m=m << 1;
				p2=3.1415926 / k;
				w1=(Math.cos(p2));
				w2=(-Math.sin(p2));
				w2=-w2;
				for (j=1; j <= k; j++)
				{
					for (l=j; l <= i_dianshu; l+=m)
					{
						l1=l + k;
						t1=x[l1] * u1 - y[l1] * u2;
						t2=x[l1] * u2 + y[l1] * u1;
						x[l1]=x[l] - t1;
						y[l1]=y[l] - t2;
						x[l]+=t1;
						y[l]+=t2;
					}
					z=u1 * w1 - u2 * w2;
					u2=u1 * w2 + u2 * w1;
					u1=z;
				}
			}
		}

		/**
		 *  
		 * @param real real[len] 输入实部的数组
		 * @param image image[len] 输入虚部的数组
		 * @param m len = 1<<m  幂
		 * @return  xout[len] 输出实部的数组
		 * 
		 */		
		public function ifft(real:Array,image:Array,m:int):Array
		{
			var k:int,le:int,windex:int,i:int,j:int;
			var tempWindex:int=0,n:int=1;
			
			var xi_x:Number,xi_y:Number,xip_x:Number,xip_y:Number,temp_x:Number,temp_y:Number,u_x:Number,u_y:Number,tm_x:Number,tm_y:Number;
			var arg:Number,w_real:Number,w_imag:Number,wrecur_real:Number,wrecur_imag:Number,wtemp_real:Number;
			n = 1<< m;
			le = n*0.5;

			var wptr0:Array = new Array(le-1),wptr1:Array = new Array(le-1),xout:Array = new Array(n),x1:Array = new Array(n);
			
			for (i=0;i<n;i++)
			{
				x1[i] = 0;
			}
			
			for (i=0;i<n;i++)
			{
				xout[i] = real[i];
				x1[i] = image[i];
			}
			
			arg = 4.0*Math.atan(1.0)/le;
			wrecur_real = w_real = Math.cos(arg);
			wrecur_imag = w_imag = Math.sin(arg);
			
			for(j=0;j<(le-1);j++)
			{
				wptr0[j] = wrecur_real;
				wptr1[j] = wrecur_imag;
				wtemp_real = wrecur_real*w_real-wrecur_imag*w_imag;
				wrecur_imag = wrecur_real*w_imag+wrecur_imag*w_real;
				wrecur_real = wtemp_real;
			}
			
			le=n;
			windex=1;
			for(var kk:int=0;kk<m;kk++)
			{
				le = le*0.5;
				for(i=0;i<n;i=i+2*le)
				{
					xi_x=xout[i];
					xi_y=x1[i];
					xip_x=xout[i+le];
					xip_y=x1[i+le];
					
					temp_x=xi_x+xip_x;
					temp_y=xi_y+xip_y;
					xip_x=xi_x-xip_x;
					xip_y=xi_y-xip_y;
					
					xout[i+le]=xip_x;
					x1[i+le]=xip_y;
					xout[i]=temp_x;
					x1[i]=temp_y;
				}
				
				tempWindex=windex-1;
				for(j=1;j<le;j++)
				{
					
					u_x=wptr0[tempWindex];
					u_y=wptr1[tempWindex];
					
					for(i=j;i<n;i=i+2*le)
					{
						xi_x=xout[i];
						xi_y=x1[i];
						xip_x=xout[i+le];
						xip_y=x1[i+le];
						
						temp_x=xi_x+xip_x;
						temp_y=xi_y+xip_y;
						tm_x=xi_x-xip_x;
						tm_y=xi_y-xip_y;
						xip_x=tm_x*u_x-tm_y*u_y;
						xip_y=tm_x*u_y+tm_y*u_x;
						
						xout[i+le]=xip_x;
						x1[i+le]=xip_y;
						xout[i]=temp_x;
						x1[i]=temp_y;
						
					}
					tempWindex=tempWindex+windex;
					
				}
				
				windex=2*windex;
			}
			
			
			j=0;
			for(i=1;i<(n-1);i++)
			{
				k=n/2;
				while(k<=j)
				{
					j=j-k;
					k=k*0.5;
				}
				j=j+k;
				if(i<j)
				{
					xi_x=xout[i];
					xi_y=x1[i];
					temp_x=xout[j];
					temp_y=x1[j];
					
					xout[j]=xi_x;
					x1[j]=xi_y;
					xout[i]=temp_x;
					x1[i]=temp_y;
				}
			}
			
			return xout;
		}
		
		/**
		 * ifft 
		 * @param xin
		 * @param m
		 * @return 
		 * 
		 */		
		public function ifft2(xin:Array2,m:int):Array2
		{
			var scale:Number;
		
			var n:int=1;
			var k:int,l:int,le:int,windex:int;
			var tempWindex:int = 0;
			var i:int,j:int;
			
			var wptr:Array2;
			var xi:Array2,xip:Array2,temp:Array2,u:Array2,tm:Array2;
			xi = new Array2(1,2);
			xip = new Array2(1,2);
			temp = new Array2(1,2);
			u = new Array2(1,2);
			tm = new Array2(1,2);
			
			var arg:Number,w_real:Number,w_imag:Number,wrecur_real:Number,wrecur_imag:Number,wtemp_real:Number;
			
			n = 1<<m;
			le = n/2;
			
			var x:Array2 = new Array2(n,2);
			for( i=0;i<n;i++)
			{
				x.set(i,0,xin.get(i,0));
				x.set(i,1,xin.get(i,1));
			}
			
			wptr = new Array2(le-1,2);
			arg = 4.0*Math.atan(1.0)/le;
			wrecur_real = w_real = Math.cos(arg);
			wrecur_imag = w_imag = Math.sin(arg);
			
			for(j=0;j<(le-1);j++)
			{
				wptr.set(j,0,wrecur_real);
				wptr.set(j,1,wrecur_imag);
				wtemp_real = wrecur_real*w_real-wrecur_imag*w_imag;
				wrecur_imag = wrecur_real*w_imag+wrecur_imag*w_real;
				wrecur_real = wtemp_real;
			}
			
			le = n;
			windex = 1;
			for(var kk:int=0;kk<m;kk++)
			{
				le = le*0.5;
				for(i=0;i<n;i=i+2*le)
				{
					xi.set(0,0,x.get(i,0));
					xi.set(0,1,x.get(i,1));
					xip.set(0,0,x.get(i+le,0));
					xip.set(0,1,x.get(i+le,1));
					
					temp.set(0,0,xi.get(0,0)+xip.get(0,0));
					temp.set(0,1,xi.get(0,1)+xip.get(0,1));
					xip.set(0,0,xi.get(0,0)-xip.get(0,0));
					xip.set(0,1,xi.get(0,1)-xip.get(0,1));
					
					x.set(i+le,0,xip.get(0,0));
					x.set(i+le,1,xip.get(0,1));
					x.set(i,0,temp.get(0,0));
					x.set(i,1,temp.get(0,1));
				}
				
				tempWindex=windex-1;
				for(j=1;j<le;j++)
				{
					u.set(0,0,wptr.get(tempWindex,0));
					u.set(0,1,wptr.get(tempWindex,1));
					
					for(i=j;i<n;i=i+2*le)
					{
						xi.set(0,0,x.get(i,0));
						xi.set(0,1,x.get(i,1));
						xip.set(0,0,x.get(i+le,0));
						xip.set(0,1,x.get(i+le,1));
						
						temp.set(0,0,xi.get(0,0)+xip.get(0,0));
						temp.set(0,1,xi.get(0,1)+xip.get(0,1));
						tm.set(0,0,xi.get(0,0)-xip.get(0,0));
						tm.set(0,1,xi.get(0,1)-xip.get(0,1));
						xip.set(0,0,tm.get(0,0)*u.get(0,0)-tm.get(0,1)*u.get(0,1));
						xip.set(0,1,tm.get(0,0)*u.get(0,1)+tm.get(0,1)*u.get(0,0));
						
						xi.set(i+le,0,xip.get(0,0));
						xi.set(i+le,1,xip.get(0,1));
						
						xi.set(i,0,temp.get(0,0));
						xi.set(i,1,temp.get(0,1));
					}
					
					tempWindex = tempWindex + windex;
					
				}
				
				windex = 2*windex;
			}
			
			
			j = 0;
			for(i=1;i<(n-1);i++)
			{
				k = n*0.5;
				while(k<=j)
				{
					j = j - k;
					k = k * 0.5;
				}
				j = j + k;
				if(i<j)
				{
					xi.set(0,0,x.get(i,0));
					xi.set(0,1,x.get(i,1));
					temp.set(0,0,x.get(j,0));
					temp.set(0,1,x.get(j,1));
					
					x.set(j,0,xi.get(0,0));
					x.set(j,1,xi.get(0,1));
					x.set(i,0,temp.get(0,0));
					x.set(i,1,temp.get(0,1));
				}
			}
			return x;
		}
	}
}
