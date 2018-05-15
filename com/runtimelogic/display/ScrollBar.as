/* ======================================================================

NAME: ScrollBar

AUTHOR: AJ Canepa
DATE  : 8/2/2014

COMMENT: A scroll bar display class that can target any DisplayObject to
scroll it.  A display container can optionally be provided and the scroll
bar will place the content in this container to display whenever new content
is specified.  The display container can be enabled for drag to support
touchscreen devices.

VIEW TYPE: Linked (this class is linked to a loaded asset).

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	
	public class ScrollBar extends Sprite
	{
		// instance members
		public var thumb: Sprite;
		
		private var _content: DisplayObject;
		private var _minThumbPosition: uint;
		private var _maxThumbPosition: uint;
		private var _displaySize: uint;
		private var _scrollDirection: uint = VERTICAL;
		private var _displayContainer: Sprite;
		private var _dragBounds: Rectangle;
		private var _minContentPosition: Number;
		private var _maxContentPosition: Number;
		
		
		public static const VERTICAL: uint = 0;
		public static const HORIZONTAL: uint = 1;
		
		
		public function ScrollBar()
		{
			super();
			
			_minThumbPosition = this.y;
			_maxThumbPosition = this.y + this.height;
			
			// UI event listeners
			this.thumb.addEventListener(MouseEvent.MOUSE_DOWN, this.startDragging);
		}
		
		
		public function Init(minThumbPosition: uint, maxThumbPosition: uint, displaySize: uint,
			scrollDirection: uint = VERTICAL, displayContainer: Sprite = null): void
		{
			_minThumbPosition = minThumbPosition;
			_maxThumbPosition = maxThumbPosition;
			_displaySize = displaySize;
			_scrollDirection = scrollDirection;
			_displayContainer = displayContainer;
			
			// define the boundary rectangle to constrain to when dragging the thumb
			if (_scrollDirection == VERTICAL)
			{
				_dragBounds = new Rectangle(this.thumb.x, _minThumbPosition, 0, _maxThumbPosition);
			}
			else
			{
				_dragBounds = new Rectangle(_minThumbPosition, this.thumb.y, _maxThumbPosition, 0);
			}
		}
		
		
		///// Accessors / Mutators /////
		
		public function get content(): DisplayObject							{ return _content; }
		public function set content(val: DisplayObject): void
		{
			if (_content)
			{
				// reset to starting position
				if (_scrollDirection == VERTICAL)
				{
					this.thumb.y = _minThumbPosition;
					_content.y = _minContentPosition;
				}
				else
				{
					this.thumb.x = _minThumbPosition;
					_content.x = _minContentPosition;
				}
				
				if (_displayContainer)
				{
					_displayContainer.removeChild(_content);
				}
			}
			
			_content = val;
			
			if (_displayContainer)
			{
				_displayContainer.addChild(_content);
			}
			
			// determine content scrollable size
			if (_scrollDirection == VERTICAL)
			{
				_minContentPosition = _content.y;
				_maxContentPosition = _content.y - _content.height + _displaySize;
			}
			else
			{
				_minContentPosition = _content.x;
				_maxContentPosition = _content.x - _content.width + _displaySize;
			}
			
			// disable if current content size fits in display area
			this.thumb.visible = true;
			if (_scrollDirection == VERTICAL)
			{
				if (_displaySize >= _content.height)
				{
					this.thumb.visible = false;
				}
			}
			else
			{
				if (_displaySize >= _content.width)
				{
					this.thumb.visible = false;
				}
			}
		}
		
		
		///// Public Interface /////
		
		
		//// UI Events ////
		
		protected function startDragging(e: MouseEvent): void
		{
			this.thumb.startDrag(false, _dragBounds);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, this.stopDragging);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.updateScrollPosition);
		}
		
		
		private function stopDragging(e: MouseEvent): void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.updateScrollPosition);
			
			this.thumb.stopDrag();
		}
		
		
		private function updateScrollPosition(e: MouseEvent): void
		{
			var scrollPercent: Number;
			
			if (_scrollDirection == VERTICAL)
			{
				// determine thumb location
				scrollPercent = 1 - ((_maxThumbPosition - this.thumb.y) / _maxThumbPosition);
//				_content.y = _minContentPosition - (_content.height * scrollPercent);
				_content.y = _minContentPosition - ((_minContentPosition - _maxContentPosition) * scrollPercent);
			}
			else
			{
				scrollPercent = 1 - ((_maxThumbPosition - this.thumb.x) / _maxThumbPosition);
//				_content.x = _minContentPosition - (_content.width * scrollPercent);
				_content.x = _minContentPosition - ((_minContentPosition - _maxContentPosition) * scrollPercent);
			}
		}
		
		
		///// Helper Methods /////
		
	}
}