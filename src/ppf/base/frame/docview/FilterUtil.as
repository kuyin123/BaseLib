package ppf.base.frame.docview
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * 滤镜
	 * @author KK
	 * 
	 */	
	public final class FilterUtil
	{
		/**
		 * 浮雕滤镜
		 * @return 矩阵盘绕滤镜效果（卷积滤镜）
		 * 
		 */		
		static public function get rilievoColorMatrix():ConvolutionFilter
		{
			if(null == _convolutionFilter)
				_convolutionFilter = new ConvolutionFilter(-3,-3,[-0.2,-0.1,0,-0.1,1,0.1,0,0.1,0.2]);
			return _convolutionFilter;
		}
		
		/**
		 * 灰度滤镜
		 * @return 颜色矩阵滤镜
		 * 
		 */		
		static public function get cinerationColorMatrix():ColorMatrixFilter
		{
			if(!_cinerationFilter)
			{
				var _cinerationFilter:ColorMatrixFilter = new ColorMatrixFilter();
				_cinerationFilter.matrix =  _bwMatrix;
			}
			return _cinerationFilter;
		}
		
		/**
		 * 阴影滤镜
		 * @return 
		 * 
		 */		
		static public function get shadowfilters():DropShadowFilter
		{
			if (null == _shadowfilters)
				_shadowfilters = new DropShadowFilter(3, 90, 0x333333, 0.5, 4, 4, 1);
			return _shadowfilters;
		}
		
		/**
		 * 边框滤镜  
		 * @return 
		 * 
		 */		
		static public function get borderGlowfilters():GlowFilter
		{
			if (null == _borderGlowFilter)
				_borderGlowFilter = new GlowFilter(0x86ffea,0.75,2,2,10,6);
				
			return _borderGlowFilter;
		}
		
		public function FilterUtil()
		{
			throw new Error("FilterUtil类只是一个静态方法类!");  
		}
		
		static private var _cinerationFilter:ColorMatrixFilter;
		
		/**
		 * 边框滤镜 
		 */		
		static private var _borderGlowFilter:GlowFilter;
		/**
		 * 阴影滤镜
		 */		
		static private var _shadowfilters:DropShadowFilter;
		
		static private var _convolutionFilter:ConvolutionFilter;
		
		/**
		 * 颜色（红色通道）
		 */
		static private var _rLum:Number = 0.2225; 
		/**
		 * 颜色（绿色通道）
		 */		
		static private var _gLum:Number = 0.7169; 
		/**
		 * 颜色（蓝色通道）
		 */		
		static private var _bLum:Number = 0.0606;  
		
		/**
		 * 灰度矩阵数组
		 */	
		static private var _bwMatrix:Array = [
			_rLum, _gLum, _bLum, 0, 0, 
			_rLum, _gLum, _bLum, 0, 0, 
			_rLum, _gLum, _bLum, 0, 0, 
			0, 0, 0, 0.4, 0]; 
	}
}