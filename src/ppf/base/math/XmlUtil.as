package ppf.base.math
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLEncoder;
	
	import ppf.base.resources.LocaleConst;
	import ppf.base.resources.LocaleManager;

	public final class XmlUtil
	{
		static public function initGet(xml:XML, nodeName:String, defaultVal:Object):Object
		{
			if (xml.hasOwnProperty(nodeName))
				return xml[nodeName];
			else
				return defaultVal;
		}
//		
//		/**
//		 * var dept:XMLList = walkXML(xml,'id','1'); 
//		 * @param node
//		 * @param attribute
//		 * @param value
//		 * @return 
//		 * 
//		 */		
//		static public function walkXML(node:XML,attribute:String,value:String):XMLList
//		{
//			var dept:XMLList;
//			if (node.attribute(attribute) == value)
//			{
//				return XMLList(node);
//			}
//			for each ( var element:XML in node.elements()) 
//			{
//				if (element.attribute(attribute) == value)
//				{
//					dept= XMLList(element);
//					break;
//				}
//				else
//				{
//					dept = walkXML(element,attribute,value);
//					
//					if (null != dept)
//						break;
//				}
//			}
//			return dept;
//		}
		
		/**
		 * Object转XML
		 */
		static public function objToXml(obj:Object , rootStr:String):XML{
				var qName:QName = new QName(rootStr);
				var xmlDocument:XMLDocument = new XMLDocument();
				var simpleXMLEncoder:SimpleXMLEncoder = new SimpleXMLEncoder(xmlDocument);
				var xmlNode:XMLNode = simpleXMLEncoder.encodeValue(obj, qName, xmlDocument);
				var xml:XML = new XML(xmlDocument.toString());
				return xml;
		}
		
		/**
		 * 转换xml为ArrayCollection
		 * @param xml 需要转换的xml
		 * @return  转换后的ArrayCollection
		 * 
		 */		
		public static function xml2ArrayCollection(xml:XML):ArrayCollection
		{
			var array:ArrayCollection = new ArrayCollection;
			
			//XML所有对象的元素列表
			var elementList:XMLList = xml.elements();
			var obj:Object;
			var attriList:XMLList;
			var qName:QName;
			for each (var elementXML:XML in elementList)
			{
				obj = {};
				//当前XML的所有属性列表
				attriList = elementXML.attributes();
				for each (var attriXML:XML in attriList)
				{
					qName = attriXML.name() as QName;
					obj[qName.localName] = LocaleManager.getInstance().getString(LocaleConst.CMD,elementXML.attribute(qName.localName)[0].toString());//elementXML.attribute(qName.localName)[0].toString();
				}
				
				//转换当前元素的子元素属性为ArrayCollection
				obj.children = xml2ArrayCollection(elementXML);
				
				if (obj.children.length == 0 )
					obj.children = null;
				array.addItem(obj);
			}
			return array;
		}
		
		public static function xml2Array(xml:XMLList):Array
		{
			var arr:Array = [];
			xmlAdd2Array(xml,arr);
			return arr;
		}
		
		public static function xmlAdd2Array(xml:XMLList,arr:Array):void
		{
			//XML所有对象的元素列表
			var elementList:XMLList = xml.children()
			var obj:Object;
			var attriList:XMLList;
			var qName:QName;
			for each (var elementXML:XML in elementList)
			{
				obj = {};
				//当前XML的所有属性列表
				attriList = elementXML.attributes();
				for each (var attriXML:XML in attriList)
				{
					qName = attriXML.name() as QName;
					obj[qName.localName] = elementXML.attribute(qName.localName)[0].toString();
				}
				arr.push(obj);
			}
		}
		
		public function XmlUtil()
		{
			throw new Error("XmlUtil类只是一个静态方法类!");  
		}
	}
}