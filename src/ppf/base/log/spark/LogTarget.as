package ppf.base.log.spark
{
	import mx.logging.LogEventLevel;
	import mx.logging.targets.LineFormattedTarget;
	import spark.components.TextArea;
	import mx.core.mx_internal;
	use namespace mx_internal
	
	public class LogTarget extends LineFormattedTarget
	{
		static public var logMaxChars:Number = 30000;
		
		public function LogTarget(textArea:TextArea)
		{
			super();
			
			this.level = LogEventLevel.ERROR;   
			this.includeDate = true;   
			this.includeLevel = true;   
			this.includeTime = true; 
			
			_textArea = textArea;  
		}
		
		mx_internal override function internalLog(message:String):void
		{
			var string:String;
			string = _textArea.text + message + "\n";
			
			if (string.length > LogTarget.logMaxChars)
				_textArea.text = _textArea.text.substring(string.length-LogTarget.logMaxChars);
			
			_textArea.appendText(message + "\n");
		}
		private var _textArea:TextArea;
	}
}