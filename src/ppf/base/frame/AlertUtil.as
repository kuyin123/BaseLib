package ppf.base.frame
{
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	use namespace mx_internal;
	
	/**
	 * Alert的工具类</br/>
	 * 更改文本和标题</br/>
	 * 支持html</br/>
	 * 支持去除按钮</br/>
	 * 支持删除 </br/>
	 * @author wangke</br/>
	 */	
	public final class AlertUtil
	{
		/**
		 * 弹出alert提示框，如果存在更新标题和文本
		 * @param text 在 Alert 控件中显示的文本字符串
		 * @param title 标题栏中显示的文本字符串
		 * @param isHtmlText 是否是html字符
		 * 
		 */		
		static public function show(text:String = "", title:String = "",flags:uint = 0x4,closeHandler:Function = null,isHtmlText:Boolean=false):void
		{
			if (null != _alert && null != _alert.parent && _alert.parent.contains(_alert))
			{
				if (_alert.buttonFlags == flags)
				{
					_alert.title = title;
					_alert.mx_internal::alertForm.mx_internal::textField.text = text;
				}
				else
					removeAlert();
			}
			
			if (null == _alert )
			{
				_alert = Alert.show(text, title, flags,null,alertClose);
			}
			_closeFunc = closeHandler;
			
			if (isHtmlText)
				_alert.mx_internal::alertForm.mx_internal::textField.htmlText = text;
		 
		}
		
		/**
		 * 手动发送移出的处理事件 
		 * @param buttonPressed
		 * 
		 */		
		static public function removeAlert(buttonPressed:String="OK"):void
		{
			if (null != _alert && null != _alert.parent)
			{
				_alert.visible = false;
				
				var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
				if (buttonPressed == "YES")
					closeEvent.detail = Alert.YES;
				else if (buttonPressed == "NO")
					closeEvent.detail = Alert.NO;
				else if (buttonPressed == "OK")
					closeEvent.detail = Alert.OK;
				else if (buttonPressed == "CANCEL")
					closeEvent.detail = Alert.CANCEL;
				_alert.dispatchEvent(closeEvent);
				
				mx.managers.PopUpManager.removePopUp(_alert);
				_alert = null;
			}
			else
				trace("AlertUtil::removeAlert alert已经被删除");
		}
		
		/**
		 * 删除btn 
		 * @param flags 指定Alert.OK、Alert.CANCEL、Alert.YES Alert.NO 默认0x000f是所有的
		 * 
		 */		
		static public function removeAlertBtn(flags:uint=0x000f):void
		{
			if (null != _alert)
			{
				if (flags & Alert.OK)
				{
					removeBtn("OK");
				}
				
				if (flags & Alert.YES)
				{
					removeBtn("YES");
				}
				
				if (flags & Alert.NO)
				{
					removeBtn("NO");
				}
				
				if (flags & Alert.CANCEL)
				{
					removeBtn("CANCEL");
				}
			}
			else
				trace("AlertUtil::removeAlertBtn 未使用AlertUtil.show 弹出");
		}
		
		static private function removeBtn(name:String):void
		{
			var btn:mx.controls.Button;
			var alertForm:UIComponent = _alert.mx_internal::alertForm;
			btn = _alert.mx_internal::alertForm.getChildByName(name) as mx.controls.Button;
			if (null != btn)
			{
				alertForm.removeChild(btn);
				btn = null;
			}
			else
				trace("AlertUtil::removeBtn "+name+"不存在此按钮");
		}
		
		static private function alertClose(event:CloseEvent):void
		{
			_alert = null;
			if (null != _closeFunc)
			{
				_closeFunc.call(null,event);
				_closeFunc = null;
			}
		}
		
		public function AlertUtil()
		{
			throw new Error("ArrayUtil类只是一个静态方法类!");  
		}
		
		static private var _alert:Alert; 
		
		static private var _closeFunc:Function; 
	}
}