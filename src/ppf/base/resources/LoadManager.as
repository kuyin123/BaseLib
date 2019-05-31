package ppf.base.resources
{
	import ppf.base.log.Logger;
	import ppf.base.math.MathUtil;
	import ppf.base.resources.loaders.AssetLoader;
	import ppf.base.resources.loaders.AssetLoaderTypes;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.events.ResourceEvent;
	import mx.events.StyleEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	
	/**
	 * 用于载入各种资源（xml、多国语言包、css） 
	 * @author wangke
	 * 
	 */	
	public final class LoadManager extends EventDispatcher
	{
		/**
		 * 载入xml
		 * @param str xml文件名
		 * @param ver 文件名版本号，可以是null. 使用ver可以修改下载的文件名，消除浏览器缓存带来的更新无效的问题
		 * @param callBackfunc 完成回调处理函数
		 * @param isLocale 是否区分语言，true：区分，读取xml/当前语言下文件夹下 false:不区分默认读取xml文件夹下的
		 * 
		 */		
		static public function loadXML(str:String, ver:String, callBackfunc:Function, isLocale:Boolean=false):void
		{
			var url:String= "xml/"+(isLocale?(currLocale+ "/"):"") + str;
			if (ver)
				url = url + "?" + ver;
			new AssetLoader(url, {onComplete:callBackfunc,filetype: AssetLoaderTypes.XML});
		}
		
		/**
		 * 载入css  默认：css/style.swf
		 * @param str
		 * 
		 */		
		static public function loadCss(str:String="style.swf"):void
		{
			var url:String = str;
			var eventDispatcher:IEventDispatcher;
			eventDispatcher = (FlexGlobals.topLevelApplication.styleManager as IStyleManager2).loadStyleDeclarations(url);
			
			eventDispatcher.addEventListener(StyleEvent.COMPLETE, onCssCompleteHandler);
			eventDispatcher.addEventListener(StyleEvent.ERROR, onCssIoErrorHandler);
		}
		
		/**
		 * 改变语言,读取语言swf资源包 默认：locale/语言类型/语言swf
		 * @param locale 语言类型  en_US  zh_CN
		 * @param str 语言swf资源名 默认resources.swf
		 * 
		 */		
		static public function loadLanguage(locale:String="zh_CN",str:String="resources.swf"):void 
		{
			currLocale = locale;
			var url:String = "locale/"+locale + "/"+str;	// + "?" + uint((new Date).time/60000);
			//判断不会重复加载
			if (null == _resDict[url])
			{
				var eventDispatcher:IEventDispatcher = rm.loadResourceModule(url);
				// Search for the text string first in the locale just selected, but fallback on en_US
				var localeChain:Array = [locale];
				
				eventDispatcher.addEventListener(ResourceEvent.COMPLETE, onLoadLanguageCompleteHandler);
				eventDispatcher.addEventListener(ResourceEvent.ERROR,onLoadLanguageError,false,0,true);
				_resDict[url] = url;
			}
			else
			{
				rm.localeChain = [currLocale];
			}
			
		}
		/**
		 * 卸载指定的已加载的语言包 
		 * @param locale
		 * 
		 */		
		static public function uoloadResource(locale:String,str:String="resources.swf"):void
		{
			var url:String = "locale/"+locale + "/"+str + "?" + uint((new Date).time/60000);
			if (_resDict.hasOwnProperty(url))
			{
				rm.unloadResourceModule(url);
				delete _resDict[url];
			}
		}
		
		
		public function LoadManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * 读取语言包成功处理函数 
		 * @param event
		 * 
		 */		
		static private function onLoadLanguageCompleteHandler(event:ResourceEvent):void 
		{
			rm.localeChain = [currLocale];
		}
		/**
		 * 读取语言包失败处理函数 
		 * @param event
		 * 
		 */		
		static private function onLoadLanguageError(event:ResourceEvent):void
		{
			Logger.debug("LoadManager::onLoadLanguageError "+event.errorText);
		}
		
		static private function onCssCompleteHandler(event:StyleEvent):void 
		{
			
		}
		
		static private function onCssIoErrorHandler(event:StyleEvent):void
		{
			Logger.debug("into ioErrorHandler");
		}
		
		static private function get rm():mx.resources.IResourceManager
		{
			return mx.resources.ResourceManager.getInstance();
		}
		
		static private var _resDict:Dictionary = new Dictionary(true);
		/**
		 * 当前的语言 
		 */		
		static private var currLocale:String = LocaleConst.ZH_CN; 
	}
}