package ppf.base.log.mx
{
	import flash.events.MouseEvent;
	
	import mx.controls.TextArea;
	import mx.core.mx_internal;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.LineFormattedTarget;

	use namespace mx_internal
	
	public class LogTarget extends LineFormattedTarget
	{
		static public var logMaxChars:Number = 30000;
		private var _isMoveText:Boolean = true;
		
		public function LogTarget(textArea:TextArea)
		{
			super();
			
			this.level = LogEventLevel.ERROR;   
			this.includeDate = true;   
			this.includeLevel = true;   
			this.includeTime = true; 
			
			_textArea = textArea;  
			_textArea.doubleClickEnabled=true;
			_textArea.addEventListener(MouseEvent.DOUBLE_CLICK , onMouseOver , false , 0 ,true);
		}
		
		private function onMouseOver(e:MouseEvent):void{
			_isMoveText = !_isMoveText;
		}
 	 
		mx_internal override function internalLog(message:String):void
		{
			if(!_isMoveText)
				return ;
			var string:String;
			string = _textArea.text + message + "\n";
			
			if (string.length > LogTarget.logMaxChars)
				string = string.substring(string.length-LogTarget.logMaxChars);
			
			_textArea.text = string;
			
 			  _textArea.validateNow();
			  _textArea.verticalScrollPosition = _textArea.maxVerticalScrollPosition;
 		}
		private var _textArea:TextArea;
	}
}