package ppf.base.log.spark
{
	import mx.logging.Log;
	
	import spark.components.TextArea;
	
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
			this.minHeight = 500;
			this.minWidth = 350;
		}
		
		private var _logTarget:LogTarget; 
	}
}