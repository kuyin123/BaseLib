package ppf.base.object
{
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;

	public final class ObjectUtil
	{
		/**
		 * 深度复制<br/>子域对象复制可能会有问题，使用cloneDeep2
		 * 对象下属性引用对象也会被复制！！<br/>
		 * @param source
		 * @return 
		 * 
		 */		
		static public function cloneDeep(obj:*):*
		{
			var typeName:String = getQualifiedClassName(obj);//获取全名
			//return;
			var packageName:String = typeName.split("::")[0];//切出包名
			var type:Class = getDefinitionByName(typeName) as Class;//获取Class
			registerClassAlias(packageName, type);//注册Class
			//复制对象
			var copier:ByteArray = new ByteArray();
			copier.writeObject(obj);
			copier.position = 0;
			return copier.readObject();
		}
		
		/**
		 * 深复制一个对象<br/>
		 * 对象深度复制 : 将实例及子实例的所有成员(属性和方法, 静态的除外)都复制一遍, (引用要重新分配空间!)<br/>
		 * 对象下属性引用对象也会被复制！！<br/>
		 * 局限性 : <br/>
		 * 1. 不能对显示对象进行复制<br/>
		 * 2. obj的必须有默认构造函数(参数个数为0,或都有默认值)<br/>
		 * 3. obj 里有obj类型 之外 的非内置数据类型时, 返回类型将不确定<br/>
		 * 
		 * @param	深复制的对象
		 * @return  复制对象
		 */
		static public function cloneDeep2(obj:*):*
		{
			var aliasClass:Class;
			var classDefinition:Class = Object(obj).constructor as Class;
			var className:String = getQualifiedClassName(obj);
			
			// 获取已注册 obj的类名的类型
			try {
				aliasClass = getClassByAlias(className);
			}catch (err:Error) { }
			
			// 没有注册 AliasName
			if (!aliasClass)
			{
				registerClassAlias(className, classDefinition);
			}
				// 已经注册了 AliasName ,且不是它的全类名,要重新注册个
			else if (aliasClass != classDefinition)
			{
				registerClassAlias(className +":/:" + className, classDefinition);
			}
			//else
			// 注册的AliasName 为 全类名
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeObject(obj);
			byteArray.position = 0;
			return byteArray.readObject();
		}
		
		/**
		 * 复制数组，将数组重建并将每一个元素进行属性级别的复制
		 */
		static public function cloneArray(arr:Array):Array{
			if(!arr)
				return null;
			var result:Array = [];
			for each(var obj:Object in arr){
				result.push(clone(obj));
			}
			return result;
		}
		
		/**
		 * 浅复制一个对象<br/>
		 * 对象浅度复制 : 将实例及子实例的所有成员(属性和方法, 静态的除外)都复制一遍, (引用不必重新分配空间!)
		 * 
		 * @param	obj
		 * @return
		 */
		static public function clone(obj:*):*
		{
			if (obj == null
				|| obj is Class
				|| obj is Function
				|| isPrimitiveType(obj))
			{
				return obj;
			}
			
			var xml:XML = describeType(obj);
			var o:* = new (Object(obj).constructor as Class);
			// clone var variables
			for each(var key:XML in xml.variable)
			{
				o[key.@name] = obj[key.@name];
			}
			// clone getter setter, if the accessor is "readwrite" then set this accessor.
			for each(key in xml.accessor)
			{
				if("readwrite" == key.@access)
					o[key.@name] = obj[key.@name];
			}
			// clone dynamic variables
			for (var k:String in obj)
			{
				o[k] = obj[k];
			}
			return o;
		}
		
		/**
		 * 浅复制一个对象<br/>
		 * 对象浅度复制 : 将实例及子实例的所有成员(属性和方法, 静态的除外)都复制一遍, (引用不必重新分配空间!)<br/>
		 * 对象下属性引用对象不会复制<br/>
		 * 
		 * @param	obj
		 * @return
		 */
		static public function clone2(obj:*):*
		{
			if (obj == null
				|| obj is Class
				|| obj is Function
				|| isPrimitiveType(obj))
			{
				return obj;
			}
			
			var arr:Array = _dict[obj.toString()];
			if (null == arr)
			{
				arr = [];
				var xml:XML = describeType(obj);
				// clone var variables
				for each(var key:XML in xml.variable)
				{
					arr.push(key.@name);
				}
				for each(key in xml.accessor)
				{
					if("readwrite" == key.@access)
						arr.push(key.@name);
				}
			}
			var o:* = new (Object(obj).constructor as Class);
			
			for each (var s:String in arr)
			{
				o[s] = obj[s];
			}
			
			return o;
		}
		
		/**
		 * 测试是否为原始类型 , Booelan, Number, String
		 * @param	o
		 * @return
		 */
		static public function isPrimitiveType(o:*):Boolean
		{
			return o is Boolean || o is Number || o is String;
		}
		
		/**
		 * 判断两个对象是否相等<br/>
		 * 此方法不考虑引用地址是否相同(包括属性的引用地址),只考虑值是否相等<br/>
		 * 此方法不考虑类型信息(自定义类型和Object将区分,自定义类型与自定义类型不区分), 例如int, Number只要值相等,那么就相等.<br/>
		 * 如果registerClassAlias注册类别名,将区别类型信息,但int Number依然不区分类型信息.<br/>
		 * 建议判断的类型信息都相同<br/>
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function equals(a:*, b:*):Boolean
		{
			var ba:ByteArray = new ByteArray();
			ba.writeObject(a);
			var bb:ByteArray = new ByteArray();
			bb.writeObject(b);
			
			var len:uint = ba.length;
			if(bb.length != len) return false;
			
			ba.position = 0;
			bb.position = 0;
			for(var i:int = 0; i < len; i++)
			{
				if(ba.readByte() != bb.readByte())return false;
			}
			return true;
		}
		
		/**
		 * 获取Object的长度
		 * @param o Object
		 * @return 长度
		 *
		 */
		static public function getObjectLength(o:Object):Number
		{
			var len:Number=0;
			for (var prop:* in o)
			{
				if (prop != "mx_internal_uid")
				{
					len++;
				}
			}
			return len;
		}

		/**
		 *  
		 * @param source
		 * @param target
		 * @param proArr
		 * @return 
		 * 
		 */		
		public static function compareProperties(source:Object, target:Object,proArr:Array=null):Boolean
		{
			return true;
		}
		
		/**
		 * 复制属性，适用于简单的valueObject 
		 * @param source
		 * @param target
		 * 
		 */		
		public static function copyProperties(source:Object, target:Object,proArr:Array=null):void
		{
			if (source != target)
			{
				var propertyNames:Array;
				if (null == proArr)
				{
					propertyNames = [];
					var xml:XML=describeType(target);
					for each (var variableXML:XML in xml.variable)
					{
						propertyNames.push(variableXML.@name.toString())
					}
					for each (var accessorXML:XML in xml.accessor)
					{
						if (accessorXML.@access == "readwrite")
						{
							propertyNames.push(accessorXML.@name.toString())
						}
					}
				}
				else
					propertyNames = proArr;
		
				for each (var prop:String in propertyNames)
				{
					if (source.hasOwnProperty(prop))
					{
						target[prop]=source[prop];
					}
				}
			}
		}
		
//		public static function copyProperties1(source:Object, target:Object):void
//		{
//			//get a list of properties in target object
//			var classInfo:Object=ObjectUtil.getClassInfo(target, null, {includeReadOnly: false});
//			var properties:Array=classInfo.properties;
//			//trace("target properties  = " +properties);
//
//			//loop throught each property
//			for each (var prop:String in properties)
//			{
//
//				//ignore if the source does not have this property
//				if (source.hasOwnProperty(prop))
//				{
//					//trace("source " + prop + " = " +source[prop] );
//					//trace("target " + prop + " = " +target[prop] );
//
//					//get the class of the property
//					var propClassName:String=getQualifiedClassName(source[prop]);
//					var propClass:Class=getDefinitionByName(propClassName) as Class;
//
//					//trace("propClass = " + propClass);
//					//copy the property
//					//object util handles copying the prop in the right way
//					target[prop]=ObjectUtil.copy(source[prop]) as propClass;
//
//						//trace("Copied to target " + prop + " = " +target[prop] );
//				}
//				else
//				{
//					//trace("Property " + prop + " ignored");
//				}
//			}
//		}
		
		static private var _dict:Dictionary = new Dictionary(true);

		public function ObjectUtil()
		{
			throw new Error("ObjectUtil类只是一个静态方法类!");
		}
	}
}