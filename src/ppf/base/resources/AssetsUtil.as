package ppf.base.resources
{
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;

	/**
	 * 根据字符读取资源文件CSS图标
	 * 默认读取CSS中的.icon
	 * @author KK
	 * 
	 */	
	public final class AssetsUtil extends Object 
	{
		[Embed(source="/assets/realtime.png")]
		static public var realTimeMark:Class;
		[Embed(source="/assets/hisData.png")]
		static public var historyMark:Class;
		[Embed(source="/assets/startup.png")]
		static public var startupMark:Class;
		[Embed(source="/assets/blackbox.png")]
		static public var blackboxMark:Class;
		
		[Embed(source="/assets/hand_up.png")]
		static public var hand_up:Class;
		[Embed(source="/assets/hand_down.png")]
		static public var hand_down:Class;
		
		[Embed(source="/assets/resizeCursorH.gif")]
		static public var DEFAULT_RESIZE_CURSOR_HORIZONTAL:Class;
		
		[Embed(source="/assets/resizeCursorTLBR.gif")]
		static public var DEFAULT_RESIZE_CURSOR_TL_BR:Class;
		
		[Embed(source="/assets/resizeCursorTRBL.gif")]
		static public var DEFAULT_RESIZE_CURSOR_TR_BL:Class;
		
		[Embed(source="/assets/resizeCursorV.gif")]
		static public var DEFAULT_RESIZE_CURSOR_VERTICAL:Class;
		
		[Embed(source="/assets/move_arrow.png")]
		static public var DEFAULT_MOVE_CURSOR:Class;
		
		[Bindable]
		[Embed(source="/assets/smallRemove.png")]
		static public var DEFAULT_REMOVE:Class;
		
		[Bindable]
		[Embed(source="/assets/close.png")]
		static public var DEFAULT_SMALL_DELETE:Class;
		
		[Bindable]
		[Embed(source="/assets/smallerror.png")]
		static public var DEFAULT_SMALL_ERROR:Class;
		
		[Embed(source='/assets/first.png')]
		static public var first:Class;
		
		[Embed(source='/assets/last.png')]
		static public var last:Class;
		
		[Embed(source='/assets/next.png')]
		static public var next:Class;
		
		[Embed(source='/assets/previous.png')]
		static public var previous:Class;
		
		[Embed(source="/assets/map_all.png")]
		static public var chartAll:Class;
		
		[Embed(source="/assets/mapNormal.png")]
		static public var mapNormal:Class;
		
		[Embed(source="/assets/mapClick.png")]
		static public var mapClick:Class;
		
		[Embed(source="/assets/mapOver.png")]
		static public var mapOver:Class;
		
		[Embed(source="/assets/mapDisable.png")]
		static public var mapDisable:Class;
		
		[Embed(source="/assets/listNormal.png")]
		static public var listNormal:Class;
		
		[Embed(source="/assets/listClick.png")]
		static public var listClick:Class;
		
		[Embed(source="/assets/listOver.png")]
		static public var listOver:Class;
		
		[Embed(source="/assets/listDisable.png")]
		static public var listDisable:Class;
		
		[Embed(source="/assets/setNormal.png")]
		static public var setNormal:Class;
		
		[Embed(source="/assets/setClick.png")]
		static public var setClick:Class;
		
		[Embed(source="/assets/setOver.png")]
		static public var setOver:Class;
		
		[Embed(source="/assets/setDisable.png")]
		static public var setDisable:Class;
		
		[Embed(source="/assets/aboutNormal.png")]
		static public var aboutNormal:Class;
		
		[Embed(source="/assets/aboutClick.png")]
		static public var aboutClick:Class;
		
		[Embed(source="/assets/aboutOver.png")]
		static public var aboutOver:Class;
		
		[Embed(source="/assets/aboutDisable.png")]
		static public var aboutDisable:Class;
		
		public function AssetsUtil()
		{
			throw new Error("AssetsUtil类只是一个静态方法类!");  
		}
		
		static public function stringToIcon(icon:String,selector:String=".icon"):Class
		{
			var icoClass:Class;
			icoClass = AssetsUtil[icon];
			if(!icoClass)
				icoClass = stringToStyle(icon,selector);
			return icoClass;
		}
		
		static public function stringToStyle(icon:String,selector:String=".icon"):Class
		{
			var css:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration(selector);
			
			if (null != css)
				return css.getStyle(icon) as Class;
			return null;
		}
	}
}