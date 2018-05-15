/* ======================================================================

NAME: ObjectEvent

AUTHOR: AJ Canepa
DATE  : 5/23/2008

COMMENT: A general event that carries generic Object event data with it.

========================================================================= */

package com.runtimelogic.events
{
	import flash.events.*;
	
	
	public class ObjectEvent extends Event
	{
		private var _eventData: Object;
		
		
		/*
			Constructor
		*/
		function ObjectEvent(type: String, eventData: Object, bubbles: Boolean = false, cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			_eventData = eventData;
		}
		
		
		//// Accessors / Mutators ////
		
		public function get eventData(): Object
		{
			return _eventData;
		}
	}
}