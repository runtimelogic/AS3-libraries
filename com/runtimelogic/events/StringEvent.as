/* ======================================================================

NAME: StringEvent

AUTHOR: AJ Canepa
DATE  : 5/23/2008

COMMENT: A general event that carries String event data with it.

========================================================================= */

package com.runtimelogic.events
{
	import flash.events.*;
	
	
	public class StringEvent extends Event
	{
		private var _eventData: String;
		
		
		/*
			Constructor
		*/
		function StringEvent(type: String, eventData: String, bubbles: Boolean = false, cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			_eventData = eventData;
		}
		
		
		//// Accessors / Mutators ////
		
		public function get eventData(): String
		{
			return _eventData;
		}
	}
}