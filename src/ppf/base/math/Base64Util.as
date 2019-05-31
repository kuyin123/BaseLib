package ppf.base.math
{
	import flash.utils.ByteArray;

	/**
	 * Base64 算法将输入的字符串或一段数据编码成只含有{”A”- ”Z”, ”a”-”z”, ”0”-”9”, ”+”, ”/”}这64个字符的串，
	 * <br/>”=”用于填充。其编码的方法是，将输入数据流每次取6 bit，用此6 bit的值(0-63)作为索引去查表，输出相应字符。
	 * <br/>这样，每3个字节将编码为4个字符(3×8 → 4×6)；不满4个字符的以”=”填充。
	 * 
	 * <br/>编码的过程是这样的：
	 * <br/>第一个字符通过右移2位获得第一个目标字符的Base64表位置，根据这个数值取到表上相应的字符，就是第一个目标字符。
	 * <br/>然后将第一个字符左移4位加上第二个字符右移4位，即获得第二个目标字符。
	 * <br/>再将第二个字符左移2位加上第三个字符右移6位，获得第三个目标字符。
	 * <br/>最后取第三个字符的右6位即获得第四个目标字符。
	 * 
	 * <br/>在以上的每一个步骤之后，再把结果与 0x3F 进行 AND 位操作，就可以得到编码后的字符了。
 	 * 
	 * <br/>来源于网上的Base64 效率比系统自带的Base64Decoder/Base64Encoder快点
	 * Base64 encoder/decoder class
	 * http://dynamicflash.com/goodies/base64/
	 * http://dynamicflash.com/downloads/base64/Base64-1.1.0.zip
	 * 例子：
	 * 1,Encoding from and decoding to String:

		   1. import com.dynamicflash.util.Base64;  
		   2.    
		   3. var source:String = "Hello, world!";  
		   4. var encoded:String = Base64.encode(source);  
		   5. trace(encoded)  
		   6.    
		   7. var decoded:String = Base64.decode(encoded);  
		   8. trace(decoded);  

			import com.dynamicflash.util.Base64;
			 
			var source:String = "Hello, world!";
			var encoded:String = Base64.encode(source);
			trace(encoded)
			 
			var decoded:String = Base64.decode(encoded);
			trace(decoded);
	 * 2,Encoding from and decoding to a ByteArray:

		   1. import com.dynamicflash.util.Base64;  
		   2.    
		   3. var obj:Object = {name:"Dynamic Flash", url:"http://dynamicflash.com"};  
		   4. var source:ByteArray = new ByteArray();  
		   5. source.writeObject(obj);  
		   6. var encoded:String = Base64.encodeByteArray(source);  
		   7. trace(encoded);  
		   8.    
		   9. var decoded:ByteArray = Base64.decodeToByteArray(encoded);  
		  10. var obj2:Object = decoded.readObject();  
		  11. trace(obj2.name + "(" + obj2.url + ")");  
	
	 * @author KK
	 */
	public final class Base64Util
	{
		/**
		 *
		 * @throws Error
		 */
		public function Base64Util()
		{
			throw new Error("Base64Util类只是一个静态方法类!");
		}
		
		/**
		 *
		 * @default
		 */
		public static const version:String="1.0.0";

		/**
		 *
		 * @param data
		 * @return
		 */
		public static function encode(data:String):String
		{

			// Convert string to ByteArray    
			var bytes:ByteArray=new ByteArray();

			bytes.writeUTFBytes(data);

			// Return encoded ByteArray    

			return encodeByteArray(bytes);
		}

		/**
		 *
		 * @param data
		 * @return
		 */
		public static function encodeByteArray(data:ByteArray):String
		{
			// Initialise output    
			var output:String="";

			// Create data and output buffers    
			var dataBuffer:Array;

			var outputBuffer:Array=new Array(4);

			// Rewind ByteArray    
			data.position=0;

			// while there are still bytes to be processed    
			while (data.bytesAvailable > 0)
			{
				// Create new data buffer and populate next 3 bytes from data    

				dataBuffer=new Array();

				for (var i:uint=0; i < 3 && data.bytesAvailable > 0; i++)
				{
					dataBuffer[i]=data.readUnsignedByte();
				}

				// Convert to data buffer Base64 character positions and    

				// store in output buffer    

				outputBuffer[0]=(dataBuffer[0] & 0xfc) >> 2;

				outputBuffer[1]=((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);

				outputBuffer[2]=((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);

				outputBuffer[3]=dataBuffer[2] & 0x3f;

				// If data buffer was short (i.e not 3 characters) then set    

				// end character indexes in data buffer to index of '=' symbol.    

				// This is necessary because Base64 data is always a multiple of    

				// 4 bytes and is basses with '=' symbols.    

				for (var j:uint=dataBuffer.length; j < 3; j++)
				{
					outputBuffer[j + 1]=64;
				}

				// Loop through output buffer and add Base64 characters to    

				// encoded data string for each character.    

				for (var k:uint=0; k < outputBuffer.length; k++)
				{
					output+=BASE64_CHARS.charAt(outputBuffer[k]);
				}
			}

			// Return encoded data    
			return output;
		}

		/**
		 *
		 * @param data
		 * @return
		 */
		public static function decode(data:String):String
		{
			// Decode data to ByteArray    
			var bytes:ByteArray=decodeToByteArray(data);

			// Convert to string and return    
			return bytes.readUTFBytes(bytes.length);
		}

		/**
		 *
		 * @param data
		 * @return
		 */
		public static function decodeToByteArray(data:String):ByteArray
		{
			// Initialise output ByteArray for decoded data    
			var output:ByteArray=new ByteArray();

			// Create data and output buffers    
			var dataBuffer:Array=new Array(4);
			var outputBuffer:Array=new Array(3);

			// While there are data bytes left to be processed    
			for (var i:uint=0; i < data.length; i+=4)
			{
				// Populate data buffer with position of Base64 characters for    
				// next 4 bytes from encoded data    
				for (var j:uint=0; j < 4 && i + j < data.length; j++)
				{
					dataBuffer[j]=BASE64_CHARS.indexOf(data.charAt(i + j));
				}

				// Decode data buffer back into bytes    

				outputBuffer[0]=(dataBuffer[0] << 2) + ((dataBuffer[1] & 0x30) >> 4);

				outputBuffer[1]=((dataBuffer[1] & 0x0f) << 4) + ((dataBuffer[2] & 0x3c) >> 2);

				outputBuffer[2]=((dataBuffer[2] & 0x03) << 6) + dataBuffer[3];

				// Add all non-padded bytes in output buffer to decoded data    

				for (var k:uint=0; k < outputBuffer.length; k++)
				{

					if (dataBuffer[k + 1] == 64)
						break;

					output.writeByte(outputBuffer[k]);
				}
			}

			// Rewind decoded data ByteArray    
			output.position=0;

			// Return decoded data    
			return output;
		}
//		private static const BASE64_CHARS:String="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		private static const BASE64_CHARS:String="fckD3V74jteRWu2+5i6slzLmFTYASygIOvh0KBX/rEJnwNbaG1pCqUZQ8M9dPoxH=";//base64编码需要增加=号
	}
}