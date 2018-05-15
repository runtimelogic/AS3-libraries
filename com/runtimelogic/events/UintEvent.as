/* ======================================================================

NAME: UintEvent

AUTHOR: AJ Canepa
DATE  : 5/23/2008

COMMENT: A general event that carries uint event data with it.

========================================================================= */

package com.runtimelogic.events
{
	import flash.events.*;
	
	
	public class UintEvent extends Event
	{
		private var _eventData: uint;
		
		
		/*
			Constructor
		*/
		function UintEvent(type: String, eventData: uint, bubbles: Boolean = false, cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			_eventData = eventData;
		}
		
		
		//// Accessors / Mutators ////
		
		public function get eventData(): uint
		{
			return _eventData;
		}
	}
}