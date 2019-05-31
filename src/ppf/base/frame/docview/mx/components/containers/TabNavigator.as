package ppf.base.frame.docview.mx.components.containers
{
	import flash.events.KeyboardEvent;
	
	import mx.containers.TabNavigator;
	
	public class TabNavigator extends mx.containers.TabNavigator
	{
		public function TabNavigator()
		{
			super();
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (null != focusManager)
			{
				super.keyDownHandler(event);
			}
		}
	}
}