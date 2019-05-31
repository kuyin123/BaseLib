package ppf.base.frame.docview.interfaces
{
	public interface IDragInitiator
	{
		/**
		 * 启动拖动的组件的来源
		 * DragGroup.IN：在拖动容器里
		 * DragGroup.OUT：在拖动容器外
		 * @return 
		 * 
		 */		
		function get source():String;
		
		/**
		 * dragSource的dataForFormat
		 * @return 
		 * 
		 */		
		function get dataForFormat():String;
		
		/**
		 * 数据的字段
		 * @return 
		 * 
		 */		
		function get dataField():String;
		
		/**
		 * 拖动的类型，以此作为区分创建dragItem的类型 
		 * @return 
		 * 
		 */		
		function getDragType(item:Object):String;
	}
}