/* ======================================================================

NAME: SocketCall

AUTHOR: AJ Canepa
DATE  : 4/27/2008

COMMENT: A utility class for initating and handling the return data for
a HTTP socket call to a server.  On server call completion the provided
callback method is invoked and a reference to the class instance passed.
The callback method can then use the provided accessors to retrieve the
call status, result data (or error message), and the callback type.
The latter is a mechanism which allows dispatching of the call results
based on an indentifier that was passed into the constructor when the
call was originated.

4/8/2009 - Added support for form post of ByteArray as MIME encoded file
12/1/2013 - Added support for sending variables packaged in with multipart
	binary data.

------
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at 
http://www.mozilla.org/MPL/
Software distributed under the License is distributed on an "AS IS" basis, WITHOUT
WARRANTY OF ANY KIND, either express or implied. See the License for the specific
language governing rights and limitations under the License.

The Initial Developer of the Original Code is AJ Canepa. Portions created by
AJ Canepa are Copyright (C) 2009, Runtime Logic, Inc. All Rights Reserved.

========================================================================= */

package com.runtimelogic.net
{
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
    import flash.net.URLVariables;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	public class SocketCall
	{
		private var _loader: URLLoader = new URLLoader();
		private var _request: URLRequest = new URLRequest();
		private var _variables: URLVariables;
		private var _callbackFunction: Function;
		private var _callbackType: uint;
		
		private var _status: uint;
		private var _result: String;
		
		
		public static const NOERR: uint = 0;
		public static const ERR: uint = 1;
		public static const FILE_UPLOAD: String = "FILE_UPLOAD";
		
		
		function SocketCall(url: String, callbackFunction: Function, callbackType: uint,
			variables: URLVariables = null, requestMethod: String = "GET", headers: Array = null,
			files: Array = null, filenames: Array = null, contentType: String = "application/octet-stream"): void
		{
			_callbackFunction = callbackFunction;
			_callbackType = callbackType;
			_variables = variables;
			
			_loader.addEventListener(Event.COMPLETE, this.dataLoaded);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, this.socketError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityError);
//			_loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, this.responseListener);
//			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.responseListener);
			
			_request.url = url;
			
			if (requestMethod == FILE_UPLOAD)
			{
				// ByteArray file upload via POST
				this.encodeForFormPost(files, filenames, contentType);
			}
			else
			{
				// standard handling
				if (_variables)
				{
					_request.data = _variables;
				}
				
				_request.method = requestMethod;
				
				if (headers)
				{
					_request.requestHeaders = headers;
				}
			}
			
			_loader.load(_request);
		}
		
		
		///// Accessors / Mutators /////
		
		public function get callbackType(): uint		{ return _callbackType; }
		public function get status(): uint				{ return _status; }
		public function get result(): String			{ return _result; }
		
		
		///// Callback Handlers /////
		
		private function dataLoaded(e: Event): void
		{
			_loader.removeEventListener(Event.COMPLETE, dataLoaded);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, socketError);
			
			_status = NOERR;
			_result = e.target.data;
			_callbackFunction(this);
		}
		
		
		private function socketError(e: IOErrorEvent): void
		{
			trace("IOError response: " + e.text);
            	
			_status = ERR;
			_result = e.text;
			_callbackFunction(this);
		}
		
		
		private function securityError(e: SecurityErrorEvent): void
		{
			trace("Security Error response: " + e.errorID + ": " + e.text);
		}
		
		
		private function responseListener(e: HTTPStatusEvent): void
		{
			trace("HTTP response: " + e.responseURL + " -- status: " + e.status);
		}
		
		
		///// Helper Methods /////
		
		/*
			The following borrowed from com.jooce.net and adapted.
			files is an Array of ByteArray / filenames is an array of String
		*/
		
		private function encodeForFormPost(files: Array, filenames: Array, contentType: String): void
		{
			var i: int;
			var bytes: String;
			var boundary: String = "";
			var postData: ByteArray = new ByteArray;
			postData.endian = Endian.BIG_ENDIAN;
			
			for ( i = 0; i < 0x10; i++ )
				boundary += String.fromCharCode( int( 97 + Math.random() * 25 ) );
	
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			_request.method = URLRequestMethod.POST;
			
			_request.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
			_request.requestHeaders.push(new URLRequestHeader('Content-Type', 'multipart/form-data; boundary='
				+ boundary));
			
			// update boundary to include double dash prefix for all further use
			boundary = '--' + boundary;
			
			if (_variables != null)
			{
				// encode provided variables into the postData ByteArray
				for (var name:String in _variables)
				{
					// boundary
					for ( i = 0; i < boundary.length; i++ )
					postData.writeByte( boundary.charCodeAt( i ) );
					
					// line break
					postData.writeShort( 0x0d0a );
					
					// content disposition
					bytes = 'Content-Disposition: form-data; name="' + name + '"';
					for ( i = 0; i < bytes.length; i++ )
						postData.writeByte( bytes.charCodeAt(i) );
					
					// 2 line breaks
					postData.writeInt( 0x0d0a0d0a );
					
					postData.writeUTFBytes(_variables[name]);
					
					// line break
					postData.writeShort( 0x0d0a );
				}
			}
			
			
			// add files to postData
			for (var j: uint = 0; j < files.length; j++)
			{
				// boundary
				for ( i = 0; i < boundary.length; i++ )
					postData.writeByte( boundary.charCodeAt( i ) );
				
				// line break
				postData.writeShort( 0x0d0a );
				
				// content disposition
				bytes = 'Content-Disposition: form-data; name="filename' + j + '"';
				for ( i = 0; i < bytes.length; i++ )
					postData.writeByte( bytes.charCodeAt( i ) );
				
				// 2 line breaks
				postData.writeInt( 0x0d0a0d0a );
				
				// file name
				postData.writeUTFBytes( filenames[j] );
				
				// line break
				postData.writeShort( 0x0d0a );
				
				// boundary
				for ( i = 0; i < boundary.length; i++ )
					postData.writeByte( boundary.charCodeAt( i ) );
				
				// line break
				postData.writeShort( 0x0d0a );
				
				// content disposition
				bytes = 'Content-Disposition: form-data; name="filedata' + j + '"; filename="';
				for ( i = 0; i < bytes.length; i++ )
					postData.writeByte( bytes.charCodeAt( i ) );
				
				// file name
				postData.writeUTFBytes( filenames[j] );
				
				// closing "
				postData.writeByte( 0x22 );
				
				// line break
				postData.writeShort( 0x0d0a );
				
				// content type
				bytes = 'Content-Type: ' + contentType;
				for ( i = 0; i < bytes.length; i++ )
					postData.writeByte( bytes.charCodeAt( i ) );
				
				// 2 line breaks
				postData.writeInt( 0x0d0a0d0a );
				
				// file data
				postData.writeBytes( files[j], 0, files[j].length );
				
				// line break
				postData.writeShort( 0x0d0a );
			}
			
			
			// boundary
			for ( i = 0; i < boundary.length; i++ )
				postData.writeByte( boundary.charCodeAt( i ) );
	
			// line break			
			postData.writeShort( 0x0d0a );
			
			// upload field
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for ( i = 0; i < bytes.length; i++ )
				postData.writeByte( bytes.charCodeAt( i ) );
			
			// 2 line breaks
			postData.writeInt( 0x0d0a0d0a );
			
			// submit
			bytes = 'Submit Query';
			for ( i = 0; i < bytes.length; i++ )
				postData.writeByte( bytes.charCodeAt( i ) );
			
			// line break
			postData.writeShort( 0x0d0a );
			
			// boundary + --
			for ( i = 0; i < boundary.length; i++ )
				postData.writeByte( boundary.charCodeAt( i ) );
			postData.writeShort( 0x2d2d );
	
			_request.data = postData;
		}
	}
}