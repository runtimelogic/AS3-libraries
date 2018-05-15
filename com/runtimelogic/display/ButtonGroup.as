/* ======================================================================

NAME: ButtonGroup

AUTHOR: AJ Canepa
DATE  : 3/22/2010

COMMENT: A Sprite containing ComplexButton instances that provides radiobutton behavior.

VIEW TYPE: Linked (this class is linked to a loaded asset).

========================================================================= */

package com.runtimelogic.display
{
	import flash.display.Sprite;
	
	import com.runtimelogic.events.UintEvent;
	
	
	public class ButtonGroup extends Sprite
	{
		// instance members
		
		private var _buttons: Array = new Array();
		private var _selectedButton: ComplexButton;
		
		
		public static const BUTTON_SELECTED_EVENT: String = "BUTTON_SELECTED_EVENT";
		
		
		public function ButtonGroup()
		{
			super();
			
			// go through child objects and register with this button group
			var tempButton: ComplexButton;
			for (var i: uint = 0; i < this.numChildren; i++)
			{
				tempButton = ComplexButton(this.getChildAt(i));
				tempButton.id = i;
				tempButton.buttonGroup = this;
				
				_buttons.push(tempButton);
			}
		}
		
		
		///// Accessors / Mutators /////
		
		public function get selectedButton(): ComplexButton							{ return _selectedButton; }
		
		
		///// Public Interface /////
		
		public function SelectButtonByIndex(index: uint): void
		{
			var tempButton: ComplexButton = _buttons[index];
			
			if (tempButton)
			{
				this.ChildClicked(tempButton);
			}
		}
		
		
		public function ChildClicked(buttonClicked: ComplexButton): void
		{
			var selectionChanged: Boolean = (_selectedButton != buttonClicked);
			
			_selectedButton = buttonClicked;
			
			// set selected state of each button
			var tempButton: ComplexButton;
			for (var i: uint = 0; i < _buttons.length; i++)
			{
				tempButton = _buttons[i];
				tempButton.selected = (tempButton == buttonClicked);
			}
			
			if (selectionChanged)
			{
				// selection changed so send select event
				this.dispatchEvent(new UintEvent(BUTTON_SELECTED_EVENT, _selectedButton.id));
			}
		}
		
		
		public function ChangeButtonLabel(index: uint, label: String): void
		{
			_buttons[index].buttonLabel = label;
		}
		
		
		//// UI Events ////
		
		
		///// Helper Methods /////
		
	}
}