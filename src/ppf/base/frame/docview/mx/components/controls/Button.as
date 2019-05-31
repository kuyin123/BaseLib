package ppf.base.frame.docview.mx.components.controls
{
	import ppf.base.frame.docview.FilterUtil;
	
	import mx.controls.Button;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	/**
	 * enabled = false 时使得icon的图标变灰 
	 * @author KK
	 * 
	 */	
	public final class Button extends mx.controls.Button
	{
		public function Button()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			if (null != currentIcon)
				currentIcon.filters = enabled ? null : [FilterUtil.cinerationColorMatrix,FilterUtil.rilievoColorMatrix];
			
		}
	}
}