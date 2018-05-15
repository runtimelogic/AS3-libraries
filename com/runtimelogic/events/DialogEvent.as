/* ======================================================================

NAME: DialogEvent

AUTHOR: AJ Canepa
DATE  : 3/10/2009

COMMENT: An event for displaying dialogs that carries String event data with it
and optional untyped model data that the popup will render.

========================================================================= */

package com.runtimelogic.events
{
	import flash.events.*;
	
	
	public class DialogEvent extends Event
	{
		private var _dialogID: String;
		private var _modelData: *;
		private var _tabID: String;
		
		
		/*
			Constructor
		*/
		function DialogEvent(type: String, dialogID: String, modelData: * = null, tabID: String = null,
			bubbles: Boolean = false, cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			_dialogID = dialogID;
			_modelData = modelData;
			_tabID = tabID;
		}
		
		
		//// Accessors / Mutators ////
		
		public function get dialogID(): String					{ return _dialogID; }
		
		public function get modelData(): *						{ return _modelData; }
		
		public function get tabID(): String						{ return _tabID; }
	}
}