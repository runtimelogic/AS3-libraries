/* ======================================================================

NAME: ToolTipLayer

AUTHOR: AJ Canepa
DATE  : 7/1/2010

COMMENT: A class to manage tooltips that supports dynamic stage resizing.
You can use a generic Sprite as the display layer for tooltips, but if you
need to support dynamic stage resizing and positioning of tooltips, create
an instance of this class to use as the display layer.

VIEW TYPE: Dynamic

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	
	public class ToolTipLayer extends Sprite
	{
		private var _updateTimer: Timer;
		
		
		public function ToolTipLayer()
		{
			super();
			
			// create prompt timer
			_updateTimer = new Timer(1000, 1);
			_updateTimer.addEventListener(TimerEvent.TIMER, this.finalUpdate);
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
		}
		
		
		public function Done(): void
		{
			this.stage.removeEventListener(Event.RESIZE, this.resizeStage);
		}
		
		
		///// Accessors / Mutators /////
		
		
		///// Public Interface /////
		
		public function PositionToolTips(): void
		{
			this.updateAllChildren();
		}
		
		
		public function DisposeToolTips(): void
		{
			// Use this to dispose all tool tips.  If replacing a ToolTip on a ComplexButton simply add the new one
			// and the old on is automatically cleaned up.
			var toolTip: ToolTip;
			for (var i: int = this.numChildren - 1; i >= 0 ; i--)
			{
				toolTip = ToolTip(this.getChildAt(i));
				toolTip.Done();
			}
		}
		
		
		//// UI events ////
		
		protected function addedToStage(e: Event): void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addedToStage);
			
			// register for Stage events
			this.stage.addEventListener(Event.RESIZE, this.resizeStage);
		}
		
		
		private function resizeStage(e: Event): void
		{
			this.updateAllChildren();
			
			// make sure timer is reset and start running it
			_updateTimer.reset();
			_updateTimer.start();
		}
		
		
		private function finalUpdate(e: TimerEvent): void
		{
			_updateTimer.reset();
			
			// make sure to update one last time to work around poor notifications from IE and other browsers
			this.updateAllChildren();
		}
		
		
		///// Helper Methods /////
		
		private function updateAllChildren(): void
		{
			var toolTip: ToolTip;
			for (var i: uint = 0; i < this.numChildren; i++)
			{
				// reposition each tooltip
				toolTip = ToolTip(this.getChildAt(i));
				toolTip.UpdatePosition();
			}
		}
	}
}