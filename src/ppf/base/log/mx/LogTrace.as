package ppf.base.log.mx
{
	import mx.controls.TextArea;
	import mx.logging.Log;
	
	public class LogTrace extends TextArea
	{
		public function LogTrace()
		{
			super();
			
			_logTarget = new LogTarget(this);    
			_logTarget.includeDate = true;    
			_logTarget.includeTime = true;    
			_logTarget.includeLevel = true;    
			_logTarget.includeCategory = true;    
			
			_logTarget.filters = ["*"];    
			Log.addTarget(_logTarget);
		}
		override protected function createChildren():void
		{
			super.createChildren();
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.minHeight = 300;
			this.minWidth = 300;
		}
		
		private var _logTarget:LogTarget; 
	}
}