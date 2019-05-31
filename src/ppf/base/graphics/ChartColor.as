package ppf.base.graphics
{
	public class ChartColor
	{
	
		static public const waveBK:Number			= 0XFFFFFF;	//波形窗口背景
		static public const waveLine:Number			= 0X0033FF;	//波形
		static public const boundaryLine:Number		= 0X4D6A8C;	//边线0X000000 2014-10-14
		static public const selectLine:Number		= 0XBBBB00;	//选择光标
		static public const selectLine2:Number		= 0X000000;	//选择光标
		static public const tipLine:Number		= 0X000000; //标签光标
		static public const centerLine:Number		= 0XA90404;	//中心线
		static public const gridLine:Number			= 0XDADADA;	//网格线
		static public const containerBoundary:Number= 0X999999;	//容器边框线
		static public const axisLine:Number			= 0X000000;	//刻度线
		static public const axisTextBK:Number		= 0XFFFFFF;	//刻度文字背景
		static public const axisText:Number			= 0X000000;	//刻度文字
		//static public const axisBK:Number			= 0X626C7B;	//刻度窗口背景
		static public const axisBK:Number			= 0XFFFFFF;	//刻度窗口背景
		static public const tipText:Number			= 0XFFFFFF;	//标签文字
		static public const axisBorder:Number 		= 0X4D6A8C; //边框颜色
//	第四种颜色  金黄 0xFFCC00,
		static public const RandomColors : Array =
		[
			0x0000FF,
			0x993366,
			0xFF00CC,
			0x663300,
			0x048484,
			0x66CCFF,
			0x996666,
			0x4e3bba,
			0x99CCCC,
			0xCC9933,
			0x3300CC,
			0x006633,
			0x993300,
			0xFFCCFF,
			0xCC00CC,
			0x9900CC,
			0xCCCC00,	
		]
				
		static private var randomCounter:uint = 0;
		static public function getRandomColor (i : int = -1) : Number
		{
			if (-1 == i)
				i = randomCounter ++;
			return RandomColors[i*3 % RandomColors.length];
		}
		
		/**
		 * 获取颜色数组 
		 * @return 
		 * 
		 */		
		static public function getColors():Array
		{
			return RandomColors;
		}
		
		// 透明度
		static public const alphaTip:Number		= 1.0;		//标签
	}
}