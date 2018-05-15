/* ======================================================================

NAME: SocketCallTriggered

AUTHOR: AJ Canepa
DATE  : 4/27/2008

COMMENT: This is a transitional class to use until a MVC architecture is
in place.  It tracks a call originator object reference so that the
call can be processed by ApplicationServer and then dispatched the class
that made the original call to ApplicationServer to start the transaction.

When MVC is in place, the result call will be handled by ApplicationServer
and then forwarded to the Controller for processing, which will make
this class obsolete and it should be removed.

========================================================================= */

package com.util
{
    import flash.net.URLVariables;
    
	import com.util.SocketCall;
	
	
	public class SocketCallTriggered extends SocketCall
	{
		private var _callOriginator: Object;  // the instance that originated this socket call
		
		
		function SocketCallTriggered(url: String, callbackFunction: Function, callbackType: uint,
			callOriginator: Object, variables: URLVariables = null)
		{
			super(url, callbackFunction, callbackType, variables);
			
			_callOriginator = callOriginator;
		}
		
		
		///// Accessors / Mutators /////
		
		public function get callOriginator(): Object
		{
			return _callOriginator;
		}
	}
}