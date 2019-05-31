package ppf.base.resources
{
	public final class LocaleConst
	{
		static public const ZH_CN:String = "zh_CN";
		
		static public const EN_US:String = "en_US";
		
		/**
		 *  CallResponder.properties
		 */		
		static public const RPC:String = "rpc";
		
		/**
		 * public.properties
		 */		
		static public const PUBLIC:String = "public";
		
		static public const SET:String = "set";
		
		static public const VIEW:String="view";
		
		static public const SERVER_CODE:String = "server_code";
		
		static public const CMD:String = "cmd";//菜单命令
		
		static public const CMD_OP:String = "cmd_op";//操作命令
		
		static public const FONT_FAMILY:String = "黑体";
		
		static public const LIB:String = "lib";//底层语言包
		
		public function LocaleConst()
		{
			throw new Error("LocaleConst类只是一个静态方法类!"); 
		}
	}
}