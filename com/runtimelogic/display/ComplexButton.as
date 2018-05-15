/* ======================================================================

NAME: ComplexButton

AUTHOR: AJ Canepa
DATE  : 3/19/2010

COMMENT: A class for buttons that is based off a MovieClip with labeled frames for button states and an optional button TextField.  A SimpleButton with instance name "clickArea" and alpha 0 should be overlaid in the asset for proper click behavior.

Supports animated buttons.  By default the button uses a single frame per button state, called "normal" mode.  In normal mode you aren't required to add stop frames to the MovieClip asset.  By calling the "animate" mutator, it puts the class into animated mode where it will allow the playhead to play when jumping to the frames for each button state.  When operating in animated mode you will need to add stops at the end of each frame range for each button state, except possibly the out or up state, which is can be an animation that plays through to the enabled state.  Even in animated mode, the enabled, disabled and selected states should be a single frame (there can be nested looping animations of course).

Button state frame labels:
over, down						- single frame or animated, set animate = true to use animated states; use stop frames
out, up 						- only used with animated buttons; may not have stop frame
enabled, disabled*, selected* 	- single frame only; no stop frame needed
* = optional states

A dynamic button label is supported via a nested "buttonLabels" MovieClip.  This should contain "enabledText" and "disabledText" TextFields.

VIEW TYPE: Linked (this class is linked to a loaded asset).

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	
	public class ComplexButton extends MovieClip
	{
		// instance members
		public var buttonLabels: MovieClip;
		public var clickArea: SimpleButton;
		
		private var _animate: Boolean = false;
		private var _enabled: Boolean = false;  // we track our own enabled member to avoid potential conflicts
		private var _selected: Boolean = false;
		private var _mouseIsOver: Boolean = false;
		private var	_id: uint = 0;  // a value that can be used to identify a button when clicked
		private var _buttonGroup: ButtonGroup;  // an optional button group that supports radio button functionality
		
		private var _buttonLabel: String;
//		private var _clickSound: Sound;  // click sound to be triggered when button pressed
		private var _toolTip: ToolTip;  // optional tool tip
		
		
		public function ComplexButton()
		{
			super();
			
			this.enabled = true;
			this.clickArea.addEventListener(MouseEvent.CLICK, this.clicked, false, 0, true);
		}
		
		
		public function Done(): void
		{
			_buttonGroup = null;
			
			if (_toolTip)
			{
				_toolTip.Done();
			}
		}
		
		
		///// Accessors / Mutators /////
		
		public function get animate(): Boolean									{ return _animate; }
		public function set animate(val: Boolean): void							{ _animate = val; }
		
//		public function get enabled(): Boolean									{ return _enabled; }
		override public function set enabled(val: Boolean): void
		{
			super.enabled = val;
			
			if (_enabled == val)
			{
				// enabled state is not changing
				return;
			}
			
			_enabled = val;
			
			// button text style is the enabled style unless this is a disabled button that is not selected
			this.changeButtonLabelStyle(_enabled || _selected);
			
			// control visiblity of click area to remove the click cursor when disabled
			this.clickArea.visible = _enabled;
			// control mouse events for this DisplayObjectContainer and its children
			this.mouseChildren = _enabled;
			this.mouseEnabled = _enabled;
			
			if (_enabled)
			{
				// add mouse handlers
				this.clickArea.addEventListener(MouseEvent.ROLL_OVER, this.rollOver);
				this.clickArea.addEventListener(MouseEvent.ROLL_OUT, this.rollOut);	
				this.clickArea.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);	
				this.clickArea.addEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
				
				this.gotoAndStop("enabled");
			}
			else
			{
				// remove mouse handlers
				this.clickArea.removeEventListener(MouseEvent.ROLL_OVER, this.rollOver);
				this.clickArea.removeEventListener(MouseEvent.ROLL_OUT, this.rollOut);	
				this.clickArea.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);	
				this.clickArea.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
				this.clickArea.visible = false;
				
				if (_selected)
				{
					this.gotoAndStop("selected");
				}
				else
				{
					this.gotoAndStop("disabled");
				}
			}
			
			if (_toolTip)
			{
				// set enabled state of tool tip to match button
				_toolTip.enabled = _enabled;
			}
		}
		
		public function get selected(): Boolean									{ return _selected; }
		public function set selected(val: Boolean): void
		{
			_selected = val;
			
			this.enabled = ! _selected;
		}
		
		public function get id(): uint											{ return _id; }
		public function set id(val: uint): void									{ _id = val; }
		
		public function get buttonGroup(): ButtonGroup							{ return _buttonGroup; }
		public function set buttonGroup(val: ButtonGroup): void					{ _buttonGroup = val; }
		
		public function get buttonLabel(): String								{ return _buttonLabel; }
		public function set buttonLabel(val: String): void
		{
			_buttonLabel = val;
			
			if (this.buttonLabels.enabledText != undefined)
			{
				TextField(this.buttonLabels.enabledText).text = _buttonLabel;
			}
			if (this.buttonLabels.disabledText != undefined)
			{
				TextField(this.buttonLabels.disabledText).text = _buttonLabel;
			}
		}
		
		
		///// Public Interface /////
		
		public function AddToolTip(toolTipLabel: String, placement: uint = ToolTip.PLACEMENT_TOP): void
		{
			// if necessary, clean up old tool tip
			this.RemoveToolTip();
			
			_toolTip = new ToolTip(this, toolTipLabel, placement);
		}
		
		
		public function RemoveToolTip(): void
		{
			if (_toolTip)
			{
				_toolTip.Done();
				_toolTip = null;
			}
		}
		
		
		//// UI Events ////
		
		private function rollOver(e: MouseEvent): void
		{
			_mouseIsOver = true;
			
			if (_animate)
			{
				this.gotoAndPlay("over");
			}
			else
			{
				this.gotoAndStop("over");
			}
		}
		
		
		private function rollOut(e: MouseEvent): void
		{
			_mouseIsOver = false;
			
			if (_animate)
			{
				this.gotoAndPlay("out");
			}
			else
			{
				this.gotoAndStop("enabled");
			}
		}
		
		
		private function mouseDown(e: MouseEvent): void
		{
			if (_animate)
			{
				this.gotoAndPlay("down");
			}
			else
			{
				this.gotoAndStop("down");
			}
		}
		
		
		private function mouseUp(e: MouseEvent): void
		{
			if (_animate)
			{
				this.gotoAndPlay("up");
			}
			else
			{
				if (_mouseIsOver)
				{
					this.gotoAndStop("over");
				}
				else
				{
					this.gotoAndStop("enabled");
				}
			}
		}
		
		
		private function clicked(e: MouseEvent): void
		{
			if (_enabled)
			{
				if (_buttonGroup)
				{
					_buttonGroup.ChildClicked(this);
				}
			}
			else
			{
//				e.stopPropagation();
			}
		}
		
		
		///// Helper Methods /////
		
		private function changeButtonLabelStyle(enabled: Boolean): void
		{
			if (_buttonLabel)
			{
				// button labels are in use since the _buttonLabel string has been defined
				this.buttonLabels.enabledText.visible = enabled;
				this.buttonLabels.disabledText.visible = ! enabled;
			}
		}
	}
}