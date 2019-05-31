package ppf.base.log
{
	import ppf.base.frame.CmdEvent;
	import ppf.base.frame.CommandManager;
	import ppf.base.frame.AlertUtil;
	
	import mx.controls.Alert;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	public class Logger
	{
		/**
		 *  是否是调试，true：是，显示调试信息
		 */		
		static public var isDebug:Boolean = true;
		/**
		 * 弹出Error的错误框
		 * @param err
		 * @param title
		 * 
		 */		
		static public function alertError(err:Error, title:String = ""):void
		{
			alertErrorString (err.message, "提示 " + title + " [" + err.errorID + "]"+err.getStackTrace());
			LogError(err);
		}
		
		/**
		 * 把字符串以弹出错误提示框的形式显示
		 * @param text 错误的内容
		 * @param title 错误的标题
		 * 
		 */		
		static public function alertErrorString(text:String, title:String="提示"):void
		{
			AlertUtil.show(text,title,Alert.OK|Alert.NONMODAL);
		}
		
		/**
		 * 记录Error错误LOG
		 * @param e 要记录的目标对象
		 * 
		 */		
		static public function LogError(err:Error):void
		{
			var errorName:String = err.name;
			var code:String = String(err.errorID);
			var what:String = err.message;
			
			Log.getLogger(CATEGORY).error("Code: [" + code + "]; \n\r Name: " + errorName + "; \r What: " + what + "\r >>>>>>>>>>>>>>>>>> End.\r\n");
		}
		
		/**
		 * 记录FaultEvent错误LOG
		 * @param event
		 * 
		 */		
		static public function LogErrorEvent(event:FaultEvent):void
		{
			var fault:Fault = event.fault as Fault;
			var code:String = fault.faultCode;
			var what:String = errorStr(code);
			var token:Object = event.token.message.body;
			var rootCause:Object = event.fault.rootCause;
			
			Log.getLogger(CATEGORY).error(
				"faultCode: [" + code + "]; \r"+ 
				(null == what?"":("描述:" +what + "; \r")) + 
				"Fault::faultString : \r"+fault.faultString + "; \r "+
				"Token:\r" + ObjectUtil.toString(token) + "; \r"+
				"Fault::rootCause: \r" + ObjectUtil.toString(rootCause) + "; \r"+
				"\r >>>>>>>>>>>>>>>>>> End.\r\n");
			
			//根据错误码弹出提示
			var errorObj:Object = event.fault.rootCause;
			if(errorObj&&errorObj.hasOwnProperty("code")){
 				CommandManager.getInstance().onCommand(new CmdEvent(null,event));
				//alertErrorString( "返回码："+ errCode + "\r" +ServerCodeUtil.getCodeStr(errCode)  + "\r" + errorObj["message"] , ServerCodeUtil.getCodeTypeName(errType)  );
			}
		}
		
		/**
		 * 记录调试信息错误LOG
		 * @param event
		 * 
		 */		
		static public function debug(text:String):void
		{
			trace(text);
			Log.getLogger(CATEGORY).error(text);
		}
		
		public function Logger()
		{
		}
		/**
		 * 根据错误代码读取资源的错误描述
		 * @param bundleName 资源的名称。
		 * @param code 错误代码
		 * @return 错误描述
		 * 
		 */		
		static private function errorStr(code:String,bundleName:String="errorCode"):String
		{
			return ResourceManager.getInstance().getString(bundleName,code);
		}
		
		/**
		 * 显示错误的弹出对话框
		 */		
		private static var alert:Alert = null;
		
		/**
		 * 记录日子的类型 
		 */		
		static protected const CATEGORY:String="com.grusen.logger";
	}
}