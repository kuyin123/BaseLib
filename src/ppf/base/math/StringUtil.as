package ppf.base.math
{
	public final class StringUtil
	{
		/**
		 * 字符加入换行\n
		 * @param str 需要换行的字符
		 * @return 加入换行符号后的字符
		 * 
		 */		
		static public function joinWrap(str:String):String
		{
			var tmpStr:String = str.split("").join("\n");
			return tmpStr;
		}
		
		/**
		 * 字符加入换行<br/>
		 * @param str 需要换行的字符
		 * @return 加入换行符号后的字符
		 * 
		 */		
		static public function joinWrapBr(str:String):String
		{
			var tmpStr:String = str.split("").join("<br/>");
			return tmpStr;
		}
		
		/**
		 * 分离标记语言 
		 * <a>aaa</a><br>test<br>分离后为aaatest
		 * @param str 编辑字符
		 * @return 分离出的字符
		 * 
		 */		
		static public function splitMarkup(str:String):String
		{
			var leftArr:Array = str.split('<');
			var joinStr:String = leftArr.join(">");
			var rightArr:Array = joinStr.split('>');
			var tmpStr:String ="";
			while (rightArr.length>0) 
			{
				var shiftStr:String = rightArr.shift()
				tmpStr += shiftStr;
				rightArr.shift();
			}
			return tmpStr;
		}
		
		/**
		 * 字符前面补足字符 
		 * @param str 要补足的字符
		 * @param fill 补足的位数
		 * @param fillStr 补足的字符
		 * @return 补足后的字符
		 * 
		 */		
		static public function strFillFront(str:String,fill:Number=0,fillStr:String="0"):String
		{
			var tmpStr:String = str;
			if (null == str)
			{
				trace("StringUtil::strFillFront str is null");
				return "";
			}
			var len:Number = str.length;
			
			if (len < fill)
			{
				for (var i:Number=len; i<fill; i++)
				{
					tmpStr = fillStr + tmpStr;
				}
			}
			
			return tmpStr;
		}
		/**
		 * 数字字符串转数字数组
		 * @param str 字符串string
		 * @param n 间隔位数
		 * @return 数字数组
		 * 
		 */		
		static public function str2NumArr(str:String,n:int):Array
		{
			var arr:Array = [];
			var len:int = str.length;
			
			for (var i:int=0;i<len;i+=n)
			{
				var tmpStr:String = str.substr(i,n);
				var tmpNum:Number = Number(tmpStr);
				arr.push(tmpNum);
			}
			
			return arr;
		}
		
		/**
		 * 数字字符串转字符数组
		 * @param str 字符串string
		 * @param n 间隔位数
		 * @return 数字数组
		 * 
		 */		
		static public function str2StrArr(str:String,n:int):Array
		{
			var arr:Array = [];
			var len:int = str.length;
			
			for (var i:int=0;i<len;i+=n)
			{
				var tmpStr:String = str.substr(i,n);
				arr.push(tmpStr);
			}
			
			return arr;
		}
		
		public function StringUtil()
		{
			throw new Error("StringUtil类只是一个静态方法类!");  
		}
	}
}