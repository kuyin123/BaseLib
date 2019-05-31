package ppf.base.frame.docview.interfaces
{
	public interface IValidator
	{
		function get minNum():Number;
		function set minNum(value:Number):void;
		
		function get maxNum():Number;
		function set maxNum(value:Number):void;
		
		function get validReg():RegExp;
		function set validReg(value:RegExp):void;
	}
}