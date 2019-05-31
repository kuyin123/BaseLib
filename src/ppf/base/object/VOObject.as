package ppf.base.object
{
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * vo对象数据基类<br/>
	 * 实现常用公共方法
	 * clone()<br/>
	 * cloneDeep()<br/>
	 * @author wangke
	 * 
	 */	
	public class VOObject extends EventDispatcher
	{
		 
		/**
		 * 浅复制对象引用对象不会被复制（引用对象不允许修改）
		 * @return 
		 */			
		public function clone():Object
		{
			return ObjectUtil.clone(this);
		}
		
		/**
		 * 按对象内部自定义要求复制,有复制要求的对象需重写此方法
		 * @return
		 */
		public function cloneNeed():Object{
			return null;
		}
		
		/**
		 * 深复制对象引用对象也会被复制，除非特殊必须，不建议使用  
		 * @return 
		 */	
		public function cloneDeep():Object
		{
			return ObjectUtil.cloneDeep(this);
		}
		
		public function VOObject(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}