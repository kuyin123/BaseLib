﻿/**	Copyright (c) 2007-2008 Ayan Ray | http://www.ayanray.com**	Permission is hereby granted, free of charge, to any person obtaining a copy*	of this software and associated documentation files (the "Software"), to deal*	in the Software without restriction, including without limitation the rights*	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell*	copies of the Software, and to permit persons to whom the Software is*	furnished to do so, subject to the following conditions:**	The above copyright notice and this permission notice shall be included in*	all copies or substantial portions of the Software.**	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,*	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE*	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,*	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN*	THE SOFTWARE.*/package ppf.base.resources.handlers{	import flash.events.*;	import flash.errors.MemoryError;	import flash.net.*;	import flash.utils.*;		import ppf.base.resources.handlers.BaseLoader;	import ppf.base.resources.loaders.AssetLoaderSettings;	/**	* The TextLoader Class uses the URLLoader to load in raw text data into Flash.	*/	public class TextLoader extends BaseLoader	{				public function TextLoader( url:String, settings:Object ):void 		{			this.settings = settings;			this.extra = (this.settings.extra != undefined) ? this.settings.extra : new Object();						// Configuration			this.loaderObj = new URLLoader();			this.listenersObj = this.loaderObj;						this.startListeners( this.listenersObj );						// Set Timeout			if(AssetLoaderSettings.TIMEOUT != 0) timeout = setTimeout( onTimeout , AssetLoaderSettings.TIMEOUT );						var request:URLRequest = new URLRequest(url);						try            {				loaderObj.load(request);            }						// All Error Cases			catch (e:ArgumentError)			{				this.onError( e );			}			catch (e:MemoryError)			{				this.onError( e );			}			catch (e:TypeError)			{				this.onError( e );			}            catch (e:SecurityError)            {              	this.onError( e );            }					}				public override function onComplete( e:Event ):void 		{   			var loader:URLLoader = e.target as URLLoader;    		if (loader != null)    		{				parseData (loader);				clear();   			}    		else    		{        		trace("Error: Loader is not XML!");			}		}								public function parseData ( loader:URLLoader ) :void		{ 			if(settings.onComplete != undefined)				settings.onComplete( {asset: loader, extra: this.extra} );		}				/**		* A Security Error occurs when Flash tries to access a file outside of it's sandbox. In most cases, you will 		* never need to set this. However, if you load SWF's from other URL's, you should handle this function.		*		*/		public function onSecurityError( e:SecurityErrorEvent ):void		{			if(settings.onIOError != undefined)				settings.onIOError({event:e, extra:this.extra});			else			{				onError( e );				throw new Error("ASSETLOADER: The URL cannot be opened from this domain. Here is the error: '" + e.text + "'.");			}				        }				public override function startListeners( dispatcher:IEventDispatcher ) :void 		{			super.startListeners( dispatcher );						// Custom			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 	onSecurityError, false, 0, true);		}		public override function stopListeners( dispatcher:IEventDispatcher ) :void 		{			super.stopListeners( dispatcher );						// Custom			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, 	onSecurityError);		}	}}